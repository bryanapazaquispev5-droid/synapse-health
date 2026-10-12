import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/features/academic_history/api/cognito_history_client.dart';
import 'package:synapse_health/features/academic_history/model/academic_history_entry.dart';

const id = '12345678-1234-4234-8234-123456789abc';
Map<String, dynamic> entry([String value = id]) => {
  'id': value,
  'areaId': 'area',
  'topicId': 'topic',
  'quizId': 'quiz',
  'attemptNumber': 1,
  'answeredAt': '2026-01-01T00:00:10Z',
  'isCorrect': true,
  'earnedStars': 1,
  'maxStars': 1,
  'selectedOptionIndex': null,
  'durationSeconds': 10,
  'score': 1,
  'status': 'submitted',
  'quizTitle': 'Local test fixture',
};
ApiResponse response(Map<String, dynamic> data) =>
    ApiResponse(200, jsonEncode({'data': data}));
void main() {
  CognitoHistoryClient client(
    ApiTransport transport, {
    String? Function()? subject,
  }) {
    final owner = subject ?? () => 'owner';
    return CognitoHistoryClient(
      api: AwsApiClient(
        baseUrl: 'https://api.example.test',
        tokenSupplier: (_) async => 'access',
        sessionUidSupplier: owner,
        transport: transport,
      ),
      subjectSupplier: owner,
    );
  }

  test('paginated history reuses accumulator and server order', () async {
    var calls = 0;
    final api = client((uri, headers, method, body) async {
      expect(uri.path, '/api/v1/history');
      calls++;
      if (calls == 1) {
        return response({
          'items': [entry()],
          'nextCursor': 'next',
        });
      }
      expect(uri.queryParameters['cursor'], 'next');
      return response({
        'items': [entry('22345678-1234-4234-8234-123456789abc')],
        'nextCursor': null,
      });
    });
    final pages = api.watchHistory('owner');
    final updates = StreamIterator(pages.stream);
    expect(await updates.moveNext(), true);
    expect(updates.current.single.durationSeconds, 10);
    await pages.loadMore();
    expect(await updates.moveNext(), true);
    expect(updates.current.length, 2);
    expect(pages.hasMore, false);
    await updates.cancel();
  });
  test('detail own endpoint parses measured result', () async {
    final item = await client((uri, headers, method, body) async {
      expect(uri.path, '/api/v1/history/$id');
      return response(entry());
    }).get(id);
    expect(item.score, 1);
    expect(item.status, 'submitted');
    expect(item.quizTitle, 'Local test fixture');
  });
  test('legacy history retains missing duration and status', () {
    final old = entry()
      ..remove('durationSeconds')
      ..remove('status')
      ..remove('score')
      ..remove('quizTitle');
    final item = AcademicHistoryEntry.fromJson(old);
    expect(item.durationSeconds, isNull);
    expect(item.status, isNull);
    expect(item.score, isNull);
  });
  test('history rejects negative elapsed time', () {
    expect(
      () => AcademicHistoryEntry.fromJson({...entry(), 'durationSeconds': -1}),
      throwsFormatException,
    );
  });
  test('history rejects invented status', () {
    expect(
      () => AcademicHistoryEntry.fromJson({...entry(), 'status': 'passed'}),
      throwsFormatException,
    );
  });
  test('session change while loading drops private response', () async {
    String? subject = 'owner';
    final pending = Completer<ApiResponse>();
    final api = client(
      (uri, headers, method, body) => pending.future,
      subject: () => subject,
    );
    final future = api.get(id);
    await Future<void>.delayed(Duration.zero);
    subject = 'another';
    pending.complete(response(entry()));
    await expectLater(
      future,
      throwsA(
        isA<AwsApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.unauthenticated,
        ),
      ),
    );
  });
  test('foreign attempt returns safe not found', () async {
    await expectLater(
      client((uri, headers, method, body) async => const ApiResponse(404, '{}'))
          .get(id),
      throwsA(
        isA<AwsApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.notFound,
        ),
      ),
    );
  });
  test('pagination errors are propagated and can retry', () async {
    var calls = 0;
    final api = client((uri, headers, method, body) async {
      calls++;
      return calls == 1
          ? const ApiResponse(503, '{}')
          : response({'items': [], 'nextCursor': null});
    });
    final pages = api.watchHistory('owner');
    final done = Completer<void>();
    final subscription = pages.stream.listen(
      (items) {
        expect(items, isEmpty);
        done.complete();
      },
      onError: (Object error) {
        expect(error, isA<AwsApiException>());
        unawaited(pages.loadMore());
      },
    );
    await done.future;
    await subscription.cancel();
  });
  test('unauthenticated request blocked before network', () {
    final api = client(
      (uri, headers, method, body) async =>
          throw StateError('Unexpected network'),
      subject: () => null,
    );
    expect(() => api.watchHistory('owner'), throwsA(isA<AwsApiException>()));
  });
}
