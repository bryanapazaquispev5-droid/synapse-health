// ============================================================================
// Archivo: matching_pair_model.dart
// Propósito: Modelo de datos inmutable para preguntas medicas, opciones de respuesta y emparejamientos [matching_pair_model].
// ============================================================================

/// Modelo de Par Estructurado para Quizzes de tipo 'Para Relacionar' (matching)
class MatchingPair {
  final String left;
  final String right;

  const MatchingPair({
    required this.left,
    required this.right,
  });

  factory MatchingPair.fromMap(Map<String, dynamic> map) {
    return MatchingPair(
      left: map['left']?.toString() ?? '',
      right: map['right']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'left': left,
      'right': right,
    };
  }
}
