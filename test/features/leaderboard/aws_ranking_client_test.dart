import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/features/leaderboard/api/aws_ranking_client.dart';
import 'package:synapse_health/features/leaderboard/model/aws_ranking_entry.dart';

Map<String, dynamic> entry() => {
  'publicId': '12345678-1234-4234-8234-123456789abc',
  'alias': 'Estudiante 1234abcd',
  'rank': 1,
  'totalStars': 3,
  'totalQuizTimeSeconds': 10,
  'completedQuizzesCount': 2,
  'averageTimeSeconds': 5.0,
};
AwsRankingClient client(ApiTransport transport) => AwsRankingClient(
  api: AwsApiClient(
    baseUrl: 'https://api.example.test',
    tokenSupplier: (_) async => 'access',
    sessionUidSupplier: () => 'subject',
    transport: transport,
  ),
);
ApiResponse response(Map<String, dynamic> data) =>
    ApiResponse(200, jsonEncode({'data': data}));
void main() {
  test('paged ranking preserves server positions and public alias', () async {
    final page = await client((uri, headers, method, body) async {
      expect(uri.path, '/api/v1/ranking');
      expect(uri.queryParameters, {'limit': '5', 'cursor': 'cursor'});
      return response({
        'items': [entry()],
        'nextCursor': 'next',
      });
    }).list(limit: 5, cursor: 'cursor');
    expect(page.items.single.rank, 1);
    expect(page.items.single.alias, 'Estudiante 1234abcd');
    expect(page.nextCursor, 'next');
  });
  test('own ranking absent is null without invented position', () async {
    expect(
      await client(
        (uri, headers, method, body) async => response({'entry': null}),
      ).me(),
      isNull,
    );
  });
  test('own ranking uses server entry', () async {
    final own = await client((uri, headers, method, body) async {
      expect(uri.path, '/api/v1/ranking/me');
      return response({'entry': entry()});
    }).me();
    expect(own?.totalStars, 3);
  });
  for (final field in [
    'sub',
    'email',
    'gender',
    'career',
    'photoUrl',
    'displayName',
  ]) {
    test('rejects public profile field $field', () {
      expect(
        () => AwsRankingEntry({...entry(), field: 'private'}),
        throwsFormatException,
      );
    });
  }
  test('empty ranking remains empty', () async {
    expect(
      (await client(
        (uri, headers, method, body) async =>
            response({'items': [], 'nextCursor': null}),
      ).list()).items,
      isEmpty,
    );
  });
  test('ranking change conflict is surfaced for cursor restart', () async {
    await expectLater(
      client((uri, headers, method, body) async => const ApiResponse(409, '{}'))
          .list(cursor: 'old'),
      throwsA(
        isA<AwsApiException>().having(
          (e) => e.failure,
          'failure',
          ApiFailure.conflict,
        ),
      ),
    );
  });
  test('duplicate rank or participant rejected', () async {
    await expectLater(
      client(
        (uri, headers, method, body) async => response({
          'items': [entry(), entry()],
          'nextCursor': null,
        }),
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
  test('401 refresh uses Cognito client boundary', () async {
    var requests = 0;
    final refreshes = <bool>[];
    final api = AwsRankingClient(
      api: AwsApiClient(
        baseUrl: 'https://api.example.test',
        sessionUidSupplier: () => 'subject',
        tokenSupplier: (refresh) async {
          refreshes.add(refresh);
          return 'access';
        },
        transport: (uri, headers, method, body) async {
          requests++;
          return requests == 1
              ? const ApiResponse(401, '{}')
              : response({'items': [], 'nextCursor': null});
        },
      ),
    );
    await api.list();
    expect(refreshes, [false, true]);
  });
  test('configuration missing stays disabled', () async {
    await expectLater(
      AwsRankingClient(api: AwsApiClient(baseUrl: '')).list(),
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
