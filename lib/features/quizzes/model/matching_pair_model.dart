// ============================================================================
// File: matching_pair_model.dart
// Purpose: Immutable data model for medical questions, answer options, and matching pairs [matching_pair_model].
// ============================================================================

/// Structured pair model for matching quizzes
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
