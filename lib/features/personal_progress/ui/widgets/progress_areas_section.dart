import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_theme.dart';
import '../../model/progress_summary.dart';

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
      const Text(
        'By area',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      for (final area in areas)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            width: double.infinity,
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
                  areaNames[area.areaId] ?? 'Area unavailable',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${area.uniqueQuizzes} unique quizzes answered'),
                const SizedBox(height: 4),
                Text('${area.currentStars} current stars'),
                const SizedBox(height: 4),
                Text(
                  area.accuracy == null
                      ? 'Current correct answers: unavailable'
                      : 'Current correct answers: ${area.accuracy!.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        ),
      const Text(
        'Overall progress and average time are unavailable for these records.',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
      ),
    ],
  );
}
