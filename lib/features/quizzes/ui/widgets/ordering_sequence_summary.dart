import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OrderingSequenceSummary extends StatelessWidget {
  final List<String> correctSequence;
  final List<String> currentItems;

  const OrderingSequenceSummary({
    super.key,
    required this.correctSequence,
    required this.currentItems,
  });

  bool _areListsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllCorrect = _areListsEqual(currentItems, correctSequence);

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
            children: [
              Icon(
                isAllCorrect ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.compass_fill,
                size: 16,
                color: isAllCorrect ? AppColors.systemGreen : AppColors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                isAllCorrect ? '¡Secuencia Exacta!' : 'Secuencia Anatómica Canónica',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isAllCorrect ? AppColors.systemGreen : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(correctSequence.length, (i) {
            final correctItem = correctSequence[i];
            final userItem = i < currentItems.length ? currentItems[i] : '';
            final isMatch = userItem == correctItem;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isMatch ? AppColors.systemGreen : const Color(0xFFE5E5EA),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isMatch ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correctItem,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isMatch ? FontWeight.w700 : FontWeight.w500,
                        color: isMatch ? AppColors.systemGreen : AppColors.primary,
                        height: 1.3,
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
