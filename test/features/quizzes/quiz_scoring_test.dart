// ============================================================================
// Archivo: quiz_scoring_test.dart
// Propósito: Pruebas unitarias para el sistema de estrellas y tiempo en quizzes.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/quizzes/model/quiz_model.dart';
import 'package:synapse_health/features/quizzes/utils/quiz_scoring_helper.dart';

void main() {
  group('Sistema de Estrellas y Tiempo de Quizzes', () {
    test('Calcula max stars correctamente para diferentes tipos de preguntas', () {
      final quizzes = [
        const QuizModel(
          id: 'q1',
          areaId: 'area1',
          topicId: 'topic1',
          type: 'single_choice',
          question: 'Pregunta 1',
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
          question: 'Ordena la secuencia',
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

    test('Formateo de duraciones en segundos y minutos', () {
      expect(QuizScoringHelper.formatDuration(0), equals('0s'));
      expect(QuizScoringHelper.formatDuration(45), equals('45s'));
      expect(QuizScoringHelper.formatDuration(60), equals('1m 0s'));
      expect(QuizScoringHelper.formatDuration(125), equals('2m 5s'));
    });

    test('Puntuación parcial de ordenamiento (1 estrella por posición correcta)', () {
      const sequence = ['A', 'B', 'C', 'D'];
      final userOrder1 = ['A', 'C', 'B', 'D']; // A y D correctos -> 2 aciertos
      final userOrder2 = ['A', 'B', 'C', 'D']; // Todos correctos -> 4 aciertos
      final userOrder3 = ['D', 'C', 'B', 'A']; // Ninguno correcto -> 0 aciertos

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
