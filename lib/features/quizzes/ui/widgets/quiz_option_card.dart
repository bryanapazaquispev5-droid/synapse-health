// ============================================================================
// Archivo: quiz_option_card.dart
// Propósito: Componente interactivo [quiz_option_card] para la resolución táctil de preguntas médicas.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Componente de interfaz de usuario reutilizable [QuizOptionCard].
class QuizOptionCard extends StatelessWidget {
  final int index;
  final String letter;
  final String text;
  final int correctIndex;
  final int? selectedOptionIndex;
  final bool isAnswered;
  final ValueChanged<int> onSelected;

  const QuizOptionCard({
    super.key,
    required this.index,
    required this.letter,
    required this.text,
    required this.correctIndex,
    required this.selectedOptionIndex,
    required this.isAnswered,
    required this.onSelected,
  });

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    Color cardBg = AppColors.surface;
    Color borderColor = AppColors.border;
    Color letterBg = const Color(0xFFF2F2F7);
    Color letterColor = AppColors.primary;
    Widget? trailingIcon;

    if (isAnswered) {
      if (index == correctIndex) {
        cardBg = const Color(0xFFE8F5E9);
        borderColor = AppColors.systemGreen;
        letterBg = AppColors.systemGreen;
        letterColor = Colors.white;
        trailingIcon = const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.systemGreen, size: 22);
      } else if (index == selectedOptionIndex) {
        cardBg = const Color(0xFFFFEBEE);
        borderColor = AppColors.systemRed;
        letterBg = AppColors.systemRed;
        letterColor = Colors.white;
        trailingIcon = const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.systemRed, size: 22);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelected(index),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: letterColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
