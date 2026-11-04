// Block: Per-question quiz progress model

class QuizQuestionProgressModel {
  // Block: Immutable student answer fields
  final String quizId;
  final bool isAnswered;
  final bool isCorrect;
  final int earnedStars;
  final int maxStars;
  final int? selectedOptionIndex;
  final DateTime? answeredAt;

  // Block: Main const constructor
  const QuizQuestionProgressModel({
    required this.quizId,
    required this.isAnswered,
    required this.isCorrect,
    required this.earnedStars,
    required this.maxStars,
    this.selectedOptionIndex,
    this.answeredAt,
  });

  // Block: Safe deserializer for API and JSON values
  factory QuizQuestionProgressModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
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

  // Block: Map serializer compatible with the API payload
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

  // Block: Immutable cloning with copyWith
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
