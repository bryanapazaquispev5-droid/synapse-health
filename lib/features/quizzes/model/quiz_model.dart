import 'package:flutter/material.dart';
import '../utils/quiz_fallback_parser.dart';
import 'matching_pair_model.dart';

export 'matching_pair_model.dart';

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
  final int orderIndex;
  int get order => orderIndex;
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
    int? order,
    int? orderIndex,
    this.matchingPairs = const [],
    this.orderingItems = const [],
  }) : orderIndex = orderIndex ?? order ?? 1;

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

    if (pairs.isEmpty && typeStr == 'matching') {
      pairs = QuizFallbackParser.extractFallbackPairs(
        question: map['question']?.toString() ?? '',
        options: parsedOptions,
        correctIndex: parsedCorrectIndex,
      );
    }

    var orderItems = parseOptions(map['orderingItems']);
    if (orderItems.isEmpty && typeStr == 'ordering') {
      orderItems = QuizFallbackParser.extractFallbackOrderingItems(
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
      orderIndex: parseIndex(map['orderIndex'] ?? map['order']),
      matchingPairs: pairs,
      orderingItems: orderItems,
    );
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

  Color get typeColor {
    switch (type) {
      case 'matching':
        return const Color(0xFF2563EB);
      case 'ordering':
        return const Color(0xFF7C3AED);
      case 'single_choice':
      default:
        return const Color(0xFF059669);
    }
  }

  Color get typeBackgroundColor {
    switch (type) {
      case 'matching':
        return const Color(0xFFDBEAFE);
      case 'ordering':
        return const Color(0xFFEDE9FE);
      case 'single_choice':
      default:
        return const Color(0xFFD1FAE5);
    }
  }
}
