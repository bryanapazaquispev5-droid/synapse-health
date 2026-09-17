// ============================================================================
// Archivo: matching_pair_model.dart
// Propósito: Modelo de datos para preguntas médicas, opciones de respuesta y dinámicas de emparejamiento [matching_pair_model].
// ============================================================================

/// Componente de interfaz de usuario reutilizable [MatchingPair].
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
