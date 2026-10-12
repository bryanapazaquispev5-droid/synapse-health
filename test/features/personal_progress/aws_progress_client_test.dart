import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/features/personal_progress/api/aws_progress_client.dart';
import 'package:synapse_health/features/personal_progress/utils/progress_statistics.dart';
import 'package:synapse_health/features/quizzes/api/aws_quizzes_client.dart';

Map<String, dynamic> topic() => {
  'areaId': 'area',
  'topicId': 'topic',
  'currentAttemptNumber': 1,
  'updatedAt': '2026-01-01T00:00:05Z',
  'history': [],
  'activeAttempt': {
    'attemptNumber': 1,
    'startedAt': '2026-01-01T00:00:00Z',
    'completedAt': null,
    'totalEarnedStars': 1,
    'totalMaxStars': 1,
    'questionAnswers': {
      'quiz': {
        'quizId': 'quiz',
        'isAnswered': true,
        'isCorrect': true,
        'earnedStars': 1,
        'maxStars': 1,
        'answeredAt': '2026-01-01T00:00:05Z',
      },
    },
  },
};
AwsApiClient client(ApiTransport transport) => AwsApiClient(
  baseUrl: 'https://api.example.test',
  tokenSupplier: (_) async => 'access',
  sessionUidSupplier: () => 'subject',
  transport: transport,
);
ApiResponse response(Map<String, dynamic> data) =>
    ApiResponse(200, jsonEncode({'data': data}));
void main() {
  test('progress uses own endpoint and existing statistics model', () async {
    final page = await AwsProgressClient(
      api: client((uri, headers, method, body) async {
        expect(uri.path, '/api/v1/progress/me');
        expect(uri.queryParameters, {'limit': '5', 'cursor': 'cursor'});
        return response({
          'items': [topic()],
          'nextCursor': 'next',
        });
      }),
    ).list(limit: 5, cursor: 'cursor');
    final metrics = calculateProgress({'area/topic': page.items.single});
    expect(metrics.currentStars, 1);
    expect(metrics.currentCorrect, 1);
    expect(metrics.currentAnswers, 1);
    expect(page.nextCursor, 'next');
  });
  test('empty page stays empty without fabricated statistics', () async {
    final page = await AwsProgressClient(
      api: client(
        (uri, headers, method, body) async =>
            response({'items': [], 'nextCursor': null}),
      ),
    ).list();
    expect(page.items, isEmpty);
  });
  test('missing timestamps rejected rather than synthesized', () async {
    final item = topic();
    (item['activeAttempt'] as Map).remove('startedAt');
    await expectLater(
      AwsProgressClient(
        api: client(
          (uri, headers, method, body) async => response({
            'items': [item],
            'nextCursor': null,
          }),
        ),
      ).list(),
      throwsA(
        isA<AwsApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.invalidResponse,
        ),
      ),
    );
  });
  test(
    'retry uses expected topic attempt and stable request identifier',
    () async {
      final updated =
          await AwsQuizzesClient(
            api: client((uri, headers, method, body) async {
              expect(uri.path, '/api/v1/quizzes/topics/topic/retry');
              expect(jsonDecode(body!), {
                'areaId': 'area',
                'expectedAttemptNumber': 1,
              });
              expect(
                headers['Idempotency-Key'],
                '12345678-1234-4234-8234-123456789abc',
              );
              return response(topic());
            }),
          ).retryTopic(
            areaId: 'area',
            topicId: 'topic',
            expectedAttemptNumber: 1,
            idempotencyKey: '12345678-1234-4234-8234-123456789abc',
          );
      expect(updated.topicId, 'topic');
    },
  );
  test('foreign results error propagates without Firebase fallback', () async {
    await expectLater(
      AwsQuizzesClient(
        api: client(
          (uri, headers, method, body) async => const ApiResponse(404, '{}'),
        ),
      ).getAttempt('quiz', 'attempt'),
      throwsA(
        isA<AwsApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.notFound,
        ),
      ),
    );
  });
}
