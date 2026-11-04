// ============================================================================
// File: quiz_general_exam_card.dart
// Purpose: Interactive component [quiz_general_exam_card] for answering multiple-choice, matching, or sequencing questions.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cheatsheets/model/medical_area_model.dart';
import '../area_quizzes_screen.dart';

// Modular visual component [QuizGeneralExamCard]
class QuizGeneralExamCard extends StatelessWidget {
  final MedicalAreaModel area;

  const QuizGeneralExamCard({super.key, required this.area});

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.square_stack_3d_up_fill,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'General Quiz Bank',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'All accumulated questions for ${area.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(10),
            minimumSize: const Size(60, 32),
            onPressed: () {
              // Block: Navigate smoothly to the next screen
              Navigator.push(
                context,
                AppPageRoute(
                  child: AreaQuizzesScreen(area: area),
                ),
              );
            },
            child: const Text(
              'Ver Todo',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
