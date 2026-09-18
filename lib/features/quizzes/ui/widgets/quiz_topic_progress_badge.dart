// Bloque: Componente modular para mostrar la insignia de progreso y estrellas del tema
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_topic_progress_model.dart';

// Bloque: Widget visual [QuizTopicProgressBadge]
class QuizTopicProgressBadge extends StatelessWidget {
  final QuizTopicProgressModel? progress;
  final int fallbackCount;

  const QuizTopicProgressBadge({
    super.key,
    required this.progress,
    required this.fallbackCount,
  });

  @override
  Widget build(BuildContext context) {
    // Bloque: Evaluación de progreso activo en el intento actual
    final bool hasActiveProgress =
        progress != null && progress!.activeAttempt.answeredCount > 0;

    if (hasActiveProgress) {
      final int earned = progress!.activeAttempt.totalEarnedStars;
      final int max = progress!.activeAttempt.totalMaxStars > fallbackCount
          ? progress!.activeAttempt.totalMaxStars
          : (fallbackCount > 0 ? fallbackCount : 20);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFDE68A), width: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 3),
            Text(
              '$earned/$max',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      );
    }

    // Bloque: Insignia por defecto con la cantidad de quizzes
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$fallbackCount Quizzes',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
