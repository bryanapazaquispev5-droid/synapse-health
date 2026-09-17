// ============================================================================
// Archivo: matching_left_card.dart
// Propósito: Componente interactivo [matching_left_card] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Componente visual modular [MatchingLeftCard]
class MatchingLeftCard extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final bool isPaired;
  final int? pairNumber;
  final Color pairColor;
  final bool isCorrect;
  final bool isIncorrect;
  final VoidCallback onTap;

  const MatchingLeftCard({
    super.key,
    required this.index,
    required this.text,
    required this.isSelected,
    required this.isPaired,
    required this.pairNumber,
    required this.pairColor,
    required this.isCorrect,
    required this.isIncorrect,
    required this.onTap,
  });

  // Renderizado reactivo del arbol de widgets
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
    } else if (isSelected) {
      bg = AppColors.accent.withValues(alpha: 0.08);
      borderColor = AppColors.accent;
      borderWidth = 2.0;
    } else if (isPaired) {
      bg = pairColor.withValues(alpha: 0.05);
      borderColor = pairColor;
      borderWidth = 1.5;
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
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isPaired ? pairColor : const Color(0xFFE5E5EA),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPaired ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
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
                  else if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Toca pareja',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
