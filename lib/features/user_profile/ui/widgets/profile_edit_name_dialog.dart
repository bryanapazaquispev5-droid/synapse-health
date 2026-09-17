// ============================================================================
// Archivo: profile_edit_name_dialog.dart
// Propósito: Componente de interfaz modular [profile_edit_name_dialog] para la visualizacion de datos de usuario y ajustes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

// Componente visual modular [ProfileEditNameDialog]
class ProfileEditNameDialog {
  static Future<void> show({
    required BuildContext context,
    required String currentName,
    required Future<void> Function(String newName) onSave,
  }) {
    final controller = TextEditingController(text: currentName);

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x33000000),
      transitionDuration: const Duration(milliseconds: 520),
      pageBuilder: (context, animation, secondaryAnimation) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        final offsetY = bottomInset > 0 ? 100.0 : 0.0;
        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Opacity(
            opacity: 0.90,
            child: CupertinoAlertDialog(
              title: const Text(
                'Editar Nombre',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.4),
              ),
              content: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ingresa tu nombre y apellidos para tu credencial médica:',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: controller,
                      autofocus: false,
                      textCapitalization: TextCapitalization.words,
                      placeholder: 'Nombre y Apellidos',
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: const Color(0xFFD1D1D6), width: 0.8),
                      ),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
                CupertinoDialogAction(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isEmpty) return;
                    Navigator.pop(context);
                    await onSave(newName);
                  },
                  child: const Text('Guardar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );
      },
    );
  }
}
