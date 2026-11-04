import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_data_source.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/core/auth/app_auth.dart';
import 'package:synapse_health/features/quizzes/api/quiz_progress_service.dart';

import '../personal_progress/personal_progress_repository_fakes.dart';

class ProgressApiFixture {
  final auth = FakeSession()..user = FakeIdentity('synthetic-student');
  final requests = <(String, String, Map<String, dynamic>?)>[];
  Map<String, dynamic> progress = {'items': <Map<String, dynamic>>[]};
  Map<String, dynamic> mutation = {};
  int status = 200;
  late final source = AwsDataSource(
    api: AwsApiClient(
      baseUrl: 'https://synthetic.invalid/',
      sessionUidSupplier: () => auth.user?.uid,
      tokenSupplier: (_) async => 'synthetic-access',
      transport: (uri, headers, method, body) async {
        final fields = body == null
            ? null
            : jsonDecode(body) as Map<String, dynamic>;
        requests.add((method, uri.path, fields));
        expect(headers['Authorization'], 'Bearer synthetic-access');
        return ApiResponse(
          status,
          jsonEncode({'data': method == 'GET' ? progress : mutation}),
        );
      },
    ),
  );
  late final service = QuizProgressService(source: source, auth: auth);

  Future<void> answer({
    Map<String, dynamic>? raw = const {'selectedOptionIndex': 1},
  }) => service.recordQuestionAnswer(
    areaId: 'synthetic-area',
    topicId: 'synthetic-topic',
    quizId: 'synthetic-question',
    isCorrect: true,
    earnedStars: 999,
    maxStars: 999,
    topicTotalMaxStars: 3,
    answer: raw,
  );

  Future<void> retry() => service.retryTopic(
    areaId: 'synthetic-area',
    topicId: 'synthetic-topic',
    totalMaxStars: 3,
  );
}

void main() {
  late ProgressApiFixture fixture;
  setUp(() => fixture = ProgressApiFixture());
  tearDown(() => fixture.auth.sessions.close());

  test('raw answer is mandatory before any authenticated request', () async {
    await expectLater(fixture.answer(raw: null), throwsArgumentError);
    expect(fixture.requests, isEmpty);
  });

  test(
    'answer delegates scoring to AWS and binds the server attempt',
    () async {
      fixture.progress = {
        'items': [
          {'topicId': 'synthetic-topic', 'currentAttemptNumber': 7},
        ],
      };
      await fixture.answer();
      expect(fixture.requests.length, 2);
      expect(fixture.requests.first.$1, 'GET');
      expect(fixture.requests.first.$2, '/api/v1/progress/me');
      final request = fixture.requests.last;
      expect(request.$1, 'POST');
      expect(request.$2, '/api/v1/progress/synthetic-topic/answer');
      expect(request.$3, {
        'areaId': 'synthetic-area',
        'quizId': 'synthetic-question',
        'answer': {'selectedOptionIndex': 1},
        'expectedAttemptNumber': 7,
        'topicTotalMaxStars': 3,
      });
      expect(request.$3!.containsKey('earnedStars'), isFalse);
      expect(request.$3!.containsKey('isCorrect'), isFalse);
      expect(request.$3!.containsKey('uid'), isFalse);
    },
  );

  test('signed-out mutation fails before storage or network access', () async {
    fixture.auth.user = null;
    final unauthorized = isA<AppAuthException>().having(
      (error) => error.code,
      'code',
      'unauthenticated',
    );
    await expectLater(fixture.answer(), throwsA(unauthorized));
    await expectLater(fixture.retry(), throwsA(unauthorized));
    expect(fixture.requests, isEmpty);
  });

  test(
    'AWS failures propagate rather than fabricating saved progress',
    () async {
      fixture.status = 503;
      await expectLater(
        fixture.answer(),
        throwsA(
          isA<AwsApiException>().having(
            (error) => error.failure,
            'failure',
            ApiFailure.unavailable,
          ),
        ),
      );
      expect(fixture.requests.length, 1);
      expect(fixture.requests.single.$1, 'GET');
    },
  );

  test('retry uses idempotency key and adopts the server attempt', () async {
    fixture.progress = {
      'items': [
        {'id': 'synthetic-topic', 'currentAttemptNumber': 4},
      ],
    };
    fixture.mutation = {
      'progress': {'currentAttemptNumber': 5},
    };
    await fixture.retry();
    final retry = fixture.requests.last;
    expect(retry.$2, '/api/v1/progress/synthetic-topic/retry');
    expect(retry.$3!['expectedAttemptNumber'], 4);
    expect(retry.$3!['idempotencyKey'], matches(RegExp(r'^[a-f0-9]{32}$')));
    await fixture.answer();
    expect(fixture.requests.last.$3!['expectedAttemptNumber'], 5);
    expect(fixture.requests.where((request) => request.$1 == 'GET').length, 1);
  });

  test(
    'changing account cannot reuse the previous owner attempt cache',
    () async {
      fixture.progress = {
        'items': [
          {'id': 'synthetic-topic', 'currentAttemptNumber': 8},
        ],
      };
      await fixture.answer();
      fixture.auth.user = FakeIdentity('synthetic-other');
      fixture.progress = {'items': <Map<String, dynamic>>[]};
      await fixture.answer();
      expect(fixture.requests.last.$3!['expectedAttemptNumber'], 1);
      expect(
        fixture.requests.where((request) => request.$1 == 'GET').length,
        2,
      );
    },
  );
}
