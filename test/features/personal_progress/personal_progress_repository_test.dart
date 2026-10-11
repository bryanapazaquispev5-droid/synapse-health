import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/personal_progress/api/personal_progress_repository.dart';
import 'package:synapse_health/features/quizzes/model/quiz_topic_progress_model.dart';

import 'personal_progress_repository_fakes.dart';

void main() {
  late FakeSession auth;
  late FakeProgressSource progress;
  late FakeCatalogSource catalog;
  late PersonalProgressRepository repository;
  final unauthorized = isA<FirebaseAuthException>().having(
    (error) => error.code,
    'code',
    'unauthenticated',
  );

  setUp(() {
    auth = FakeSession()..user = FakeIdentity('alice');
    progress = FakeProgressSource();
    catalog = FakeCatalogSource();
    repository = PersonalProgressRepository(
      auth: auth,
      progressService: progress,
      catalog: catalog,
    );
  });

  test('owner progress forwards existing service and data once', () async {
    final value = {
      'topic': QuizTopicProgressModel.empty(topicId: 'topic', areaId: 'area'),
    };
    final received = repository.watchProgress('alice').first;
    progress.source.add(value);
    expect(await received, same(value));
    expect(progress.calls, 1);
  });

  test('another UID fails before invoking private service', () async {
    await expectLater(
      repository.watchProgress('bob'),
      emitsError(unauthorized),
    );
    expect(progress.calls, 0);
  });

  test('signed out session fails before any data access', () async {
    auth.user = null;
    await expectLater(
      repository.watchProgress('alice'),
      emitsError(unauthorized),
    );
    await expectLater(repository.watchAreas('alice'), emitsError(unauthorized));
    await expectLater(
      repository.watchTopics('alice', 'area'),
      emitsError(unauthorized),
    );
    expect(progress.calls, 0);
    expect(catalog.areaCalls, 0);
    expect(catalog.topicCalls, isEmpty);
  });

  test(
    'identity changing before private event never forwards old data',
    () async {
      final expectation = expectLater(
        repository.watchProgress('alice'),
        emitsInOrder([emitsError(unauthorized), emitsDone]),
      );
      auth.user = FakeIdentity('bob');
      progress.source.add({
        'alice-only': QuizTopicProgressModel.empty(topicId: 't', areaId: 'a'),
      });
      await progress.source.close();
      await expectation;
      expect(progress.calls, 1);
    },
  );

  for (final code in ['permission-denied', 'unavailable']) {
    test('$code propagates instead of a silent empty result', () async {
      final failure = FirebaseException(plugin: 'cloud_firestore', code: code);
      final expectation = expectLater(
        repository.watchProgress('alice'),
        emitsError(same(failure)),
      );
      progress.source.addError(failure);
      await expectation;
    });
  }

  test(
    'cancelling repository subscription cancels source subscription',
    () async {
      final subscription = repository.watchProgress('alice').listen((_) {});
      await subscription.cancel();
      expect(progress.cancellations, 1);
      expect(progress.source.hasListener, isFalse);
    },
  );

  test('catalog reads require owner before querying services', () async {
    await expectLater(repository.watchAreas('bob'), emitsError(unauthorized));
    await expectLater(
      repository.watchTopics('bob', 'area'),
      emitsError(unauthorized),
    );
    expect(catalog.areaCalls, 0);
    expect(catalog.topicCalls, isEmpty);

    final areasResult = repository.watchAreas('alice').first;
    catalog.areas.add([]);
    expect(await areasResult, isEmpty);
    final topicsResult = repository.watchTopics('alice', 'area').first;
    catalog.topics.add([]);
    expect(await topicsResult, isEmpty);
    expect(catalog.areaCalls, 1);
    expect(catalog.topicCalls, ['area']);
  });

  test('catalog event rechecks identity after query begins', () async {
    final expectation = expectLater(
      repository.watchAreas('alice'),
      emitsError(unauthorized),
    );
    auth.user = null;
    catalog.areas.add([]);
    await expectation;
  });

  test('identity and session changes use injected Auth', () async {
    expect(repository.currentUser?.uid, 'alice');
    final next = repository.sessionChanges.first;
    auth.sessions.add(null);
    expect(await next, isNull);
  });
}
