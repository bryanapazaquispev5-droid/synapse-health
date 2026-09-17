// ============================================================================
// Archivo: matching_right_card.dart
// Propósito: Componente interactivo [matching_right_card] para la resolución táctil de preguntas médicas.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Componente de interfaz de usuario reutilizable [MatchingRightCard].
class MatchingRightCard extends StatelessWidget {
  final int rightIndex;
  final String text;
  final bool isPaired;
  final int? pairNumber;
  final Color pairColor;
  final bool isTargetOfSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final bool isIncorrect;
  final VoidCallback onTap;

  const MatchingRightCard({
    super.key,
    required this.rightIndex,
    required this.text,
    required this.isPaired,
    required this.pairNumber,
    required this.pairColor,
    required this.isTargetOfSelected,
    required this.isSubmitted,
    required this.isCorrect,
    required this.isIncorrect,
    required this.onTap,
  });

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surface;
    Color borderColor = AppColors.border;
    double borderWidth = 1.0;

    if (isCorrect) {
      bg = const Color(0xFFF0FDF4);
      borderColor = AppColors.systemGreen;
      borderWidth = 1.6;
    } else if (isIncorrect) {
      bg = const Color(0xFFFEF2F2);
      borderColor = AppColors.systemRed;
      borderWidth = 1.6;
    } else if (isPaired) {
      bg = pairColor.withValues(alpha: 0.05);
      borderColor = pairColor;
      borderWidth = 1.5;
    } else if (isTargetOfSelected) {
      bg = const Color(0xFFF8FAFC);
      borderColor = AppColors.accent.withValues(alpha: 0.4);
      borderWidth = 1.2;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isCorrect)
                    const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.systemGreen, size: 18)
                  else if (isIncorrect)
                    const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.systemRed, size: 18)
                  else if (isPaired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: pairColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Par $pairNumber',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: pairColor,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isPaired ? pairColor : Colors.transparent,
                      border: Border.all(
                        color: isPaired ? pairColor : AppColors.border,
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
