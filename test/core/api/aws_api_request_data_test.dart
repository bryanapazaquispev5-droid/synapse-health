import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';

void main() {
  AwsApiClient client(ApiTransport transport, {String? Function()? uid}) =>
      AwsApiClient(
        baseUrl: 'https://api.example.test/',
        tokenSupplier: (_) async => 'test-token',
        sessionUidSupplier: uid ?? () => 'fixture-sub',
        transport: transport,
      );
  for (final path in [
    'https://evil.test/api/v1/flashcards',
    '//evil.test',
    '/api/v1/flashcards',
    'api/v1/../flashcards',
    'api/v1/flashcards?token=x',
    'api/v1/flashcards#secret',
    'api/v1/flashcards/%2F',
  ]) {
    test('unsafe relative path rejected: $path', () {
      expect(
        () =>
            client((_, _, _, _) => throw StateError('not called'))
                .requestData('GET', path),
        throwsArgumentError,
      );
    });
  }
  for (final headers in [
    {'Authorization': 'injected'},
    {'If-Match': '2'},
    {'If-Match': '"2"\r\nAuthorization: injected'},
    {'if-match': '"2"'},
  ]) {
    test('unsafe extra headers rejected: ${headers.keys}', () {
      expect(
        () => client(
          (_, _, _, _) => throw StateError('not called'),
        ).requestData('PATCH', 'api/v1/flashcards/id', extraHeaders: headers),
        throwsArgumentError,
      );
    });
  }
  test(
    'delete response rejected when session changes during request',
    () async {
      String? uid = 'before';
      final api = client((_, _, _, _) async {
        uid = 'after';
        return const ApiResponse(204, '');
      }, uid: () => uid);
      await expectLater(
        api.requestData('DELETE', 'api/v1/flashcards/id'),
        throwsA(
          isA<AwsApiException>().having(
            (e) => e.failure,
            'failure',
            ApiFailure.unauthenticated,
          ),
        ),
      );
    },
  );
  test('401 refresh preserves optimistic concurrency header', () async {
    var calls = 0;
    await client((_, headers, _, _) async {
      expect(headers['If-Match'], '"2"');
      return ++calls == 1
          ? const ApiResponse(401, '{}')
          : const ApiResponse(204, '');
    }).requestData(
      'DELETE',
      'api/v1/flashcards/id',
      extraHeaders: {'If-Match': '"2"'},
    );
    expect(calls, 2);
  });
  for (final status in [400, 413, 415, 422]) {
    test('HTTP $status maps to invalid request', () async {
      await expectLater(
        client((_, _, _, _) async => ApiResponse(status, 'internal'))
            .requestData('GET', 'api/v1/flashcards'),
        throwsA(
          isA<AwsApiException>().having(
            (e) => e.failure,
            'failure',
            ApiFailure.invalidRequest,
          ),
        ),
      );
    });
  }
}
