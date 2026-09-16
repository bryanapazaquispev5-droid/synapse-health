import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_model.dart';

class QuizRationaleCard extends StatelessWidget {
  final QuizModel quiz;
  final bool? isMatchingCorrect;
  final bool? isOrderingCorrect;
  final int? selectedOptionIndex;

  const QuizRationaleCard({
    super.key,
    required this.quiz,
    required this.isMatchingCorrect,
    required this.isOrderingCorrect,
    required this.selectedOptionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = quiz.type == 'matching'
        ? (isMatchingCorrect ?? false)
        : quiz.type == 'ordering'
            ? (isOrderingCorrect ?? false)
            : (selectedOptionIndex == quiz.correctIndex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.info_circle_fill,
                size: 18,
                color: isCorrect ? AppColors.systemGreen : AppColors.systemRed,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '¡Respuesta Correcta!' : 'Explicación Anatómica',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCorrect ? AppColors.systemGreen : AppColors.systemRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            quiz.rationale,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
