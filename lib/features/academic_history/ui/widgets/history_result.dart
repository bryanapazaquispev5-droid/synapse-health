import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/academic_history_entry.dart';
import 'history_catalog.dart';
import 'history_entry_card.dart';

class HistoryResult extends StatelessWidget {
  const HistoryResult({super.key, required this.entry, required this.labels});
  final AcademicHistoryEntry entry;
  final HistoryLabels labels;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labels.quiz(entry),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${labels.area(entry)} · ${labels.topic(entry)}',
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            _field('Resultado', entry.isCorrect ? 'Correcta' : 'Incorrecta'),
            _field(
              'Estrellas obtenidas',
              '${entry.earnedStars} / ${entry.maxStars}',
            ),
            _field('Intento', '${entry.attemptNumber}'),
            _field('Fecha', historyDate(entry.answeredAt)),
            _field(
              'Tiempo',
              entry.durationSeconds == null
                  ? 'No registrado'
                  : '${entry.durationSeconds} s',
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Se conservan el intento actual y hasta tres anteriores.',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
    ],
  );
  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}
