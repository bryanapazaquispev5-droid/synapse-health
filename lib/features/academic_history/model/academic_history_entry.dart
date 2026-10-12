/// A saved answer within a retained topic attempt, not a completed session.
class AcademicHistoryEntry {
  const AcademicHistoryEntry({
    required this.id,
    required this.areaId,
    required this.topicId,
    required this.quizId,
    required this.attemptNumber,
    required this.answeredAt,
    required this.isCorrect,
    required this.earnedStars,
    required this.maxStars,
    required this.selectedOptionIndex,
  });

  final String id;
  final String areaId;
  final String topicId;
  final String quizId;
  final int attemptNumber;
  final DateTime? answeredAt;
  final bool isCorrect;
  final int earnedStars;
  final int maxStars;
  final int? selectedOptionIndex;

  /// The existing persisted answers do not record reliable elapsed time.
  int? get durationSeconds => null;

  factory AcademicHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AcademicHistoryEntry(
      id: json['id'] as String,
      areaId: json['areaId'] as String,
      topicId: json['topicId'] as String,
      quizId: json['quizId'] as String,
      attemptNumber: json['attemptNumber'] as int,
      answeredAt: json['answeredAt'] == null
          ? null
          : DateTime.parse(json['answeredAt'] as String),
      isCorrect: json['isCorrect'] as bool,
      earnedStars: json['earnedStars'] as int,
      maxStars: json['maxStars'] as int,
      selectedOptionIndex: json['selectedOptionIndex'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'areaId': areaId,
    'topicId': topicId,
    'quizId': quizId,
    'attemptNumber': attemptNumber,
    'answeredAt': answeredAt?.toUtc().toIso8601String(),
    'isCorrect': isCorrect,
    'earnedStars': earnedStars,
    'maxStars': maxStars,
    'selectedOptionIndex': selectedOptionIndex,
    'durationSeconds': null,
  };
}
