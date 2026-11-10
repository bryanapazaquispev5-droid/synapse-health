import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth_login/cognito/model/cognito_auth_exception.dart';
import '../services/user_local_profile_service.dart';
import 'app_user.dart';
import 'auth_backend.dart';

class DynamoAuthService implements AuthBackend {
  DynamoAuthService({
    String? baseUrl,
    FlutterSecureStorage? storage,
    HttpClient Function()? clientFactory,
  }) : baseUrl = Uri.parse(baseUrl ?? const String.fromEnvironment(
         'SYNAPSE_API_BASE_URL',
         defaultValue: 'https://tcpq1i1oxl.execute-api.us-east-2.amazonaws.com',
       )),
       _storage = storage ?? const FlutterSecureStorage(
         aOptions: AndroidOptions(resetOnError: true),
         iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked_this_device),
       ),
       _clientFactory = clientFactory ?? HttpClient.new;

  final Uri baseUrl;
  final FlutterSecureStorage _storage;
  final HttpClient Function() _clientFactory;
  final _changes = StreamController<AppUser?>.broadcast();
  static const _storageKey = 'synapse.dynamo_auth.session.v1';

  AppUser? _currentUser;
  String? _token;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _changes.stream;

  @override
  Future<void> initialize() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final token = map['token'] as String?;
      final exp = map['exp'] as int?;
      if (token == null || exp == null) return;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      if (!expiry.isAfter(DateTime.now().toUtc().add(const Duration(seconds: 30)))) {
        await _storage.delete(key: _storageKey);
        return;
      }
      _token = token;
      _currentUser = AppUser(
        uid: map['sub'] as String,
        email: map['email'] as String?,
        displayName: map['name'] as String?,
        emailVerified: true,
      );
      _changes.add(_currentUser);
    } catch (_) {
      await _storage.delete(key: _storageKey);
    }
  }

  @override
  Future<AppUserCredential> register({
    required String name,
    required String email,
    required String password,
    required String career,
    required String gender,
  }) async {
    final payload = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'career': career.trim(),
      'gender': gender.trim(),
    };
    final response = await _postJson('/api/v1/auth/register', payload);
    return _applyAuthResponse(response, career: career, gender: gender);
  }

  @override
  Future<AppUserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password,
    };
    final response = await _postJson('/api/v1/auth/login', payload);
    return _applyAuthResponse(response);
  }

  @override
  Future<void> signOut() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: _storageKey);
    _changes.add(null);
  }

  @override
  Future<String?> accessToken({bool forceRefresh = false}) async => _token;

  @override
  Future<void> updateDisplayName(String name) async {
    if (_currentUser == null) return;
    _currentUser = AppUser(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: name.trim(),
      photoURL: _currentUser!.photoURL,
      emailVerified: true,
    );
    _changes.add(_currentUser);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Password reset endpoint placeholder
  }

  @override
  Future<void> deleteAccount() async {
    final client = _clientFactory();
    client.connectionTimeout = const Duration(seconds: 15);
    try {
      if (_token != null) {
        final request = await client.deleteUrl(baseUrl.resolve('/api/v1/auth/me'));
        request.headers.set('Authorization', 'Bearer $_token');
        final response = await request.close();
        final bytes = await response.fold<List<int>>([], (buf, chunk) => buf..addAll(chunk));
        if (response.statusCode != 200 && response.statusCode != 204) {
          final body = utf8.decode(bytes);
          throw CognitoAuthException('delete_failed', 'Failed to delete account: $body');
        }
      }
    } finally {
      client.close(force: true);
    }
    await signOut();
  }

  Future<AppUserCredential> _applyAuthResponse(
    Map<String, dynamic> body, {
    String? career,
    String? gender,
  }) async {
    final data = body['data'] as Map<String, dynamic>? ?? {};
    final token = data['token'] as String;
    final userMap = data['user'] as Map<String, dynamic>? ?? {};
    final sub = (userMap['sub'] ?? userMap['id'] ?? '') as String;
    final email = userMap['email'] as String?;
    final name = userMap['name'] as String?;
    final userCareer = (userMap['career'] as String?) ?? career ?? 'General Medicine';
    final userGender = (userMap['gender'] as String?) ?? gender ?? 'Male';

    final claims = _decodeJwtPayload(token);
    final exp = claims['exp'] is int ? claims['exp'] as int : (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400 * 7);

    _token = token;
    _currentUser = AppUser(
      uid: sub,
      email: email,
      displayName: name,
      emailVerified: true,
    );

    await _storage.write(
      key: _storageKey,
      value: jsonEncode({
        'token': token,
        'sub': sub,
        'email': email,
        'name': name,
        'career': userCareer,
        'gender': userGender,
        'exp': exp,
      }),
    );

    try {
      await UserLocalProfileService().saveProfile(
        uid: sub,
        name: name ?? '',
        email: email ?? '',
        career: userCareer,
        gender: userGender,
      );
    } catch (_) {}

    _changes.add(_currentUser);
    return AppUserCredential(_currentUser);
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return {};
      final normalized = base64Url.normalize(parts[1]);
      return jsonDecode(utf8.decode(base64Url.decode(normalized)))
          as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    final client = _clientFactory();
    client.connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.postUrl(baseUrl.resolve(path));
      request.headers.set('Content-Type', 'application/json');
      request.write(jsonEncode(body));
      final response = await request.close();
      final bytes = await response.fold<List<int>>([], (buf, chunk) => buf..addAll(chunk));
      final decoded = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) return decoded;
      final msg = decoded['message'] as String? ?? 'Authentication request failed.';
      if (response.statusCode == 409) throw CognitoAuthException('email_in_use', msg);
      if (response.statusCode == 401) throw CognitoAuthException('authentication_failed', msg);
      throw CognitoAuthException('service_unavailable', msg);
    } on CognitoAuthException {
      rethrow;
    } on SocketException {
      throw const CognitoAuthException('offline', 'Network error. Check connection.');
    } on TimeoutException {
      throw const CognitoAuthException('timeout', 'Connection timed out.');
    } catch (e) {
      throw CognitoAuthException('service_unavailable', e.toString());
    } finally {
      client.close(force: true);
    }
  }
}
