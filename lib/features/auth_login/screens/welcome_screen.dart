import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final String name = data['name'] ?? user.displayName ?? (isAnonymous ? 'Invitado Médico' : 'Estudiante');
            final String career = data['career'] ?? (isAnonymous ? 'Explorador Temporal' : 'Ciencias de la Salud');
            final int streak = data['studyStreakDays'] ?? 0;
            final String email = user.email ?? (isAnonymous ? 'Sin correo (Modo Invitado)' : 'Sin correo');

            return SingleChildScrollView(
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_unread_outlined, color: Color(0xFFD97706), size: 24),
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
                          TextButton(
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
                      width: 80,
                      height: 80,
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
                  const SizedBox(height: 20),

                  // Titulo
                  const Text(
                    '¡Felicidades, bienvenido!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
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

                  // Tarjeta con Datos del Usuario y Firestore
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
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
                                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 26,
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
                              child: _infoItem(
                                icon: Icons.school_outlined,
                                label: 'Especialidad',
                                value: career,
                              ),
                            ),
                            Container(width: 1, height: 36, color: AppColors.border),
                            Expanded(
                              child: _infoItem(
                                icon: Icons.local_fire_department_rounded,
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
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGoogleUser
                                    ? Icons.g_mobiledata_rounded
                                    : isAnonymous
                                        ? Icons.visibility_outlined
                                        : Icons.mail_outline_rounded,
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

                  const SizedBox(height: 32),

                  // Boton de Cerrar Sesion en pildora ergonómica One UI
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await GoogleSignIn().signOut();
                        } catch (_) {}
                        await FirebaseAuth.instance.signOut();
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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

  Widget _infoItem({
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
          color: isHighlight ? const Color(0xFFF59E0B) : AppColors.accent,
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
            color: isHighlight ? const Color(0xFFD97706) : AppColors.primary,
          ),
        ),
      ],
    );
  }
}