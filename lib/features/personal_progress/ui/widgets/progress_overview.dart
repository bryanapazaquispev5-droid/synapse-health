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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCFE6F1)),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFDEF2FA), Color(0xFFFBFDFE)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressAccuracyCard(
              accuracy: summary.accuracy,
              correct: summary.currentCorrect,
              answers: summary.currentAnswers,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 1,
                child: ColoredBox(color: ProgressAppearance.rule),
              ),
            ),
            _OverviewMetrics(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  const _OverviewMetrics({required this.summary});
  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columnWidth = MediaQuery.textScalerOf(context).scale(82);
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
              tint: const Color(0xFFFCECCB),
              color: const Color(0xFF855409),
              label: 'Estrellas actuales',
              value: summary.currentStars,
            ),
          ),
          SizedBox(
            width: width,
            child: _ProgressMetric(
              icon: CupertinoIcons.doc_text,
              tint: const Color(0xFFDDF2E9),
              color: const Color(0xFF1B7059),
              label: 'Quizzes únicos',
              value: summary.uniqueQuizzes,
            ),
          ),
          SizedBox(
            width: width,
            child: _ProgressMetric(
              icon: CupertinoIcons.clock,
              tint: const Color(0xFFE8EAFB),
              color: const Color(0xFF4B4D93),
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
    required this.tint,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color tint;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(icon, size: 16, color: color),
            ),
          ),
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
          fontSize: 13,
          height: 1.15,
          color: ProgressAppearance.muted,
        ),
      ),
    ],
  );
}
