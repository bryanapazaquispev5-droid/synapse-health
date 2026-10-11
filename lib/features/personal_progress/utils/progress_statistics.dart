import '../../quizzes/model/quiz_attempt_model.dart';
import '../../quizzes/model/quiz_question_progress_model.dart';
import '../../quizzes/model/quiz_topic_progress_model.dart';
import '../model/progress_summary.dart';

/// Counts only retained evidence; retries do not accumulate current stars.
ProgressSummary calculateProgress(Map<String, QuizTopicProgressModel> topics) {
  final areas = <String, _AreaAccumulator>{};
  final evolution = <TopicEvolution>[];
  for (final entry in topics.entries) {
    final topic = entry.value;
    final topicId = topic.topicId.isEmpty ? entry.key : topic.topicId;
    final area = areas.putIfAbsent(topic.areaId, _AreaAccumulator.new);
    final activeAnswers = _answers(topic.activeAttempt);
    if (activeAnswers.isNotEmpty) {
      // A negative aggregate is invalid legacy evidence, not earned stars.
      if (topic.activeAttempt.totalEarnedStars >= 0) {
        area.stars += topic.activeAttempt.totalEarnedStars;
      }
      area.answers += activeAnswers.length;
      area.correct += activeAnswers.where((answer) => answer.isCorrect).length;
    }

    final attempts = <int, QuizAttemptModel>{};
    final history = topic.history;
    final first = history.length > QuizTopicProgressModel.maxHistoryEntries
        ? history.length - QuizTopicProgressModel.maxHistoryEntries
        : 0;
    for (final attempt in history.skip(first)) {
      attempts[attempt.attemptNumber] = attempt;
    }
    // The current attempt is authoritative if legacy history repeats its ID.
    attempts[topic.activeAttempt.attemptNumber] = topic.activeAttempt;
    final points = <ProgressEvolutionPoint>[];
    for (final attempt in attempts.values) {
      final answers = _answers(attempt);
      if (answers.isEmpty) continue;
      area.attempts++;
      for (final answer in attempt.questionAnswers.entries) {
        if (answer.key.isNotEmpty && answer.value.isAnswered) {
          area.unique.add((topicId, answer.key));
        }
      }
      final point = _point(attempt, answers);
      if (point != null) points.add(point);
    }
    if (points.length >= 2) {
      points.sort((a, b) => a.attemptNumber.compareTo(b.attemptNumber));
      evolution.add(
        TopicEvolution(
          areaId: topic.areaId,
          topicId: topicId,
          points: List.unmodifiable(points),
        ),
      );
    }
  }
  final areaStats =
      areas.entries.map((entry) => entry.value.freeze(entry.key)).toList()
        ..sort((a, b) => a.areaId.compareTo(b.areaId));
  evolution.sort((a, b) {
    final areaOrder = a.areaId.compareTo(b.areaId);
    return areaOrder != 0 ? areaOrder : a.topicId.compareTo(b.topicId);
  });
  return ProgressSummary(
    currentStars: areaStats.fold(0, (sum, area) => sum + area.currentStars),
    currentAnswers: areaStats.fold(0, (sum, area) => sum + area.currentAnswers),
    currentCorrect: areaStats.fold(0, (sum, area) => sum + area.currentCorrect),
    uniqueQuizzes: areaStats.fold(0, (sum, area) => sum + area.uniqueQuizzes),
    retainedAttempts: areaStats.fold(
      0,
      (sum, area) => sum + area.retainedAttempts,
    ),
    areas: List.unmodifiable(areaStats),
    evolution: List.unmodifiable(evolution),
  );
}

List<QuizQuestionProgressModel> _answers(QuizAttemptModel attempt) => attempt
    .questionAnswers
    .entries
    .where((entry) => entry.key.isNotEmpty && entry.value.isAnswered)
    .map((entry) => entry.value)
    .toList();

ProgressEvolutionPoint? _point(
  QuizAttemptModel attempt,
  List<QuizQuestionProgressModel> answers,
) {
  if (answers.any((answer) => answer.answeredAt == null)) return null;
  final correct = answers.where((answer) => answer.isCorrect).length;
  final lastAnsweredAt = answers
      .map((answer) => answer.answeredAt!)
      .reduce((a, b) => a.isAfter(b) ? a : b);
  return ProgressEvolutionPoint(
    attemptNumber: attempt.attemptNumber,
    answered: answers.length,
    correct: correct,
    lastAnsweredAt: lastAnsweredAt,
    accuracy: correct / answers.length * 100,
  );
}

class _AreaAccumulator {
  int stars = 0;
  int answers = 0;
  int correct = 0;
  int attempts = 0;
  final Set<(String, String)> unique = {};

  ProgressAreaStats freeze(String areaId) => ProgressAreaStats(
    areaId: areaId,
    currentStars: stars,
    currentAnswers: answers,
    currentCorrect: correct,
    uniqueQuizzes: unique.length,
    retainedAttempts: attempts,
  );
}
