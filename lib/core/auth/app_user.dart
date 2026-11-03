import 'app_auth.dart';

/// Provider-neutral identity; backend authorization always verifies the token.
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  bool get isAnonymous => false;

  Future<String?> getIdToken([bool forceRefresh = false]) =>
      AppAuth.instance.accessToken(forceRefresh: forceRefresh);
  Future<void> updateDisplayName(String name) =>
      AppAuth.instance.updateDisplayName(name);
  Future<void> sendEmailVerification() =>
      AppAuth.instance.requestEmailVerification();
  Future<bool> verifyEmail(String code) => AppAuth.instance.verifyEmail(code);
  Future<void> reload() => AppAuth.instance.reload();
  Future<void> delete() => AppAuth.instance.deleteAccount();
}

class AppUserCredential {
  const AppUserCredential(this.user);
  final AppUser? user;
}
