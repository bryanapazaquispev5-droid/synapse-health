// ============================================================================
// Archivo: profile_gender_sheet.dart
// Propósito: Componente de interfaz modular [profile_gender_sheet] para la visualizacion de datos de usuario y ajustes.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import 'opaque_action_sheet.dart';

// Componente visual modular [ProfileGenderSheet]
class ProfileGenderSheet {
  static void show({
    required BuildContext context,
    required String currentGender,
    required ValueChanged<String> onSelectGender,
  }) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x5A000000),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return OpaqueActionSheet(
          title: const Text(
            'Seleccionar Género',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
          message: const Text(
            'Elige tu avatar de estudiante de salud:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              fontWeight: FontWeight.normal,
              color: AppColors.textMuted,
              decoration: TextDecoration.none,
            ),
          ),
          actions: [
            OpaqueActionSheetActionItem(
              onPressed: () {
                Navigator.pop(context);
                onSelectGender('Hombre');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.person_fill, color: AppColors.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Hombre',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      fontWeight: currentGender == 'Hombre' ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.accent,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            OpaqueActionSheetActionItem(
              onPressed: () {
                Navigator.pop(context);
                onSelectGender('Mujer');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.person_crop_circle_fill, color: AppColors.systemPink, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Mujer',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      fontWeight: currentGender == 'Mujer' ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.systemPink,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curvedAnimation),
          child: Align(alignment: Alignment.bottomCenter, child: child),
        );
      },
    );
  }
}
