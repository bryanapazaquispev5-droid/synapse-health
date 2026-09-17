// ============================================================================
// Archivo: profile_sign_out_button.dart
// Propósito: Componente de interfaz modular [profile_sign_out_button] para la visualizacion de datos de usuario y ajustes.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Definicion principal de la clase [ProfileSignOutButton]
class ProfileSignOutButton extends StatelessWidget {
  final VoidCallback onSignOut;

  const ProfileSignOutButton({super.key, required this.onSignOut});

  // Renderizado reactivo del arbol de widgets
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 28, bottom: 100),
      child: GestureDetector(
        onTap: onSignOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.6),
          ),
          child: const Center(
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.systemRed,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
