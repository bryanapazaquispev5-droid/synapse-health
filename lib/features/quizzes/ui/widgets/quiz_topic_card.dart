// ============================================================================
// File: quiz_topic_card.dart
// Purpose: Interactive component [quiz_topic_card] for answering multiple-choice, matching, or sequencing questions.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/states/app_states.dart';
import '../../../cheatsheets/model/medical_area_model.dart';
import '../../../cheatsheets/model/topic_model.dart';
import '../../model/quiz_topic_progress_model.dart';
import '../topic_quizzes_screen.dart';
import 'quiz_topic_progress_badge.dart';

// Block: Modular visual component [QuizTopicCard]
class QuizTopicCard extends StatelessWidget {
  final MedicalAreaModel area;
  final TopicModel topic;
  final int number;
  final QuizTopicProgressModel? progress;
  final bool progressIsAvailable;
  final bool isLoadingProgress;

  const QuizTopicCard({
    super.key,
    required this.area,
    required this.topic,
    required this.number,
    this.progress,
    this.progressIsAvailable = true,
    this.isLoadingProgress = false,
  });

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    final int quizzesCount = topic.quizzesCount;

    return GestureDetector(
      onTap: () {
        // Block: Navigate smoothly to the next screen
        Navigator.push(
          context,
          AppPageRoute(
            child: TopicQuizzesScreen(area: area, topic: topic),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (!progressIsAvailable)
                        if (isLoadingProgress)
                          const AppLoadingState(
                            message: 'Loading progress',
                            compact: true,
                          )
                        else
                          const Text(
                            'Progress unavailable',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          )
                      else if (progress != null || quizzesCount > 0)
                        QuizTopicProgressBadge(
                          progress: progress,
                          fallbackCount: quizzesCount,
                        )
                      else
                        const Text(
                          'View quizzes',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      if (topic.description.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            topic.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 14,
              color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }
}
