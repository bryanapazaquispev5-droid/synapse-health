import 'app_user.dart';

/// Abstract contract for authentication providers (DynamoDB Native, Cognito, etc.).
abstract interface class AuthBackend {
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;

  Future<void> initialize();

  Future<AppUserCredential> signIn({
    required String email,
    required String password,
  });

  Future<AppUserCredential> register({
    required String name,
    required String email,
    required String password,
    required String career,
    required String gender,
  });

  Future<void> signOut();

  Future<String?> accessToken({bool forceRefresh = false});

  Future<void> updateDisplayName(String name);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> deleteAccount();
}
