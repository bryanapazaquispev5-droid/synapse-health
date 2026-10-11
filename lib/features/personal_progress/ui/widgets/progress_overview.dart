import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/progress_summary.dart';

class ProgressOverview extends StatelessWidget {
  const ProgressOverview({super.key, required this.summary});
  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final singleColumn =
              MediaQuery.textScalerOf(context).scale(16) > 24 ||
              constraints.maxWidth < 300;
          final width = singleColumn
              ? constraints.maxWidth
              : (constraints.maxWidth - 12) / 2;
          final metrics = <(String, String)>[
            ('Estrellas actuales', '${summary.currentStars}'),
            ('Quizzes únicos respondidos', '${summary.uniqueQuizzes}'),
            (
              'Aciertos actuales',
              summary.accuracy == null
                  ? 'No disponible'
                  : '${summary.accuracy!.toStringAsFixed(1)} %',
            ),
            ('Intentos conservados', '${summary.retainedAttempts}'),
          ];
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: width,
                  child: ProgressMetricCard(label: metric.$1, value: metric.$2),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 12),
      Text(
        '${summary.currentCorrect} respuestas correctas de ${summary.currentAnswers} respuestas actuales.',
        style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
      const SizedBox(height: 8),
      const Text(
        'Las estrellas y los aciertos corresponden al intento actual. Quizzes e intentos cuentan los registros conservados y pueden no incluir toda tu práctica anterior.',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
      ),
    ],
  );
}

class ProgressMetricCard extends StatelessWidget {
  const ProgressMetricCard({
    super.key,
    required this.label,
    required this.value,
  });
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.primary),
        ),
      ],
    ),
  );
}
