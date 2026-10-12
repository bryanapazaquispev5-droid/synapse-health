import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/features/quizzes/api/aws_quizzes_client.dart';
import 'package:synapse_health/features/quizzes/model/aws_quiz.dart';

const key = '12345678-1234-4234-8234-123456789abc';
Map<String, dynamic> question([String type = 'single_choice']) => {
  'id': 'quiz',
  'areaId': 'area',
  'topicId': 'topic',
  'type': type,
  'question': 'Local test',
  'sourceBook': '',
  'orderIndex': 1,
  if (type == 'single_choice')
    'options': [
      {'id': key, 'text': 'Fixture'},
    ],
  if (type == 'matching')
    'leftItems': [
      {'id': 'left', 'text': 'Fixture left'},
    ],
  if (type == 'matching')
    'rightItems': [
      {'id': 'right', 'text': 'Fixture right'},
    ],
  if (type == 'ordering')
    'items': [
      {'id': 'item', 'text': 'Fixture item'},
    ],
};
Map<String, dynamic> result() => {
  'attemptId': key,
  'quizId': 'quiz',
  'answeredAt': '2026-01-01T00:00:05Z',
  'durationSeconds': 5,
  'topicAttemptNumber': 1,
  'isCorrect': true,
  'score': 1,
  'earnedStars': 1,
  'maxStars': 1,
};
ApiResponse response(Map<String, dynamic> data, [int status = 200]) =>
    ApiResponse(status, jsonEncode({'data': data}));
AwsQuizzesClient client(ApiTransport transport) => AwsQuizzesClient(
  api: AwsApiClient(
    baseUrl: 'https://api.example.test',
    tokenSupplier: (_) async => 'access',
    sessionUidSupplier: () => 'subject',
    transport: transport,
  ),
);
void main() {
  for (final type in ['single_choice', 'matching', 'ordering']) {
    test('safe $type DTO exposes labels without grading key', () {
      final quiz = AwsQuiz(question(type));
      expect(quiz.type, type);
      expect(quiz.question, 'Local test');
    });
  }
  for (final secret in [
    'correctIndex',
    'rationale',
    'matchingPairs',
    'orderingItems',
  ]) {
    test(
      'rejects response exposing $secret',
      () => expect(
        () => AwsQuiz({...question(), secret: 0}),
        throwsFormatException,
      ),
    );
  }
  test('list forwards real filters and paginated cursor', () async {
    final api = client((uri, headers, method, body) async {
      expect(uri.path, '/api/v1/quizzes');
      expect(uri.queryParameters, {
        'areaId': 'area',
        'topicId': 'topic',
        'limit': '5',
        'cursor': 'cursor',
      });
      expect(headers['Authorization'], 'Bearer access');
      return response({
        'items': [question()],
        'nextCursor': 'next',
      });
    });
    final page = await api.list(
      areaId: 'area',
      topicId: 'topic',
      limit: 5,
      cursor: 'cursor',
    );
    expect(page.items.single.id, 'quiz');
    expect(page.nextCursor, 'next');
  });
  test('detail parses safe question', () async {
    expect(
      (await client((uri, headers, method, body) async {
        expect(uri.path, '/api/v1/quizzes/quiz');
        return response(question());
      }).get('quiz')).id,
      'quiz',
    );
  });
  test('start sends empty body and stable idempotency key', () async {
    final start = await client((uri, headers, method, body) async {
      expect(uri.path, '/api/v1/quizzes/quiz/attempts/start');
      expect(method, 'POST');
      expect(jsonDecode(body!), {});
      expect(headers['Idempotency-Key'], key);
      return response({
        'attemptId': key,
        'startedAt': '2026-01-01T00:00:00Z',
        'topicAttemptNumber': 1,
        'status': 'started',
        'question': question(),
      }, 201);
    }).start('quiz', idempotencyKey: key);
    expect(start.attemptId, key);
    expect(start.status, 'started');
    expect(start.result, isNull);
  });
  for (final status in [200, 201]) {
    test('submit $status sends only answer and attempt locator', () async {
      final submitted = await client((uri, headers, method, body) async {
        expect(jsonDecode(body!), {
          'attemptId': key,
          'answer': {'choiceId': key},
        });
        return response(result(), status);
      }).submit('quiz', attemptId: key, answer: const AwsChoiceAnswer(key));
      expect(submitted.earnedStars, 1);
      expect(submitted.durationSeconds, 5);
    });
  }
  test('answer DTOs cannot accept score or stars', () {
    expect(
      const AwsMatchingAnswer([(leftId: 'left', rightId: 'right')]).toMap(),
      {
        'pairs': [
          {'leftId': 'left', 'rightId': 'right'},
        ],
      },
    );
    expect(const AwsOrderingAnswer(['second', 'first']).toMap(), {
      'itemIds': ['second', 'first'],
    });
  });
  test('own attempt read returns server result', () async {
    final attempt = await client(
      (uri, headers, method, body) async => response({
        'attemptId': key,
        'startedAt': '2026-01-01T00:00:00Z',
        'topicAttemptNumber': 1,
        'status': 'submitted',
        'question': question(),
        'result': result(),
      }),
    ).getAttempt('quiz', key);
    expect(attempt.result?.score, 1);
  });
  test('malformed server response returns safe invalid response', () async {
    await expectLater(
      client(
        (uri, headers, method, body) async => response({'id': 'incomplete'}),
      ).get('quiz'),
      throwsA(
        isA<AwsApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.invalidResponse,
        ),
      ),
    );
  });
  test('invalid id and limit rejected without request', () async {
    final api = client(
      (uri, headers, method, body) async =>
          throw StateError('Unexpected network'),
    );
    await expectLater(api.get('../quiz'), throwsArgumentError);
    await expectLater(api.list(areaId: 'area', limit: 51), throwsArgumentError);
  });
  test('401 refresh preserves idempotency and body', () async {
    var requests = 0;
    final refreshes = <bool>[];
    final bodies = <String?>[];
    final api = AwsQuizzesClient(
      api: AwsApiClient(
        baseUrl: 'https://api.example.test',
        sessionUidSupplier: () => 'sub',
        tokenSupplier: (refresh) async {
          refreshes.add(refresh);
          return refresh ? 'new' : 'old';
        },
        transport: (uri, headers, method, body) async {
          expect(headers['Idempotency-Key'], key);
          bodies.add(body);
          requests++;
          return requests == 1
              ? const ApiResponse(401, '{}')
              : response({
                  'attemptId': key,
                  'startedAt': '2026-01-01T00:00:00Z',
                  'topicAttemptNumber': 1,
                  'status': 'started',
                  'question': question(),
                }, 201);
        },
      ),
    );
    await api.start('quiz', idempotencyKey: key);
    expect(refreshes, [false, true]);
    expect(bodies[0], bodies[1]);
  });
  test('invalid idempotency header rejected before transport', () async {
    await expectLater(
      client(
        (uri, headers, method, body) async =>
            throw StateError('Unexpected network'),
      ).start('quiz', idempotencyKey: 'bad'),
      throwsArgumentError,
    );
  });
  test('unconfigured AWS remains disabled', () async {
    await expectLater(
      AwsQuizzesClient(api: AwsApiClient(baseUrl: '')).get('quiz'),
      throwsA(
        isA<AwsApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.disabled,
        ),
      ),
    );
  });
}
