import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/academic_history_entry.dart';
import 'history_catalog.dart';

String historyDate(DateTime? date) {
  if (date == null) return 'Fecha no disponible';
  final local = date.toLocal();
  String digits(int value) => value.toString().padLeft(2, '0');
  return '${digits(local.day)}/${digits(local.month)}/${local.year} '
      '${digits(local.hour)}:${digits(local.minute)}';
}

class HistoryEntryCard extends StatelessWidget {
  const HistoryEntryCard({
    super.key,
    required this.entry,
    required this.labels,
    required this.onTap,
  });
  final AcademicHistoryEntry entry;
  final HistoryLabels labels;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labels.quiz(entry),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${labels.area(entry)} · ${labels.topic(entry)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                Text(
                  'Intento ${entry.attemptNumber}',
                  style: const TextStyle(fontSize: 13, color: AppColors.accent),
                ),
                Text(
                  entry.isCorrect ? 'Correcta' : 'Incorrecta',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${entry.earnedStars} / ${entry.maxStars} estrellas',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              historyDate(entry.answeredAt),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    ),
  );
}
