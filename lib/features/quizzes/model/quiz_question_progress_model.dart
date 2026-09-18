// Bloque: Modelo de Progreso Individual por Pregunta de Quiz
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestionProgressModel {
  // Bloque: Atributos inmutables de la respuesta del estudiante
  final String quizId;
  final bool isAnswered;
  final bool isCorrect;
  final int earnedStars;
  final int maxStars;
  final int? selectedOptionIndex;
  final DateTime? answeredAt;

  // Bloque: Constructor principal constante
  const QuizQuestionProgressModel({
    required this.quizId,
    required this.isAnswered,
    required this.isCorrect,
    required this.earnedStars,
    required this.maxStars,
    this.selectedOptionIndex,
    this.answeredAt,
  });

  // Bloque: Deserializador seguro tolerante a tipos Firestore y JSON
  factory QuizQuestionProgressModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    int parseInt(dynamic val, int fallback) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    return QuizQuestionProgressModel(
      quizId: map['quizId']?.toString() ?? '',
      isAnswered: map['isAnswered'] == true,
      isCorrect: map['isCorrect'] == true,
      earnedStars: parseInt(map['earnedStars'], 0),
      maxStars: parseInt(map['maxStars'], 3),
      selectedOptionIndex: map['selectedOptionIndex'] != null
          ? parseInt(map['selectedOptionIndex'], 0)
          : null,
      answeredAt: parseDate(map['answeredAt']),
    );
  }

  // Bloque: Serializador a Map compatible con Firestore
  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'isAnswered': isAnswered,
      'isCorrect': isCorrect,
      'earnedStars': earnedStars,
      'maxStars': maxStars,
      'selectedOptionIndex': selectedOptionIndex,
      'answeredAt': answeredAt?.toIso8601String(),
    };
  }

  // Bloque: Clonación inmutable con copyWith
  QuizQuestionProgressModel copyWith({
    String? quizId,
    bool? isAnswered,
    bool? isCorrect,
    int? earnedStars,
    int? maxStars,
    int? selectedOptionIndex,
    DateTime? answeredAt,
  }) {
    return QuizQuestionProgressModel(
      quizId: quizId ?? this.quizId,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
      earnedStars: earnedStars ?? this.earnedStars,
      maxStars: maxStars ?? this.maxStars,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }
}
