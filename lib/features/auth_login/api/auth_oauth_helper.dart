import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../ui/complete_profile_screen.dart';
import 'auth_service.dart';

class AuthOAuthHelper {
  static Future<void> syncGoogleUserAndNavigate({
    required BuildContext context,
    required AuthService authService,
    required User user,
  }) async {
    final doc = await authService.firestore.collection(AppConstants.FIRESTORE_USERS).doc(user.uid).get();
    final data = doc.data();
    final String? career = data?['career'];

    if (career == null || career.trim().isEmpty) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompleteProfileScreen(user: user)),
        );
      }
    } else {
      await UserLocalProfileService().saveProfile(
        uid: user.uid,
        name: data?['name'] ?? user.displayName ?? '',
        email: data?['email'] ?? user.email ?? '',
        career: career,
        gender: data?['gender'] ?? 'Hombre',
        photoUrl: user.photoURL,
      );
    }
  }
}
