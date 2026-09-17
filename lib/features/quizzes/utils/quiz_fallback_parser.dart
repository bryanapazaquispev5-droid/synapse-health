// ============================================================================
// Archivo: quiz_fallback_parser.dart
// Propósito: Componente interactivo [quiz_fallback_parser] para la resolucion de preguntas de opcion multiple, relacion o secuencia.
// ============================================================================

import '../model/matching_pair_model.dart';

// Definicion principal de la clase [QuizFallbackParser]
class QuizFallbackParser {
  static List<MatchingPair> extractFallbackPairs({
    required String question,
    required List<String> options,
    required int correctIndex,
  }) {
    try {
      if (options.isEmpty || correctIndex < 0 || correctIndex >= options.length) {
        return const [];
      }

      final leftItems = <String>[];
      final lines = question.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        final match = RegExp(r'^\d+\.\s*(.+)$').firstMatch(trimmed);
        if (match != null) {
          leftItems.add(match.group(1)!.trim());
        }
      }

      final rightItems = <String>[];
      final correctOption = options[correctIndex];
      final segments = correctOption.split('|');
      for (final segment in segments) {
        final trimmed = segment.trim();
        final colonIdx = trimmed.indexOf(':');
        if (colonIdx != -1) {
          rightItems.add(trimmed.substring(colonIdx + 1).trim());
        } else {
          rightItems.add(trimmed);
        }
      }

      final pairs = <MatchingPair>[];
      final count = leftItems.length < rightItems.length ? leftItems.length : rightItems.length;
      for (int i = 0; i < count; i++) {
        pairs.add(MatchingPair(left: leftItems[i], right: rightItems[i]));
      }
      return pairs;
    } catch (_) {
      return const [];
    }
  }

  static List<String> extractFallbackOrderingItems({
    required String question,
    required List<String> options,
    required int correctIndex,
  }) {
    try {
      if (options.isNotEmpty && correctIndex >= 0 && correctIndex < options.length) {
        final opt = options[correctIndex];
        if (opt.contains('->')) {
          final items = opt.split('->').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          if (items.isNotEmpty && items.every((e) => RegExp(r'^\d+$').hasMatch(e))) {
            final questionItems = <String>[];
            for (final line in question.split('\n')) {
              final m = RegExp(r'^\d+\.\s*(.+)$').firstMatch(line.trim());
              if (m != null) questionItems.add(m.group(1)!.trim());
            }
            if (questionItems.isNotEmpty) {
              return items.map((numStr) {
                final idx = int.parse(numStr) - 1;
                return (idx >= 0 && idx < questionItems.length) ? questionItems[idx] : numStr;
              }).toList();
            }
          }
          return items;
        } else if (opt.contains('|')) {
          return opt.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
      }

      final items = <String>[];
      for (final line in question.split('\n')) {
        final m = RegExp(r'^\d+\.\s*(.+)$').firstMatch(line.trim());
        if (m != null) items.add(m.group(1)!.trim());
      }
      return items;
    } catch (_) {
      return const [];
    }
  }
}
