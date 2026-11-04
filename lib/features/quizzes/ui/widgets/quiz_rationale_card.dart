// ============================================================================
// File: quiz_rationale_card.dart
// Purpose: Interactive component [quiz_rationale_card] for answering multiple-choice, matching, or sequencing questions.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../model/quiz_model.dart';

// Modular visual component [QuizRationaleCard]
class QuizRationaleCard extends StatelessWidget {
  final QuizModel quiz;
  final bool? isMatchingCorrect;
  final bool? isOrderingCorrect;
  final int? selectedOptionIndex;
  final int earnedStars;
  final int maxStars;
  final int elapsedSeconds;

  const QuizRationaleCard({
    super.key,
    required this.quiz,
    required this.isMatchingCorrect,
    required this.isOrderingCorrect,
    required this.selectedOptionIndex,
    this.earnedStars = 0,
    this.maxStars = 1,
    this.elapsedSeconds = 0,
  });

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
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
                isCorrect ? 'Correct Answer!' : 'Anatomical Explanation',
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
          const SizedBox(height: 12),
          // Block: Stars earned and time spent on the question
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCorrect ? const Color(0xFFBBF7D0) : const Color(0xFFFECDD3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      earnedStars > 0 ? CupertinoIcons.star_fill : CupertinoIcons.star,
                      size: 15,
                      color: earnedStars > 0 ? const Color(0xFFFFA000) : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      earnedStars > 0
                          ? '+$earnedStars / $maxStars ${maxStars == 1 ? "star" : "stars"}'
                          : '0 / $maxStars stars',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: earnedStars > 0 ? const Color(0xFFB78103) : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(CupertinoIcons.stopwatch, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${elapsedSeconds}s',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
