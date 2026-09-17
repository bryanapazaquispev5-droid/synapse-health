// ============================================================================
// Archivo: auth_action_buttons.dart
// Propósito: Widget visual modular [auth_action_buttons] para el flujo y los formularios de inicio de sesión y registro.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import 'google_logo_icon.dart';

/// Componente de interfaz de usuario reutilizable [AuthActionButtons].
class AuthActionButtons extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final bool isLockoutActive;
  final int lockoutSeconds;
  final VoidCallback onSubmitEmailAuth;
  final VoidCallback onGoogleSignIn;
  final VoidCallback? onGuestSignIn;

  const AuthActionButtons({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.isLockoutActive,
    required this.lockoutSeconds,
    required this.onSubmitEmailAuth,
    required this.onGoogleSignIn,
    this.onGuestSignIn,
  });

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 50,
          child: CupertinoButton.filled(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(14),
            onPressed: (isLoading || isLockoutActive) ? null : onSubmitEmailAuth,
            child: isLoading
                ? const CupertinoActivityIndicator(color: AppColors.surface)
                : isLockoutActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.lock_fill, size: 18, color: AppColors.surface),
                          const SizedBox(width: 8),
                          Text(
                            'Bloqueado ($lockoutSeconds s)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.surface,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLogin ? 'Iniciar Sesión' : 'Crear Cuenta Médica',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.surface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(CupertinoIcons.arrow_right, size: 16, color: AppColors.surface),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 52,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            pressedOpacity: 0.6,
            onPressed: isLoading ? null : onGoogleSignIn,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  GoogleLogoIcon(size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Continuar con Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onGuestSignIn != null) ...[
          const SizedBox(height: 18),
          Center(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: isLoading ? null : onGuestSignIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.person_crop_circle, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Continuar como Invitado (Modo Prueba)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
