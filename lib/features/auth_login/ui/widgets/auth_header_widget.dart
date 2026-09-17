// ============================================================================
// Archivo: auth_header_widget.dart
// Propósito: Widget visual de soporte [auth_header_widget] para el formulario y flujo de inicio de sesion.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Componente visual modular [AuthHeaderWidget]
class AuthHeaderWidget extends StatelessWidget {
  final bool isLogin;

  const AuthHeaderWidget({super.key, required this.isLogin});

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 78,
            height: 78,
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
        Text(
          isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isLogin
              ? 'Accede a tus chuletas y quizzes médicos'
              : 'Únete para registrar tu racha y progreso',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
