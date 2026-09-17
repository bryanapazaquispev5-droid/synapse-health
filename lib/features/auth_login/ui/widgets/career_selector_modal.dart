// ============================================================================
// Archivo: career_selector_modal.dart
// Propósito: Widget visual de soporte [career_selector_modal] para el formulario y flujo de inicio de sesion.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

// Definicion principal de la clase [CareerSelectorModal]
class CareerSelectorModal {
  static void show({
    required BuildContext context,
    required List<String> careers,
    required ValueChanged<String> onSelected,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return CupertinoActionSheet(
          title: const Text(
            'Selecciona tu Carrera o Especialidad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          message: const Text(
            'Esto personalizará tu plan de estudio y banco de preguntas.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          actions: careers.map((career) {
            return CupertinoActionSheetAction(
              onPressed: () {
                onSelected(career);
                Navigator.pop(sheetContext);
              },
              child: Text(
                career,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(sheetContext),
            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }
}
