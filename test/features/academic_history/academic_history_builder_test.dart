import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/academic_history/model/academic_history_entry.dart';
import 'package:synapse_health/features/academic_history/utils/academic_history_builder.dart';
import 'package:synapse_health/features/quizzes/model/quiz_attempt_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_question_progress_model.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

QuizQuestionProgressModel answer({DateTime? date, bool answered = true}) =>
    QuizQuestionProgressModel(
      quizId: 'legacy-field',
      isAnswered: answered,
      isCorrect: true,
      earnedStars: 2,
      maxStars: 3,
      selectedOptionIndex: 1,
      answeredAt: date,
    );

QuizAttemptModel attempt(
  int number,
  Map<String, QuizQuestionProgressModel> answers,
) => QuizAttemptModel(
  attemptNumber: number,
  startedAt: DateTime.utc(2025),
  completedAt: DateTime.utc(2025, 2),
  totalEarnedStars: 99,
  totalMaxStars: 99,
  questionAnswers: answers,
);

QuizTopicProgressModel topic({
  String area = 'area',
  String id = 'topic',
  QuizAttemptModel? active,
  List<QuizAttemptModel> history = const [],
}) => QuizTopicProgressModel(
  areaId: area,
  topicId: id,
  currentAttemptNumber: active?.attemptNumber ?? 1,
  activeAttempt: active ?? attempt(1, {}),
  history: history,
);

void main() {
  test('empty progress has no fabricated entries', () {
    expect(buildAcademicHistory({}), isEmpty);
    expect(buildAcademicHistory({'topic': topic()}), isEmpty);
  });

  test('partial attempt includes only saved answered questions', () {
    final entries = buildAcademicHistory({
      'topic': topic(
        active: attempt(1, {
          'quiz-a': answer(),
          'quiz-b': answer(answered: false),
          '': answer(),
        }),
      ),
    });
    expect(entries, hasLength(1));
    expect(entries.single.quizId, 'quiz-a');
    expect(entries.single.earnedStars, 2);
    expect(entries.single.maxStars, 3);
    expect(entries.single.selectedOptionIndex, 1);
  });

  test('retains only three archived attempts plus the active answer', () {
    final entries = buildAcademicHistory({
      'topic': topic(
        active: attempt(5, {'q': answer()}),
        history: [
          for (var i = 1; i <= 4; i++) attempt(i, {'q': answer()}),
        ],
      ),
    });
    expect(entries.map((entry) => entry.attemptNumber).toSet(), {2, 3, 4, 5});
  });

  test('active attempt replaces a duplicate archived attempt', () {
    final entries = buildAcademicHistory({
      'topic': topic(
        active: attempt(2, {'active-question': answer()}),
        history: [
          attempt(2, {'old-question': answer()}),
        ],
      ),
    });
    expect(entries, hasLength(1));
    expect(entries.single.quizId, 'active-question');
  });

  test('missing answer dates and duration remain unavailable', () {
    final entry = buildAcademicHistory({
      'topic': topic(active: attempt(1, {'q': answer()})),
    }).single;
    expect(entry.answeredAt, isNull);
    expect(entry.durationSeconds, isNull);
    expect(entry.toJson()['answeredAt'], isNull);
    expect(entry.toJson()['durationSeconds'], isNull);
  });

  test('orders actual dates descending and undated entries last', () {
    final entries = buildAcademicHistory({
      'topic': topic(
        active: attempt(1, {
          'older': answer(date: DateTime.utc(2025, 3)),
          'undated': answer(),
          'newer': answer(date: DateTime.utc(2025, 4)),
        }),
      ),
    });
    expect(entries.map((entry) => entry.quizId), ['newer', 'older', 'undated']);
  });

  test('equal dates and missing dates have stable identifier ordering', () {
    final first = buildAcademicHistory({
      'topic': topic(active: attempt(1, {'b': answer(), 'a': answer()})),
    });
    final reversed = buildAcademicHistory({
      'topic': topic(active: attempt(1, {'a': answer(), 'b': answer()})),
    });
    expect(first.map((entry) => entry.id), reversed.map((entry) => entry.id));
    expect(first.first.id.compareTo(first.last.id), lessThan(0));
  });

  test('canonical identifier matches the backend tuple without padding', () {
    final id = canonicalHistoryEntryId('área/1', 'tema_2', 3, 'quiz?4');
    expect(id, isNot(contains('=')));
    expect(jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(id)))), [
      'área/1',
      'tema_2',
      3,
      'quiz?4',
    ]);
    expect(canonicalHistoryEntryId('a', 'b', 1, 'c'), 'WyJhIiwiYiIsMSwiYyJd');
  });

  test(
    'identical quiz and topic identifiers in different areas stay distinct',
    () {
      final entries = buildAcademicHistory({
        'one': topic(area: 'area-a', active: attempt(1, {'q': answer()})),
        'two': topic(area: 'area-b', active: attempt(1, {'q': answer()})),
      });
      expect(entries, hasLength(2));
      expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
    },
  );

  test('detail lookup only returns entries from the supplied owner scope', () {
    final entries = buildAcademicHistory({
      'topic': topic(active: attempt(1, {'q': answer()})),
    });
    expect(
      findAcademicHistoryEntry(entries, entries.single.id),
      same(entries.single),
    );
    expect(findAcademicHistoryEntry([], entries.single.id), isNull);
    expect(findAcademicHistoryEntry(entries, 'unknown'), isNull);
  });

  test('JSON round trip preserves real answer fields and ISO date', () {
    final entry = buildAcademicHistory({
      'topic': topic(
        active: attempt(7, {'q': answer(date: DateTime.utc(2025, 5))}),
      ),
    }).single;
    final restored = AcademicHistoryEntry.fromJson(entry.toJson());
    expect(restored.toJson(), entry.toJson());
    expect(restored.answeredAt, DateTime.utc(2025, 5));
  });

  test('DTO does not adopt a fabricated elapsed duration', () {
    final entry = buildAcademicHistory({
      'topic': topic(active: attempt(1, {'q': answer()})),
    }).single;
    final json = entry.toJson()..['durationSeconds'] = 123;
    expect(AcademicHistoryEntry.fromJson(json).durationSeconds, isNull);
  });
}
