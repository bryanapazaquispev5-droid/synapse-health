import '../../features/auth_login/cognito/api/cognito_auth_service.dart';
import '../../features/auth_login/cognito/model/cognito_auth_exception.dart';
import '../../features/auth_login/cognito/model/cognito_config.dart';
import '../../features/auth_login/cognito/model/cognito_session.dart';
import 'app_user.dart';
import 'auth_backend.dart';
import 'cognito_account_api.dart';
import 'dynamo_auth_service.dart';

export 'app_user.dart';
export 'auth_backend.dart';
export 'dynamo_auth_service.dart';
export '../../features/auth_login/cognito/api/cognito_auth_service.dart'
    show CognitoRegistration;
export '../../features/auth_login/cognito/model/cognito_auth_exception.dart'
    show CognitoAuthException;

typedef AppAuthException = CognitoAuthException;

/// Manages student authentication, sessions and tokens across DynamoDB and AWS.
class AppAuth {
  AppAuth({CognitoAuthService? service, AuthBackend? backend})
    : service =
          service ??
          CognitoAuthService(config: CognitoConfig.fromEnvironment()),
      backend = backend ?? (service == null ? DynamoAuthService() : null);

  static final AppAuth instance = AppAuth();
  final CognitoAuthService service;
  final AuthBackend? backend;
  String? _displayName;

  AppUser? get currentUser =>
      backend?.currentUser ?? _user(service.currentSession);

  Stream<AppUser?> authStateChanges() async* {
    if (backend != null) {
      yield backend!.currentUser;
      yield* backend!.authStateChanges;
      return;
    }
    yield currentUser;
    yield* service.sessionChanges.map(_user);
  }

  AppUser? _user(CognitoSession? session) => session == null
      ? null
      : AppUser(
          uid: session.sub,
          email: session.email,
          displayName: _displayName ?? session.name,
          photoURL: session.picture,
          emailVerified: session.emailVerified,
        );

  Future<void> initialize() async {
    if (backend != null) {
      await backend!.initialize();
      return;
    }
    if (!service.config.isValid) return;
    try {
      await service.restoreSession();
    } on CognitoAuthException catch (error) {
      if (!{'offline', 'timeout', 'service_unavailable'}.contains(error.code)) {
        rethrow;
      }
    }
  }

  Future<AppUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _displayName = null;
    if (backend != null) {
      return backend!.signIn(
        email: email.trim().toLowerCase(),
        password: password,
      );
    }
    await service.signIn(email: email.trim().toLowerCase(), password: password);
    return AppUserCredential(currentUser);
  }

  Future<void> signOut() async {
    _displayName = null;
    if (backend != null) {
      await backend!.signOut();
      return;
    }
    await service.signOut();
  }

  Future<String?> accessToken({bool forceRefresh = false}) async {
    if (backend != null) {
      return backend!.accessToken(forceRefresh: forceRefresh);
    }
    return (await service.validSession(forceRefresh: forceRefresh))?.accessToken;
  }

  Future<void> updateDisplayName(String name) async {
    if (backend != null) {
      await backend!.updateDisplayName(name);
      return;
    }
    await CognitoAccountApi(service).updateName(name);
    _displayName = name.trim();
  }

  Future<void> reload() async {
    if (backend != null) return;
    await service.validSession(forceRefresh: true);
  }

  Future<void> resendConfirmation(String email) =>
      service.resendConfirmation(email);

  Future<void> requestEmailVerification() =>
      CognitoAccountApi(service).requestEmailVerification();

  Future<bool> verifyEmail(String code) =>
      CognitoAccountApi(service).verifyEmail(code);

  Future<bool> refreshEmailVerificationStatus() async {
    if (backend != null) return true;
    await service.refreshUserAttributes();
    return service.currentSession?.emailVerified ?? false;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    if (backend != null) {
      await backend!.sendPasswordResetEmail(email);
      return;
    }
    await service.forgotPassword(email.trim().toLowerCase());
  }

  Future<void> deleteAccount() async {
    if (backend != null) {
      await backend!.deleteAccount();
      return;
    }
    await CognitoAccountApi(service).deleteAccount();
    await signOut();
  }
}
