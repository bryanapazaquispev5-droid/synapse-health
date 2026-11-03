import '../../../core/auth/app_auth.dart';
import '../../../core/api/own_profile_repository.dart';
import '../../../core/services/user_local_profile_service.dart';

/// App-facing authentication backed exclusively by Cognito.
class AuthService {
  AuthService({AppAuth? auth, OwnProfileRepository? profiles})
    : _auth = auth ?? AppAuth.instance,
      profiles = profiles ?? OwnProfileRepository();
  final AppAuth _auth;
  final OwnProfileRepository profiles;
  AppAuth get auth => _auth;

  Future<AppUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      try {
        final data = await profiles.fetch(user.uid);
        await UserLocalProfileService().saveProfile(
          uid: user.uid,
          name: data['name'] as String? ?? user.displayName ?? '',
          email: user.email ?? '',
          career: data['career'] as String? ?? '',
          gender: data['gender'] as String? ?? '',
          photoUrl: user.photoURL,
        );
      } catch (_) {
        /* Profile loading is retried by the authenticated session gate. */
      }
    }
    return credential;
  }

  Future<void> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String career,
    required String gender,
    required String password,
  }) => _auth.service.register(
    email: email.trim().toLowerCase(),
    password: password,
    name: name,
  );

  Future<void> confirmRegistration(String email, String code) =>
      _auth.service.confirmRegistration(email: email, code: code);
  Future<void> resendConfirmation(String email) =>
      _auth.resendConfirmation(email);
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);
  Future<void> confirmPasswordReset(
    String email,
    String code,
    String password,
  ) => _auth.service.confirmPasswordReset(
    email: email,
    code: code,
    newPassword: password,
  );

  /// Cancelling onboarding signs out; existing accounts and data stay intact.
  Future<void> cancelAndRollbackAccount(AppUser user) => _auth.signOut();
}
