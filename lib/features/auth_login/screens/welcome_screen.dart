import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  final User user;

  const WelcomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isGoogleUser = user.providerData.any(
      (info) => info.providerId == 'google.com',
    );
    final bool isAnonymous = user.isAnonymous;
    final bool needsVerification = !isAnonymous && !isGoogleUser && !user.emailVerified;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection(AppConstants.firestoreUsers).doc(user.uid).snapshots(),
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

                  // Banner de Verificacion de Correo si aplica
                  if (needsVerification) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.mail_solid, color: Color(0xFFD97706), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Verifica tu correo electrónico',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Revisa tu bandeja de entrada para activar todas las funciones.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                                ),
                              ],
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            onPressed: () async {
                              await user.sendEmailVerification();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Correo de verificación reenviado.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Reenviar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Logo de la aplicacion
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
                        child: Image.asset(
                          'assets/images/app_logo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Titulo
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
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tarjeta con Datos del Usuario (Apple Inset Card)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        user.photoURL != null
                            ? CircleAvatar(
                                radius: 36,
                                backgroundImage: NetworkImage(user.photoURL!),
                                backgroundColor: AppColors.border,
                              )
                            : CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 14),

                        // Nombre
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Correo
                        Text(
                          email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Divider(color: AppColors.border, height: 1),
                        const SizedBox(height: 16),

                        // Datos de Firestore: Carrera y Racha
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                icon: CupertinoIcons.book,
                                label: 'Especialidad',
                                value: career,
                              ),
                            ),
                            Container(width: 1, height: 36, color: AppColors.border),
                            Expanded(
                              child: _buildInfoItem(
                                icon: CupertinoIcons.flame_fill,
                                label: 'Racha de Estudio',
                                value: '$streak días',
                                isHighlight: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Badge de metodo de autenticacion
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGoogleUser
                                    ? Icons.g_mobiledata_rounded
                                    : isAnonymous
                                        ? CupertinoIcons.person
                                        : CupertinoIcons.mail,
                                size: 18,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isGoogleUser
                                    ? 'Google Sign-In'
                                    : isAnonymous
                                        ? 'Modo Invitado Activo'
                                        : 'Correo Verificable',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Boton de Cerrar Sesion en estilo iOS
                  SizedBox(
                    height: 50,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: () async {
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(CupertinoIcons.square_arrow_right, size: 18, color: AppColors.systemRed),
                            SizedBox(width: 8),
                            Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.systemRed,
                              ),
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

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlight ? AppColors.systemOrange : AppColors.accent,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlight ? AppColors.systemOrange : AppColors.primary,
          ),
        ),
      ],
    );
  }
}