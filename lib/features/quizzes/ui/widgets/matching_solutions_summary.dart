// ============================================================================
// Archivo: matching_solutions_summary.dart
// Propósito: Componente interactivo [matching_solutions_summary] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/matching_pair_model.dart';

// Definicion principal de la clase [MatchingSolutionsSummary]
class MatchingSolutionsSummary extends StatelessWidget {
  final List<String> leftItems;
  final List<String> rightItems;
  final List<MatchingPair> originalPairs;
  final Map<int, int> userPairings;

  const MatchingSolutionsSummary({
    super.key,
    required this.leftItems,
    required this.rightItems,
    required this.originalPairs,
    required this.userPairings,
  });

  String _getCorrectRightTextForLeft(int leftIndex) {
    final leftText = leftItems[leftIndex];
    final pair = originalPairs.firstWhere(
      (p) => p.left == leftText,
      orElse: () => const MatchingPair(left: '', right: ''),
    );
    return pair.right;
  }

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(CupertinoIcons.checkmark_shield_fill, size: 16, color: AppColors.accent),
              SizedBox(width: 6),
              Text(
                'Relaciones Correctas del Rouvière',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(leftItems.length, (i) {
            final left = leftItems[i];
            final correctRight = _getCorrectRightTextForLeft(i);
            final userRightIdx = userPairings[i];
            final isCorrect = userRightIdx != null &&
                userRightIdx < rightItems.length &&
                rightItems[userRightIdx] == correctRight;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isCorrect ? CupertinoIcons.check_mark : CupertinoIcons.xmark,
                    size: 13,
                    color: isCorrect ? AppColors.systemGreen : AppColors.systemRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, height: 1.3),
                        children: [
                          TextSpan(
                            text: '$left: ',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: correctRight,
                            style: TextStyle(
                              color: isCorrect ? AppColors.systemGreen : const Color(0xFF1E293B),
                              fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
