import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';

import '../../model/progress_summary.dart';
import 'progress_accuracy_card.dart';
import 'progress_appearance.dart';

class ProgressOverview extends StatelessWidget {
  const ProgressOverview({super.key, required this.summary});
  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressAccuracyCard(
          accuracy: summary.accuracy,
          correct: summary.currentCorrect,
          answers: summary.currentAnswers,
        ),
        const SizedBox(height: 18),
        const _MetricRule(),
        const SizedBox(height: 12),
        _OverviewMetrics(summary: summary),
        const SizedBox(height: 12),
        const _MetricRule(),
      ],
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({required this.summary});
  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columnWidth = MediaQuery.textScalerOf(context).scale(95);
      final columns = (constraints.maxWidth ~/ columnWidth).clamp(1, 3);
      final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
      return Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          SizedBox(
            width: width,
            child: _ProgressMetric(
              icon: CupertinoIcons.star,
              label: 'Estrellas actuales',
              value: summary.currentStars,
            ),
          ),
          SizedBox(
            width: width,
            child: _ProgressMetric(
              icon: CupertinoIcons.checkmark_circle,
              label: 'Quizzes únicos',
              value: summary.uniqueQuizzes,
            ),
          ),
          SizedBox(
            width: width,
            child: _ProgressMetric(
              icon: CupertinoIcons.clock,
              label: 'Intentos guardados',
              value: summary.retainedAttempts,
            ),
          ),
        ],
      );
    },
  );
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [
          Icon(icon, size: 16, color: ProgressAppearance.accent),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 23,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: ProgressAppearance.ink,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          height: 1.15,
          color: ProgressAppearance.muted,
        ),
      ),
    ],
  );
}

class _MetricRule extends StatelessWidget {
  const _MetricRule();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: double.infinity,
    height: 1,
    child: ColoredBox(color: ProgressAppearance.rule),
  );
}
