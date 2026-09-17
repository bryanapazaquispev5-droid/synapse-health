// ============================================================================
// Archivo: auth_oauth_helper.dart
// Propósito: Servicio de autenticacion con Firebase Auth, control de sesiones y llamadas a la API de seguridad.
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/user_local_profile_service.dart';
import '../ui/complete_profile_screen.dart';
import 'auth_service.dart';

// Definicion principal de la clase [AuthOAuthHelper]
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
        // Bloque: Navegación y transición fluida hacia la siguiente pantalla
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
