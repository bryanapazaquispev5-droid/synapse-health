/// Derived statistics from the current attempt and the retained retry history.
class ProgressSummary {
  final int currentStars;
  final int currentAnswers;
  final int currentCorrect;
  final int uniqueQuizzes;
  final int retainedAttempts;
  final List<ProgressAreaStats> areas;
  final List<TopicEvolution> evolution;

  const ProgressSummary({
    required this.currentStars,
    required this.currentAnswers,
    required this.currentCorrect,
    required this.uniqueQuizzes,
    required this.retainedAttempts,
    required this.areas,
    required this.evolution,
  });

  double? get accuracy =>
      currentAnswers == 0 ? null : currentCorrect / currentAnswers * 100;
  bool get hasActivity => retainedAttempts > 0;
}

class ProgressAreaStats {
  final String areaId;
  final int currentStars;
  final int currentAnswers;
  final int currentCorrect;
  final int uniqueQuizzes;
  final int retainedAttempts;

  const ProgressAreaStats({
    required this.areaId,
    required this.currentStars,
    required this.currentAnswers,
    required this.currentCorrect,
    required this.uniqueQuizzes,
    required this.retainedAttempts,
  });

  double? get accuracy =>
      currentAnswers == 0 ? null : currentCorrect / currentAnswers * 100;
}

/// Attempts from one topic only, without comparing unrelated subject matter.
class TopicEvolution {
  final String areaId;
  final String topicId;
  final List<ProgressEvolutionPoint> points;

  const TopicEvolution({
    required this.areaId,
    required this.topicId,
    required this.points,
  });
}

class ProgressEvolutionPoint {
  final int attemptNumber;
  final int answered;
  final int correct;
  final DateTime lastAnsweredAt;
  final double accuracy;

  const ProgressEvolutionPoint({
    required this.attemptNumber,
    required this.answered,
    required this.correct,
    required this.lastAnsweredAt,
    required this.accuracy,
  });
}
