// ============================================================================
// File: quiz_scoring_helper.dart
// Purpose: Utilities for calculating stars and formatting quiz times.
// ============================================================================

import '../model/quiz_model.dart';

// Main definition of the class [QuizScoringHelper]
class QuizScoringHelper {
  // Calculates the maximum number of stars available across a list of quizzes
  static int calculateTotalMaxStars(List<QuizModel> quizzes) {
    int total = 0;
    for (final q in quizzes) {
      if (q.type == 'matching') {
        total += q.matchingPairs.length;
      } else if (q.type == 'ordering') {
        total += q.orderingItems.length;
      } else {
        total += 1;
      }
    }
    return total > 0 ? total : quizzes.length;
  }

  // Formats a duration in seconds for display in the interface
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m}m ${s}s';
  }
}
