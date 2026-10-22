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
    this.durationSeconds,
    this.score,
    this.status,
    this.quizTitle,
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

  /// Optional server measurements; legacy Firebase records remain unavailable.
  final int? durationSeconds;
  final int? score;
  final String? status;
  final String? quizTitle;

  factory AcademicHistoryEntry.fromJson(Map<String, dynamic> json) {
    final duration = json['status'] == 'submitted'
        ? json['durationSeconds']
        : null;
    final score = json['score'];
    final status = json['status'];
    if (duration != null && (duration is! int || duration < 0) ||
        score != null && (score is! int || !{0, 1}.contains(score)) ||
        status != null && status != 'submitted') {
      throw const FormatException('Invalid history result.');
    }
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
      durationSeconds: duration as int?,
      score: score as int?,
      status: status as String?,
      quizTitle: json['quizTitle'] as String?,
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
    'durationSeconds': durationSeconds,
    if (score != null) 'score': score,
    if (status != null) 'status': status,
    if (quizTitle != null) 'quizTitle': quizTitle,
  };
}
