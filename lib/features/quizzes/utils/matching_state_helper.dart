// ============================================================================
// Archivo: matching_state_helper.dart
// Propósito: Componente interactivo [matching_state_helper] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import 'package:flutter/material.dart';
import '../model/quiz_model.dart';

// Definicion principal de la clase [MatchingStateHelper]
class MatchingStateHelper {
  static const List<Color> pairColors = [
    Color(0xFF007AFF), // iOS Blue
    Color(0xFF5856D6), // iOS Indigo
    Color(0xFFFF9500), // iOS Orange
    Color(0xFF30B0C7), // iOS Teal
    Color(0xFFAF52DE), // iOS Violet
    Color(0xFFFF2D55), // iOS Pink
  ];

  static Color getPairColor(int pairIndex) {
    return pairColors[pairIndex % pairColors.length];
  }

  static int? getPairNumberForLeft(Map<int, int> userPairings, int leftIndex) {
    if (!userPairings.containsKey(leftIndex)) return null;
    final keys = userPairings.keys.toList()..sort();
    return keys.indexOf(leftIndex) + 1;
  }

  static int? getPairNumberForRight(Map<int, int> userPairings, int rightIndex) {
    for (final entry in userPairings.entries) {
      if (entry.value == rightIndex) {
        return getPairNumberForLeft(userPairings, entry.key);
      }
    }
    return null;
  }

  static int? getLeftIndexForRight(Map<int, int> userPairings, int rightIndex) {
    for (final entry in userPairings.entries) {
      if (entry.value == rightIndex) return entry.key;
    }
    return null;
  }

  static bool isPairCorrect({
    required Map<int, int> userPairings,
    required List<String> leftItems,
    required List<String> rightItems,
    required List<MatchingPair> originalPairs,
    required int? leftIndex,
  }) {
    if (leftIndex == null) return false;
    final rightIndex = userPairings[leftIndex];
    if (rightIndex == null) return false;

    final leftText = leftItems[leftIndex];
    final userRightText = rightItems[rightIndex];

    final pair = originalPairs.firstWhere(
      (p) => p.left == leftText,
      orElse: () => const MatchingPair(left: '', right: ''),
    );

    return pair.right == userRightText;
  }
}
