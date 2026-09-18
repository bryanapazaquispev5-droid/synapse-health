// ============================================================================
// Archivo: quiz_scoring_helper.dart
// Propósito: Utilidades para el cálculo de estrellas y formateo de tiempos en quizzes.
// ============================================================================

import '../model/quiz_model.dart';

// Definición principal de la clase [QuizScoringHelper]
class QuizScoringHelper {
  // Calcula el total máximo de estrellas acumulables para una lista de quizzes
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

  // Formatea una cantidad de segundos a formato legible para la interfaz
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m}m ${s}s';
  }
}
