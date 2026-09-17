// ============================================================================
// Archivo: welcome_screen.dart
// Propósito: Pantalla de autenticación y flujo de acceso [welcome_screen] con soporte para credenciales y Google Sign-In.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/email_verification_banner.dart';
import 'widgets/welcome_profile_card.dart';

/// Pantalla principal de interfaz de usuario [WelcomeScreen].
class WelcomeScreen extends StatelessWidget {
  final User user;

  const WelcomeScreen({super.key, required this.user});

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    final bool isGoogleUser = user.providerData.any((info) => info.providerId == 'google.com');
    final bool isAnonymous = user.isAnonymous;
    final bool needsVerification = !isAnonymous && !isGoogleUser && !user.emailVerified;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(AppConstants.FIRESTORE_USERS).doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final String name = data['name'] ?? user.displayName ?? (isAnonymous ? 'Invitado Médico' : 'Estudiante');
            final String career = data['career'] ?? (isAnonymous ? 'Explorador Temporal' : 'Ciencias de la Salud');
            final int streak = data['studyStreakDays'] ?? 0;
            final String email = user.email ?? (isAnonymous ? 'Sin correo (Modo Invitado)' : 'Sin correo');

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  if (needsVerification) ...[
                    EmailVerificationBanner(user: user),
                    const SizedBox(height: 20),
                  ],
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset('assets/images/app_logo.jpg', fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '¡Felicidades, bienvenido!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tu entorno de estudio médico en Synapse Health',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  WelcomeProfileCard(
                    user: user,
                    name: name,
                    email: email,
                    career: career,
                    streak: streak,
                    isGoogleUser: isGoogleUser,
                    isAnonymous: isAnonymous,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: () async {
                        // Bloque: Ejecución protegida de operación asíncrona
                        try {
                          await GoogleSignIn().signOut();
                        } catch (_) {}
                        await FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.square_arrow_right, size: 18, color: AppColors.systemRed),
                            SizedBox(width: 8),
                            Text(
                              'Cerrar Sesión',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.systemRed),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
