// ============================================================================
// Archivo: ordering_reorderable_card.dart
// Propósito: Componente interactivo [ordering_reorderable_card] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Componente visual modular [OrderingReorderableCard]
class OrderingReorderableCard extends StatelessWidget {
  final String item;
  final int index;
  final int totalItems;
  final bool isSubmitted;
  final bool isCorrectPosition;
  final bool isIncorrectPosition;
  final Function(int index, int delta) onMoveItem;

  const OrderingReorderableCard({
    super.key,
    required this.item,
    required this.index,
    required this.totalItems,
    required this.isSubmitted,
    required this.isCorrectPosition,
    required this.isIncorrectPosition,
    required this.onMoveItem,
  });

  // Renderizado reactivo del arbol de widgets
  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surface;
    Color borderColor = AppColors.border;
    Color badgeBg = const Color(0xFFF2F2F7);
    Color badgeTextColor = AppColors.primary;
    double borderWidth = 1.0;

    if (isCorrectPosition) {
      bg = const Color(0xFFF0FDF4);
      borderColor = AppColors.systemGreen;
      badgeBg = AppColors.systemGreen;
      badgeTextColor = Colors.white;
      borderWidth = 1.6;
    } else if (isIncorrectPosition) {
      bg = const Color(0xFFFEF2F2);
      borderColor = AppColors.systemRed;
      badgeBg = AppColors.systemRed;
      badgeTextColor = Colors.white;
      borderWidth = 1.6;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: isCorrectPosition
                  ? const Icon(CupertinoIcons.checkmark, color: Colors.white, size: 16)
                  : isIncorrectPosition
                      ? const Icon(CupertinoIcons.xmark, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: badgeTextColor,
                          ),
                        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.35,
                ),
              ),
            ),
            if (!isSubmitted) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0)
                    GestureDetector(
                      onTap: () => onMoveItem(index, -1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Icon(CupertinoIcons.chevron_up, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                  if (index < totalItems - 1)
                    GestureDetector(
                      onTap: () => onMoveItem(index, 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Icon(CupertinoIcons.chevron_down, size: 16, color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.bars,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
