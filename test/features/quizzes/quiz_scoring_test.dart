// ============================================================================
// File: quiz_scoring_test.dart
// Purpose: Unit tests for the quiz star and timing system.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/quizzes/model/quiz_model.dart';
import 'package:synapse_health/features/quizzes/utils/quiz_scoring_helper.dart';

void main() {
  group('Quiz Star and Timing System', () {
    test('Calculates max stars correctly for different question types', () {
      final quizzes = [
        const QuizModel(
          id: 'q1',
          areaId: 'area1',
          topicId: 'topic1',
          type: 'single_choice',
          question: 'Question 1',
          options: ['A', 'B', 'C'],
          correctIndex: 0,
          rationale: 'R1',
          sourceBook: 'B1',
        ),
        const QuizModel(
          id: 'q2',
          areaId: 'area1',
          topicId: 'topic1',
          type: 'ordering',
          question: 'Order the sequence',
          options: [],
          correctIndex: 0,
          rationale: 'R2',
          sourceBook: 'B2',
          orderingItems: ['Paso 1', 'Paso 2', 'Paso 3', 'Paso 4'],
        ),
        const QuizModel(
          id: 'q3',
          areaId: 'area1',
          topicId: 'topic1',
          type: 'matching',
          question: 'Relaciona',
          options: [],
          correctIndex: 0,
          rationale: 'R3',
          sourceBook: 'B3',
          matchingPairs: [
            MatchingPair(left: 'L1', right: 'R1'),
            MatchingPair(left: 'L2', right: 'R2'),
            MatchingPair(left: 'L3', right: 'R3'),
          ],
        ),
      ];

      final totalStars = QuizScoringHelper.calculateTotalMaxStars(quizzes);
      // 1 (single) + 4 (ordering) + 3 (matching) = 8
      expect(totalStars, equals(8));
    });

    test('Formats durations in seconds and minutes', () {
      expect(QuizScoringHelper.formatDuration(0), equals('0s'));
      expect(QuizScoringHelper.formatDuration(45), equals('45s'));
      expect(QuizScoringHelper.formatDuration(60), equals('1m 0s'));
      expect(QuizScoringHelper.formatDuration(125), equals('2m 5s'));
    });

    test('Partial ordering score (1 star per correct position)', () {
      const sequence = ['A', 'B', 'C', 'D'];
      final userOrder1 = ['A', 'C', 'B', 'D']; // A and D are correct -> 2 correct answers
      final userOrder2 = ['A', 'B', 'C', 'D']; // All answers correct -> 4 correct answers
      final userOrder3 = ['D', 'C', 'B', 'A']; // No answers correct -> 0 correct answers

      int countCorrect(List<String> user) {
        int correct = 0;
        for (int i = 0; i < user.length; i++) {
          if (i < sequence.length && user[i] == sequence[i]) {
            correct++;
          }
        }
        return correct;
      }

      expect(countCorrect(userOrder1), equals(2));
      expect(countCorrect(userOrder2), equals(4));
      expect(countCorrect(userOrder3), equals(0));
    });
  });
}
