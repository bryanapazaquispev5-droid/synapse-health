// Block: Quiz topic progress and attempt system model
import 'quiz_attempt_model.dart';

class QuizTopicProgressModel {
  // Block: Strict FIFO limit for attempt history
  static const int maxHistoryEntries = 3;

  // Block: Topic progress fields
  final String topicId;
  final String areaId;
  final int currentAttemptNumber;
  final QuizAttemptModel activeAttempt;
  final List<QuizAttemptModel> history;
  final DateTime? updatedAt;

  // Block: Main const constructor
  const QuizTopicProgressModel({
    required this.topicId,
    required this.areaId,
    required this.currentAttemptNumber,
    required this.activeAttempt,
    required this.history,
    this.updatedAt,
  });

  // Block: Query and presentation helpers
  bool isQuestionLocked(String quizId) {
    return activeAttempt.isQuizLocked(quizId);
  }

  String get starsDisplay {
    return '${activeAttempt.totalEarnedStars} / ${activeAttempt.totalMaxStars}';
  }

  double get starsPercentage {
    if (activeAttempt.totalMaxStars <= 0) return 0.0;
    return (activeAttempt.totalEarnedStars / activeAttempt.totalMaxStars).clamp(
      0.0,
      1.0,
    );
  }

  // Block: Empty initial progress constructor
  factory QuizTopicProgressModel.empty({
    required String topicId,
    required String areaId,
    int totalMaxStars = 0,
  }) {
    return QuizTopicProgressModel(
      topicId: topicId,
      areaId: areaId,
      currentAttemptNumber: 1,
      activeAttempt: QuizAttemptModel.empty(
        attemptNumber: 1,
        totalMaxStars: totalMaxStars,
      ),
      history: const [],
      updatedAt: DateTime.now(),
    );
  }

  // Block: Safe deserializer that accepts API and JSON values
  factory QuizTopicProgressModel.fromMap(
    Map<String, dynamic> map, {
    String? topicId,
    String? areaId,
  }) {
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

    final String resolvedTopicId = map['topicId']?.toString() ?? topicId ?? '';
    final String resolvedAreaId = map['areaId']?.toString() ?? areaId ?? '';
    final int attemptNum = parseInt(map['currentAttemptNumber'], 1);

    final rawActive = map['activeAttempt'];
    final QuizAttemptModel parsedActive = rawActive is Map
        ? QuizAttemptModel.fromMap(Map<String, dynamic>.from(rawActive))
        : QuizAttemptModel.empty(attemptNumber: attemptNum);

    final rawHistory = map['history'];
    final List<QuizAttemptModel> parsedHistory = [];

    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map) {
          parsedHistory.add(
            QuizAttemptModel.fromMap(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    // Block: Enforce a strict FIFO history limit of three entries
    final List<QuizAttemptModel> trimmedHistory =
        parsedHistory.length > maxHistoryEntries
        ? parsedHistory.sublist(parsedHistory.length - maxHistoryEntries)
        : parsedHistory;

    return QuizTopicProgressModel(
      topicId: resolvedTopicId,
      areaId: resolvedAreaId,
      currentAttemptNumber: attemptNum,
      activeAttempt: parsedActive,
      history: trimmedHistory,
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  // Block: Map serializer compatible with the API payload
  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'areaId': areaId,
      'currentAttemptNumber': currentAttemptNumber,
      'activeAttempt': activeAttempt.toMap(),
      'history': history.map((e) => e.toMap()).toList(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Block: Retry the topic by archiving the current attempt with strict FIFO ordering
  QuizTopicProgressModel archiveCurrentAttemptAndReset({
    required int totalMaxStars,
  }) {
    final completedAttempt = activeAttempt.copyWith(
      completedAt: DateTime.now(),
    );

    final updatedHistory = List<QuizAttemptModel>.from(history)
      ..add(completedAttempt);

    final trimmedHistory = updatedHistory.length > maxHistoryEntries
        ? updatedHistory.sublist(updatedHistory.length - maxHistoryEntries)
        : updatedHistory;

    final nextAttemptNumber = currentAttemptNumber + 1;

    return QuizTopicProgressModel(
      topicId: topicId,
      areaId: areaId,
      currentAttemptNumber: nextAttemptNumber,
      activeAttempt: QuizAttemptModel.empty(
        attemptNumber: nextAttemptNumber,
        totalMaxStars: totalMaxStars,
      ),
      history: trimmedHistory,
      updatedAt: DateTime.now(),
    );
  }

  // Block: Immutable cloning with copyWith
  QuizTopicProgressModel copyWith({
    String? topicId,
    String? areaId,
    int? currentAttemptNumber,
    QuizAttemptModel? activeAttempt,
    List<QuizAttemptModel>? history,
    DateTime? updatedAt,
  }) {
    return QuizTopicProgressModel(
      topicId: topicId ?? this.topicId,
      areaId: areaId ?? this.areaId,
      currentAttemptNumber: currentAttemptNumber ?? this.currentAttemptNumber,
      activeAttempt: activeAttempt ?? this.activeAttempt,
      history: history ?? this.history,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
