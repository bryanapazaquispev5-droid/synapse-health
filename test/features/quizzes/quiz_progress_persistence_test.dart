import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/constants/app_constants.dart';
import 'package:synapse_health/features/quizzes/api/quiz_progress_service.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

import 'quiz_progress_persistence_fakes.dart';

void main() {
  late MemoryFirestore store;
  late MemoryAuth auth;
  late QuizProgressService service;
  final path =
      '${AppConstants.FIRESTORE_USERS}/student/quiz_topics_progress/topic';
  setUp(() {
    store = MemoryFirestore();
    auth = MemoryAuth();
    service = QuizProgressService(firestore: store, auth: auth);
  });

  Future<void> answer(String id, {int stars = 1}) =>
      service.recordQuestionAnswer(
        areaId: 'area',
        topicId: 'topic',
        quizId: id,
        isCorrect: stars > 0,
        earnedStars: stars,
        maxStars: 3,
        topicTotalMaxStars: 9,
      );
  QuizTopicProgressModel saved() =>
      QuizTopicProgressModel.fromMap(store.documents[path]!);

  test(
    'concurrent answers preserve both entries and original scoring',
    () async {
      await Future.wait([
        answer('first', stars: 2),
        answer('second', stars: 3),
      ]);
      expect(store.transactions, 2);
      expect(
        saved().activeAttempt.questionAnswers.keys,
        containsAll(['first', 'second']),
      );
      expect(saved().activeAttempt.totalEarnedStars, 5);
      expect(saved().activeAttempt.totalMaxStars, 9);
    },
  );

  test(
    're-answering the same key replaces instead of double counting',
    () async {
      await answer('first', stars: 2);
      await answer('first', stars: 3);
      expect(saved().activeAttempt.answeredCount, 1);
      expect(saved().activeAttempt.totalEarnedStars, 3);
    },
  );

  test('concurrent answer then retry archives the saved answer', () async {
    await Future.wait([
      answer('first'),
      service.retryTopic(areaId: 'area', topicId: 'topic', totalMaxStars: 9),
    ]);
    expect(saved().history.single.questionAnswers.keys, ['first']);
    expect(saved().activeAttempt.questionAnswers, isEmpty);
    expect(saved().currentAttemptNumber, 2);
  });

  test('retry keeps FIFO three and preserves attempt increments', () async {
    for (var i = 1; i <= 5; i++) {
      await answer('q$i');
      await service.retryTopic(
        areaId: 'area',
        topicId: 'topic',
        totalMaxStars: 9,
      );
    }
    expect(saved().history.map((a) => a.attemptNumber), [3, 4, 5]);
    expect(saved().currentAttemptNumber, 6);
    expect(saved().activeAttempt.totalEarnedStars, 0);
  });

  test('empty retry updates max stars without archiving', () async {
    await service.retryTopic(
      areaId: 'area',
      topicId: 'topic',
      totalMaxStars: 9,
    );
    await service.retryTopic(
      areaId: 'area',
      topicId: 'topic',
      totalMaxStars: 12,
    );
    expect(saved().history, isEmpty);
    expect(saved().currentAttemptNumber, 1);
    expect(saved().activeAttempt.totalMaxStars, 12);
  });

  test(
    'failed transaction propagates and leaves saved answers intact',
    () async {
      await answer('first');
      final failure = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
      store.failure = failure;
      await expectLater(answer('second'), throwsA(same(failure)));
      expect(saved().activeAttempt.questionAnswers.keys, ['first']);
      await expectLater(
        service.retryTopic(areaId: 'area', topicId: 'topic', totalMaxStars: 9),
        throwsA(same(failure)),
      );
      expect(saved().activeAttempt.questionAnswers.keys, ['first']);
      expect(saved().history, isEmpty);
    },
  );

  test(
    'missing authentication is an explicit failure without transactions',
    () async {
      auth.user = null;
      final unauthorized = isA<FirebaseAuthException>().having(
        (e) => e.code,
        'code',
        'unauthenticated',
      );
      await expectLater(answer('first'), throwsA(unauthorized));
      await expectLater(
        service.retryTopic(areaId: 'area', topicId: 'topic', totalMaxStars: 9),
        throwsA(unauthorized),
      );
      expect(store.transactions, 0);
    },
  );
}
