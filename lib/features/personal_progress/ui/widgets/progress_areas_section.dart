import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/widgets.dart';

import '../../model/progress_summary.dart';
import 'progress_appearance.dart';
import 'progress_meter.dart';

class ProgressAreasSection extends StatelessWidget {
  const ProgressAreasSection({
    super.key,
    required this.areas,
    required this.areaNames,
  });
  final List<ProgressAreaStats> areas;
  final Map<String, String> areaNames;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: const Text(
          'Por área',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ProgressAppearance.ink,
          ),
        ),
      ),
      const SizedBox(height: 9),
      if (areas.isNotEmpty) ...[
        for (final area in areas) ...[
          const SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(color: ProgressAppearance.rule),
          ),
          _AreaProgress(
            stats: area,
            name: areaNames[area.areaId] ?? 'Área no disponible',
          ),
        ],
        const SizedBox(height: 8),
      ],
      const Text(
        'Avance total y tiempo promedio sin datos.',
        style: TextStyle(
          fontSize: 12,
          color: ProgressAppearance.muted,
          height: 1.35,
        ),
      ),
    ],
  );
}

class _AreaProgress extends StatelessWidget {
  const _AreaProgress({required this.stats, required this.name});

  final ProgressAreaStats stats;
  final String name;

  @override
  Widget build(BuildContext context) {
    final accuracy = stats.accuracy;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.square_stack,
                size: 16,
                color: ProgressAppearance.accent,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 12,
            runSpacing: 3,
            children: [
              Text(
                '${stats.uniqueQuizzes} quizzes únicos respondidos',
                style: const TextStyle(
                  fontSize: 12,
                  color: ProgressAppearance.muted,
                ),
              ),
              Text(
                '${stats.currentStars} estrellas actuales',
                style: const TextStyle(
                  fontSize: 12,
                  color: ProgressAppearance.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            accuracy == null
                ? 'Aciertos actuales: no disponibles'
                : 'Aciertos actuales: ${accuracy.toStringAsFixed(1)} %',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (accuracy != null) ...[
            const SizedBox(height: 6),
            ProgressMeter(
              percentage: accuracy,
              color: ProgressAppearance.accent,
            ),
          ],
        ],
      ),
    );
  }
}
