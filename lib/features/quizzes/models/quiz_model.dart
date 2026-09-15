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

/// Modelo de Dominio para los Quizzes Clínicos de Synapse Health
/// Soporta preguntas de 3 alternativas con retroalimentación médica inmediata
class QuizModel {
  final String id;
  final String areaId;
  final String topicId;
  final String type; // 'single_choice', 'matching', 'ordering'
  final String question;
  final List<String> options;
  final int correctIndex;
  final String rationale;
  final String sourceBook;
  final int order;
  final List<MatchingPair> matchingPairs;
  final List<String> orderingItems;

  const QuizModel({
    required this.id,
    required this.areaId,
    required this.topicId,
    this.type = 'single_choice',
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.rationale,
    required this.sourceBook,
    this.order = 1,
    this.matchingPairs = const [],
    this.orderingItems = const [],
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String documentId) {
    List<String> parseOptions(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    int parseIndex(dynamic raw) {
      if (raw is int) return raw;
      if (raw is num) return raw.toInt();
      if (raw != null) return int.tryParse(raw.toString()) ?? 0;
      return 0;
    }

    List<MatchingPair> parseMatchingPairs(dynamic raw) {
      if (raw is List && raw.isNotEmpty) {
        return raw.map((item) {
          if (item is Map<String, dynamic>) {
            return MatchingPair.fromMap(item);
          } else if (item is Map) {
            return MatchingPair.fromMap(Map<String, dynamic>.from(item));
          }
          return const MatchingPair(left: '', right: '');
        }).where((p) => p.left.isNotEmpty && p.right.isNotEmpty).toList();
      }
      return const [];
    }

    var rawType = map['type']?.toString() ?? 'single_choice';
    if (rawType == 'case_study' || (rawType != 'matching' && rawType != 'ordering')) {
      rawType = 'single_choice';
    }
    final typeStr = rawType;
    final parsedOptions = parseOptions(map['options']);
    final parsedCorrectIndex = parseIndex(map['correctIndex']);
    var pairs = parseMatchingPairs(map['matchingPairs']);

    // Fallback inteligente para preguntas de relacionar si aún no están estructuradas
    if (pairs.isEmpty && typeStr == 'matching') {
      pairs = _extractFallbackPairs(
        question: map['question']?.toString() ?? '',
        options: parsedOptions,
        correctIndex: parsedCorrectIndex,
      );
    }

    var orderItems = parseOptions(map['orderingItems']);
    // Fallback inteligente para preguntas de ordenar si aún no están estructuradas
    if (orderItems.isEmpty && typeStr == 'ordering') {
      orderItems = _extractFallbackOrderingItems(
        question: map['question']?.toString() ?? '',
        options: parsedOptions,
        correctIndex: parsedCorrectIndex,
      );
    }

    return QuizModel(
      id: documentId,
      areaId: map['areaId']?.toString() ?? '',
      topicId: map['topicId']?.toString() ?? '',
      type: typeStr,
      question: map['question']?.toString() ?? '',
      options: parsedOptions,
      correctIndex: parsedCorrectIndex,
      rationale: map['rationale']?.toString() ?? '',
      sourceBook: map['sourceBook']?.toString() ?? map['source']?.toString() ?? '',
      order: parseIndex(map['order']),
      matchingPairs: pairs,
      orderingItems: orderItems,
    );
  }

  static List<MatchingPair> _extractFallbackPairs({
    required String question,
    required List<String> options,
    required int correctIndex,
  }) {
    try {
      if (options.isEmpty || correctIndex < 0 || correctIndex >= options.length) {
        return const [];
      }

      // 1. Extraer elementos de la izquierda del question
      final leftItems = <String>[];
      final lines = question.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        final match = RegExp(r'^\d+\.\s*(.+)$').firstMatch(trimmed);
        if (match != null) {
          leftItems.add(match.group(1)!.trim());
        }
      }

      // 2. Extraer elementos de la derecha de la opción correcta
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

  static List<String> _extractFallbackOrderingItems({
    required String question,
    required List<String> options,
    required int correctIndex,
  }) {
    try {
      if (options.isNotEmpty && correctIndex >= 0 && correctIndex < options.length) {
        final opt = options[correctIndex];
        if (opt.contains('->')) {
          final items = opt.split('->').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          // Si los items son solo números '1 -> 2 -> 3', extraer el texto real de question
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

      // Extraer desde el question si contiene 1., 2., etc.
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

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'topicId': topicId,
      'type': type,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'rationale': rationale,
      'sourceBook': sourceBook,
      'order': order,
      'matchingPairs': matchingPairs.map((p) => p.toMap()).toList(),
      'orderingItems': orderingItems,
    };
  }

  /// Devuelve el enunciado limpio sin los numerales 1., 2., 3. si es de tipo matching u ordering
  String get cleanQuestionPrompt {
    if (type == 'matching' || type == 'ordering') {
      final firstNum = question.indexOf(RegExp(r'\n\s*1\.'));
      if (firstNum != -1) {
        return question.substring(0, firstNum).trim();
      }
    }
    return question;
  }

  String get typeLabel {
    switch (type) {
      case 'matching':
        return 'Para Relacionar';
      case 'ordering':
        return 'Para Ordenar';
      case 'single_choice':
      default:
        return 'Selección Simple';
    }
  }
}
