// ============================================================================
// Archivo: auth_mode_selector.dart
// Propósito: Widget visual modular [auth_mode_selector] para el flujo y los formularios de inicio de sesión y registro.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

/// Componente de interfaz de usuario reutilizable [AuthModeSelector].
class AuthModeSelector extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onModeChanged;

  const AuthModeSelector({
    super.key,
    required this.isLogin,
    required this.onModeChanged,
  });

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<bool>(
        groupValue: isLogin,
        backgroundColor: const Color(0xFFE5E5EA),
        thumbColor: AppColors.surface,
        padding: const EdgeInsets.all(3),
        children: const {
          true: Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          false: Padding(
            padding: EdgeInsets.symmetric(vertical: 9),
            child: Text(
              'Registrarse',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
          ),
        },
        onValueChanged: (val) {
          if (val != null) onModeChanged(val);
        },
      ),
    );
  }
}
