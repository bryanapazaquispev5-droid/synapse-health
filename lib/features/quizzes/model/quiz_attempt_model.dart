// Block: Quiz attempt model (QuizAttemptModel)
import 'quiz_question_progress_model.dart';

class QuizAttemptModel {
  // Block: Topic attempt fields
  final int attemptNumber;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalEarnedStars;
  final int totalMaxStars;
  final Map<String, QuizQuestionProgressModel> questionAnswers;

  // Block: Main const constructor
  const QuizAttemptModel({
    required this.attemptNumber,
    required this.startedAt,
    this.completedAt,
    required this.totalEarnedStars,
    required this.totalMaxStars,
    required this.questionAnswers,
  });

  // Block: State and lock status query methods
  bool isQuizLocked(String quizId) {
    return questionAnswers[quizId]?.isAnswered ?? false;
  }

  QuizQuestionProgressModel? getQuizProgress(String quizId) {
    return questionAnswers[quizId];
  }

  int get answeredCount {
    return questionAnswers.values.where((q) => q.isAnswered).length;
  }

  bool get isCompleted => completedAt != null;

  // Block: Safe deserializer from a Map
  factory QuizAttemptModel.fromMap(Map<String, dynamic> map) {
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

    final rawAnswers = map['questionAnswers'];
    final Map<String, QuizQuestionProgressModel> parsedAnswers = {};

    if (rawAnswers is Map) {
      rawAnswers.forEach((key, val) {
        if (val is Map) {
          parsedAnswers[key.toString()] = QuizQuestionProgressModel.fromMap(
            Map<String, dynamic>.from(val),
          );
        }
      });
    }

    return QuizAttemptModel(
      attemptNumber: parseInt(map['attemptNumber'], 1),
      startedAt: parseDate(map['startedAt']) ?? DateTime.now(),
      completedAt: parseDate(map['completedAt']),
      totalEarnedStars: parseInt(map['totalEarnedStars'], 0),
      totalMaxStars: parseInt(map['totalMaxStars'], 0),
      questionAnswers: parsedAnswers,
    );
  }

  // Block: Map serializer compatible with the API payload
  Map<String, dynamic> toMap() {
    return {
      'attemptNumber': attemptNumber,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalEarnedStars': totalEarnedStars,
      'totalMaxStars': totalMaxStars,
      'questionAnswers': questionAnswers.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  // Block: Empty attempt constructor
  factory QuizAttemptModel.empty({
    int attemptNumber = 1,
    int totalMaxStars = 0,
  }) {
    return QuizAttemptModel(
      attemptNumber: attemptNumber,
      startedAt: DateTime.now(),
      completedAt: null,
      totalEarnedStars: 0,
      totalMaxStars: totalMaxStars,
      questionAnswers: const {},
    );
  }

  // Block: Immutable cloning with copyWith
  QuizAttemptModel copyWith({
    int? attemptNumber,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalEarnedStars,
    int? totalMaxStars,
    Map<String, QuizQuestionProgressModel>? questionAnswers,
  }) {
    return QuizAttemptModel(
      attemptNumber: attemptNumber ?? this.attemptNumber,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalEarnedStars: totalEarnedStars ?? this.totalEarnedStars,
      totalMaxStars: totalMaxStars ?? this.totalMaxStars,
      questionAnswers: questionAnswers ?? this.questionAnswers,
    );
  }
}
