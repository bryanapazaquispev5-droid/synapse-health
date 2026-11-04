// ============================================================================
// File: quiz_result_view.dart
// Purpose: Interactive component [quiz_result_view] for answering multiple-choice, matching, or sequencing questions.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../utils/quiz_scoring_helper.dart';

// User interface screen [QuizResultView]
class QuizResultView extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int earnedStars;
  final int totalMaxStars;
  final int totalDurationSeconds;
  final String areaTitle;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const QuizResultView({
    super.key,
    required this.score,
    required this.totalQuestions,
    this.earnedStars = 0,
    this.totalMaxStars = 0,
    this.totalDurationSeconds = 0,
    required this.areaTitle,
    required this.onRestart,
    required this.onExit,
  });

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    final double percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;
    final bool hasPassed = percentage >= 60;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: hasPassed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      hasPassed ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.exclamationmark_circle_fill,
                      size: 50,
                      color: hasPassed ? AppColors.systemGreen : AppColors.systemRed,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  hasPassed ? 'Excellent Performance!' : 'Good Review Attempt',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Quiz session completed for $areaTitle',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                // Block: Detailed results card with stars and times
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.star_fill, size: 28, color: Color(0xFFFFA000)),
                          const SizedBox(width: 8),
                          Text(
                            '$earnedStars',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB78103),
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            ' / $totalMaxStars',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stars earned ($score of $totalQuestions questions answered correctly)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(CupertinoIcons.stopwatch, size: 15, color: AppColors.accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      QuizScoringHelper.formatDuration(totalDurationSeconds),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Total time',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 30, color: AppColors.border),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(CupertinoIcons.chart_bar_alt_fill, size: 15, color: AppColors.systemGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${percentage.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Accuracy',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(16),
                    onPressed: onRestart,
                    child: const Text(
                      'Retake Quiz',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: onExit,
                    child: const Text(
                      'Back to Main Menu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
