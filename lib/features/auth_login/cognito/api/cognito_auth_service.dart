import 'dart:async';
import 'dart:convert';

import '../model/cognito_auth_exception.dart';
import '../model/cognito_config.dart';
import '../model/cognito_session.dart';
import 'cognito_token_store.dart';
import 'cognito_transport.dart';

part 'cognito_registration.dart';
part 'cognito_user_api.dart';

class CognitoAuthService {
  CognitoAuthService({
    required this.config,
    CognitoTransport? transport,
    CognitoTokenStore? tokenStore,
    DateTime Function()? clock,
  }) : _transport = transport ?? CognitoHttpTransport(config),
       _store = tokenStore ?? SecureCognitoTokenStore(),
       _clock = clock ?? DateTime.now;
  final CognitoConfig config;
  final CognitoTransport _transport;
  final CognitoTokenStore _store;
  final DateTime Function() _clock;
  final _changes = StreamController<CognitoSession?>.broadcast();
  CognitoSession? _session;
  Future<CognitoSession?>? _refreshing;
  int _generation = 0;
  bool _disposed = false;
  Future<void> _storageTail = Future<void>.value();
  CognitoSession? get currentSession => _session;
  Stream<CognitoSession?> get sessionChanges => _changes.stream;
  Future<CognitoSession> signIn({
    required String email,
    required String password,
  }) async {
    // Cognito verifica la contraseña y devuelve tokens si las credenciales son válidas.
    final generation = ++_generation;
    final result = await _send('InitiateAuth', {
      'AuthFlow': 'USER_PASSWORD_AUTH',
      'AuthParameters': {'USERNAME': email.trim(), 'PASSWORD': password},
    });
    if (result['ChallengeName'] != null) {
      throw const CognitoAuthException(
        'challenge_required',
        'The account requires an additional verification step.',
      );
    }
    final session = CognitoSession.parse(
      _authentication(result),
      config,
      _clock(),
    );
    await _save(session, generation);
    return session;
  }

  Future<CognitoSession?> restoreSession() async {
    if (_disposed) {
      return null;
    }
    final generation = _generation;
    final stored = await _store.read();
    if (stored == null || generation != _generation) {
      return null;
    }
    try {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      final session = CognitoSession.parse(
        decoded,
        config,
        _clock(),
        allowExpired: true,
      );
      if (session.isExpired(_clock())) {
        return await _refresh(session, generation);
      }
      _session = session;
      if (!_changes.isClosed) {
        _changes.add(session);
      }
      return session;
    } on CognitoAuthException catch (error) {
      if (error.code == 'offline' ||
          error.code == 'timeout' ||
          error.code == 'service_unavailable') {
        rethrow;
      }
      if (generation == _generation) {
        await _clear();
      }
      return null;
    } on FormatException {
      if (generation == _generation) {
        await _clear();
      }
      return null;
    } on TypeError {
      if (generation == _generation) {
        await _clear();
      }
      return null;
    }
  }

  Future<CognitoSession?> validSession({bool forceRefresh = false}) async {
    final session = _session;
    if (session == null) {
      return null;
    }
    if (!forceRefresh && !session.isExpired(_clock())) {
      return session;
    }
    if (_refreshing != null) {
      return _refreshing;
    }
    final generation = _generation;
    final future = _refresh(session, generation);
    _refreshing = future;
    try {
      return await future;
    } on CognitoAuthException catch (error) {
      if (generation == _generation &&
          (error.code == 'authentication_failed' ||
              error.code == 'invalid_session')) {
        await _clear();
      }
      rethrow;
    } finally {
      _refreshing = null;
    }
  }

  Future<CognitoSession?> _refresh(
    CognitoSession session,
    int generation,
  ) async {
    final result = await _send('GetTokensFromRefreshToken', {
      'RefreshToken': session.refreshToken,
    });
    final updated = CognitoSession.parse(
      _authentication(result),
      config,
      _clock(),
      previousRefreshToken: session.refreshToken,
    );
    if (updated.sub != session.sub) {
      throw const CognitoAuthException(
        'invalid_session',
        'Your session is invalid. Please sign in again.',
      );
    }
    await _save(updated, generation);
    return updated;
  }

  Future<CognitoSignOutResult> signOut() async {
    final session = _session;
    ++_generation;
    await _clear();
    if (session == null) {
      return const CognitoSignOutResult(remoteRevoked: false);
    }
    try {
      await _transport.send('GlobalSignOut', {
        'AccessToken': session.accessToken,
      });
      return const CognitoSignOutResult(remoteRevoked: true);
    } on CognitoAuthException {
      return const CognitoSignOutResult(remoteRevoked: false);
    }
  }

  Future<Map<String, dynamic>> _send(
    String operation,
    Map<String, dynamic> fields,
  ) {
    if (_disposed) {
      throw const CognitoAuthException(
        'cancelled',
        'The sign-in request was canceled.',
      );
    }
    if (!config.isValid) {
      throw const CognitoAuthException(
        'configuration',
        'Authentication is not configured yet.',
      );
    }
    return _transport.send(operation, {'ClientId': config.clientId, ...fields});
  }

  Map<String, dynamic> _authentication(Map<String, dynamic> result) {
    final auth = result['AuthenticationResult'];
    if (auth is! Map<String, dynamic>) {
      throw const CognitoAuthException('invalid_session', 'Could not sign in.');
    }
    return auth;
  }

  Future<void> _save(CognitoSession session, int generation) =>
      _storageOperation(() async {
        if (_disposed || generation != _generation) {
          throw const CognitoAuthException(
            'cancelled',
            'The sign-in request was canceled.',
          );
        }
        await _store.write(session.encode());
        if (_disposed || generation != _generation) {
          throw const CognitoAuthException(
            'cancelled',
            'The sign-in request was canceled.',
          );
        }
        _session = session;
        if (!_changes.isClosed) {
          _changes.add(session);
        }
      });

  Future<void> _clear() {
    _session = null;
    if (!_changes.isClosed) {
      _changes.add(null);
    }
    return _storageOperation(_store.clear);
  }

  Future<void> _storageOperation(Future<void> Function() action) {
    final pending = _storageTail.then((_) => action());
    _storageTail = pending.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return pending;
  }

  Future<void> dispose() {
    _disposed = true;
    ++_generation;
    _session = null;
    return _changes.close();
  }
}
