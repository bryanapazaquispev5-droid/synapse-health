import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/personal_progress/utils/progress_statistics.dart';
import 'package:synapse_health/features/quizzes/model/quiz_attempt_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_question_progress_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

void main() {
  test('empty progress has no activity or invented accuracy', () {
    final summary = calculateProgress({});
    expect(summary.hasActivity, isFalse);
    expect(summary.currentStars, 0);
    expect(summary.accuracy, isNull);
    expect(summary.evolution, isEmpty);
  });

  test('empty active aggregate does not manufacture earned stars', () {
    final summary = calculateProgress({'t': topic(attempt(2, {}, stars: 9))});
    expect(summary.currentStars, 0);
    expect(summary.hasActivity, isFalse);
  });

  test('partial stars and question accuracy remain distinct', () {
    final summary = calculateProgress({
      't': topic(attempt(1, {'q': answer(correct: false)}, stars: 2)),
    });
    expect(summary.currentStars, 2);
    expect(summary.currentAnswers, 1);
    expect(summary.currentCorrect, 0);
    expect(summary.accuracy, 0);
  });

  test('false answered flags and empty identity keys are excluded', () {
    final summary = calculateProgress({
      't': topic(
        attempt(1, {
          'ignored': answer(answered: false),
          '': answer(),
          'valid': answer(correct: false),
        }),
      ),
    });
    expect(summary.currentAnswers, 1);
    expect(summary.currentCorrect, 0);
    expect(summary.uniqueQuizzes, 1);
  });

  test('same quiz across retries is unique and only active stars count', () {
    final summary = calculateProgress({
      't': topic(
        attempt(2, {'q': answer()}, stars: 1),
        history: [
          attempt(1, {'q': answer(correct: false)}, stars: 0),
        ],
      ),
    });
    expect(summary.uniqueQuizzes, 1);
    expect(summary.retainedAttempts, 2);
    expect(summary.currentStars, 1);
    expect(summary.evolution.single.points.map((p) => p.accuracy), [0, 100]);
  });

  test('quiz identities are scoped to area and topic', () {
    final summary = calculateProgress({
      'one': topic(attempt(1, {'q': answer()}), area: 'a', id: 't'),
      'two': topic(attempt(1, {'q': answer()}), area: 'b', id: 't'),
      'three': topic(attempt(1, {'q': answer()}), area: 'a', id: 'u'),
    });
    expect(summary.uniqueQuizzes, 3);
    expect(summary.areas.first.uniqueQuizzes, 2);
    expect(summary.evolution, isEmpty);
  });

  test('history obeys last three retention before deduplication', () {
    final summary = calculateProgress({
      't': topic(
        attempt(5, {}),
        history: [
          for (var i = 1; i <= 4; i++) attempt(i, {'q$i': answer()}),
        ],
      ),
    });
    expect(summary.retainedAttempts, 3);
    expect(summary.uniqueQuizzes, 3);
    expect(summary.evolution.single.points.map((p) => p.attemptNumber), [
      2,
      3,
      4,
    ]);
  });

  test('active overrides duplicate history attempt number', () {
    final summary = calculateProgress({
      't': topic(
        attempt(2, {'current': answer()}),
        history: [
          attempt(1, {'first': answer()}),
          attempt(2, {'stale': answer(correct: false)}),
        ],
      ),
    });
    expect(summary.retainedAttempts, 2);
    expect(summary.uniqueQuizzes, 2);
    expect(summary.evolution.single.points.last.accuracy, 100);
  });

  test('empty active overrides duplicate history without false activity', () {
    final summary = calculateProgress({
      't': topic(
        attempt(1, {}),
        history: [
          attempt(1, {'stale': answer()}),
        ],
      ),
    });
    expect(summary.hasActivity, isFalse);
    expect(summary.uniqueQuizzes, 0);
  });

  test('missing answer dates exclude point but retain real counters', () {
    final summary = calculateProgress({
      't': topic(
        attempt(3, {'q': answer()}),
        history: [
          attempt(1, {'q': answer()}),
          attempt(2, {'q': answer(), 'other': answer(dated: false)}),
        ],
      ),
    });
    expect(summary.retainedAttempts, 3);
    expect(summary.evolution.single.points.map((p) => p.attemptNumber), [1, 3]);
  });

  test('a sole dated attempt does not imply evolution', () {
    final summary = calculateProgress({
      't': topic(
        attempt(2, {'q': answer()}),
        history: [
          attempt(1, {'q': answer(dated: false)}),
        ],
      ),
    });
    expect(summary.evolution, isEmpty);
    expect(summary.retainedAttempts, 2);
  });

  test('point uses latest answer date and sorted attempt numbers', () {
    final lateAnswer = answer().copyWith(answeredAt: DateTime(2025, 2, 1));
    final summary = calculateProgress({
      't': topic(
        attempt(3, {'q': answer(), 'r': lateAnswer}),
        history: [
          attempt(2, {'q': answer()}),
          attempt(1, {'q': answer()}),
        ],
      ),
    });
    final points = summary.evolution.single.points;
    expect(points.map((p) => p.attemptNumber), [1, 2, 3]);
    expect(points.last.lastAnsweredAt, DateTime(2025, 2, 1));
  });

  test('negative legacy aggregate does not reduce earned stars', () {
    final summary = calculateProgress({
      't': topic(attempt(1, {'q': answer()}, stars: -4)),
    });
    expect(summary.currentStars, 0);
    expect(summary.currentAnswers, 1);
  });

  test('summary collections cannot be mutated', () {
    final summary = calculateProgress({
      't': topic(
        attempt(2, {'q': answer()}),
        history: [
          attempt(1, {'q': answer()}),
        ],
      ),
    });
    expect(() => summary.areas.clear(), throwsUnsupportedError);
    expect(() => summary.evolution.clear(), throwsUnsupportedError);
    expect(
      () => summary.evolution.single.points.clear(),
      throwsUnsupportedError,
    );
  });
}

QuizQuestionProgressModel answer({
  bool correct = true,
  bool answered = true,
  bool dated = true,
}) => QuizQuestionProgressModel(
  quizId: 'q',
  isAnswered: answered,
  isCorrect: correct,
  earnedStars: correct ? 1 : 0,
  maxStars: 1,
  answeredAt: dated ? DateTime(2025, 1, 1) : null,
);

QuizAttemptModel attempt(
  int number,
  Map<String, QuizQuestionProgressModel> answers, {
  int stars = 0,
}) => QuizAttemptModel(
  attemptNumber: number,
  startedAt: DateTime(2025),
  totalEarnedStars: stars,
  totalMaxStars: 3,
  questionAnswers: answers,
);

QuizTopicProgressModel topic(
  QuizAttemptModel active, {
  String area = 'area',
  String id = 'topic',
  List<QuizAttemptModel> history = const [],
}) => QuizTopicProgressModel(
  topicId: id,
  areaId: area,
  currentAttemptNumber: active.attemptNumber,
  activeAttempt: active,
  history: history,
);
