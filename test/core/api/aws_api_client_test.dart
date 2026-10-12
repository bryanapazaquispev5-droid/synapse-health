import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';

void main() {
  AwsApiClient client(ApiTransport transport, {ApiTokenSupplier? tokens}) =>
      AwsApiClient(
        baseUrl: 'https://api.example.test/stage',
        tokenSupplier: tokens ?? (_) async => 'test-token',
        transport: transport,
        sessionUidSupplier: () => 'student',
      );
  Matcher failure(ApiFailure type) =>
      isA<AwsApiException>().having((error) => error.failure, 'failure', type);

  test('disabled client never requests a token or sends a request', () async {
    final api = AwsApiClient(
      baseUrl: '',
      tokenSupplier: (_) => throw StateError('unexpected token request'),
      transport: (_, _, _, _) => throw StateError('unexpected request'),
    );
    expect(api.isEnabled, isFalse);
    await expectLater(
      api.fetchOwnProfile(),
      throwsA(failure(ApiFailure.disabled)),
    );
  });

  for (final url in [
    'http://api.example.test',
    'https://secret@api.example.test',
    'https://api.example.test?secret=value',
    'https://api.example.test#fragment',
    'invalid',
  ]) {
    test('rejects unsafe base URL $url', () {
      expect(() => AwsApiClient(baseUrl: url), throwsArgumentError);
    });
  }

  test('uses own profile route and Firebase bearer token', () async {
    final api = client((uri, headers, method, body) async {
      expect(uri.toString(), 'https://api.example.test/stage/v1/me/profile');
      expect(headers['Authorization'], 'Bearer test-token');
      expect(headers['Accept'], 'application/json');
      return const ApiResponse(200, '{"data":{"uid":"student"}}');
    });
    expect(await api.fetchOwnProfile(), {'uid': 'student'});
  });

  test('refreshes token once after 401 and never retries again', () async {
    final refreshes = <bool>[];
    var requests = 0;
    final api = client(
      (_, _, _, _) async {
        requests++;
        return const ApiResponse(401, 'private server detail');
      },
      tokens: (refresh) async {
        refreshes.add(refresh);
        return 'token';
      },
    );
    await expectLater(
      api.fetchOwnProfile(),
      throwsA(failure(ApiFailure.unauthenticated)),
    );
    expect(refreshes, [false, true]);
    expect(requests, 2);
  });

  test('rejects replay when authenticated session changes', () async {
    var uid = 'student';
    var requests = 0;
    final api = AwsApiClient(
      baseUrl: 'https://api.example.test',
      sessionUidSupplier: () => uid,
      tokenSupplier: (_) async => 'token',
      transport: (_, _, _, _) async {
        requests++;
        uid = 'another-student';
        return const ApiResponse(401, '');
      },
    );
    await expectLater(
      api.fetchOwnProfile(),
      throwsA(failure(ApiFailure.unauthenticated)),
    );
    expect(requests, 1);
  });

  test('accepts response after refreshed token', () async {
    var requests = 0;
    final api = client(
      (_, _, _, _) async => ++requests == 1
          ? const ApiResponse(401, '')
          : const ApiResponse(200, '{"data":{}}'),
    );
    expect(await api.fetchOwnProfile(), isEmpty);
    expect(requests, 2);
  });

  test('missing token does not reach transport', () async {
    final api = client(
      (_, _, _, _) => throw StateError('unexpected request'),
      tokens: (_) async => null,
    );
    await expectLater(
      api.fetchOwnProfile(),
      throwsA(failure(ApiFailure.unauthenticated)),
    );
  });

  for (final entry in {
    403: ApiFailure.forbidden,
    404: ApiFailure.notFound,
    429: ApiFailure.rateLimited,
    500: ApiFailure.unavailable,
    302: ApiFailure.unavailable,
  }.entries) {
    test('maps HTTP ${entry.key} without exposing response detail', () async {
      final api = client(
        (_, _, _, _) async => ApiResponse(entry.key, 'secret error'),
      );
      await expectLater(api.fetchOwnProfile(), throwsA(failure(entry.value)));
    });
  }

  for (final body in ['not-json', '[]']) {
    test('rejects invalid profile response $body', () async {
      final api = client((_, _, _, _) async => ApiResponse(200, body));
      await expectLater(
        api.fetchOwnProfile(),
        throwsA(failure(ApiFailure.invalidResponse)),
      );
    });
  }

  test('patches only editable profile fields', () async {
    final api = client((uri, headers, method, body) async {
      expect(method, 'PATCH');
      expect(body, '{"name":"Student"}');
      return const ApiResponse(200, '{"data":{"name":"Student"}}');
    });
    expect(await api.updateOwnProfile(field: 'name', value: 'Student'), {
      'name': 'Student',
    });
    expect(
      () => api.updateOwnProfile(field: 'stars', value: '99'),
      throwsArgumentError,
    );
  });

  test('classifies network outage', () async {
    final api = client(
      (_, _, _, _) async => throw const SocketException('internal'),
    );
    await expectLater(
      api.fetchOwnProfile(),
      throwsA(failure(ApiFailure.offline)),
    );
  });

  test('bounds slow transport without automatic fallback', () async {
    final api = AwsApiClient(
      baseUrl: 'https://api.example.test',
      sessionUidSupplier: () => 'student',
      tokenSupplier: (_) async => 'token',
      transport: (_, _, _, _) => Completer<ApiResponse>().future,
      timeout: const Duration(milliseconds: 1),
    );
    await expectLater(
      api.fetchOwnProfile(),
      throwsA(failure(ApiFailure.timeout)),
    );
  });
}
