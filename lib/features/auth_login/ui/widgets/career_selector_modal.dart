// ============================================================================
// File: career_selector_modal.dart
// Purpose: Supporting visual widget [career_selector_modal] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';

// Main definition of class [CareerSelectorModal]
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
            'Select your degree or specialty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          message: const Text(
            'This will personalize your study plan and question bank.',
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
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }
}
