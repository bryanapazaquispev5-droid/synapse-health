import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/progress_summary.dart';

/// Tarjeta atómica para visualizar la evolución histórica de un tema en quizzes.
class TopicEvolutionCard extends StatelessWidget {
  const TopicEvolutionCard({
    super.key,
    required this.series,
    required this.areaName,
    required this.topicName,
  });

  final TopicEvolution series;
  final String areaName;
  final String topicName;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
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
              topicName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              areaName,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            for (final point in series.points)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Semantics(
                  label:
                      'Intento ${point.attemptNumber}, ${point.accuracy.toStringAsFixed(1)} por ciento de aciertos, ${point.correct} respuestas correctas de ${point.answered}. Última respuesta ${_formatDate(point.lastAnsweredAt)}.',
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intento ${point.attemptNumber} · ${point.accuracy.toStringAsFixed(1)} %',
                        ),
                        const SizedBox(height: 6),
                        LayoutBuilder(
                          builder: (context, constraints) => Container(
                            width: constraints.maxWidth,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: constraints.maxWidth *
                                  point.accuracy.clamp(0, 100) /
                                  100,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Última respuesta: ${_formatDate(point.lastAnsweredAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
