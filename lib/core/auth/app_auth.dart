import '../../features/auth_login/cognito/api/cognito_auth_service.dart';
import '../../features/auth_login/cognito/model/cognito_auth_exception.dart';
import '../../features/auth_login/cognito/model/cognito_config.dart';
import '../../features/auth_login/cognito/model/cognito_session.dart';
import 'app_user.dart';
import 'cognito_account_api.dart';

export 'app_user.dart';
export '../../features/auth_login/cognito/api/cognito_auth_service.dart'
    show CognitoRegistration;
export '../../features/auth_login/cognito/model/cognito_auth_exception.dart'
    show CognitoAuthException;

typedef AppAuthException = CognitoAuthException;

/// Cognito owns email/password sessions; no AWS credentials reach the app.
class AppAuth {
  AppAuth({CognitoAuthService? service})
    : service =
          service ??
          CognitoAuthService(config: CognitoConfig.fromEnvironment());
  static final AppAuth instance = AppAuth();
  final CognitoAuthService service;
  String? _displayName;

  AppUser? get currentUser => _user(service.currentSession);
  Stream<AppUser?> authStateChanges() async* {
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
    await service.signIn(email: email.trim().toLowerCase(), password: password);
    return AppUserCredential(currentUser);
  }

  Future<void> signOut() async {
    _displayName = null;
    await service.signOut();
  }

  Future<String?> accessToken({bool forceRefresh = false}) async =>
      (await service.validSession(forceRefresh: forceRefresh))?.accessToken;

  Future<void> updateDisplayName(String name) async {
    await CognitoAccountApi(service).updateName(name);
    _displayName = name.trim();
  }

  Future<void> reload() async {
    await service.validSession(forceRefresh: true);
  }

  Future<void> resendConfirmation(String email) =>
      service.resendConfirmation(email);
  Future<void> requestEmailVerification() =>
      CognitoAccountApi(service).requestEmailVerification();
  Future<bool> verifyEmail(String code) =>
      CognitoAccountApi(service).verifyEmail(code);
  Future<bool> refreshEmailVerificationStatus() async {
    await service.refreshUserAttributes();
    return service.currentSession?.emailVerified ?? false;
  }

  Future<void> sendPasswordResetEmail({required String email}) =>
      service.forgotPassword(email.trim().toLowerCase());

  Future<void> deleteAccount() async {
    await CognitoAccountApi(service).deleteAccount();
    await signOut();
  }
}
