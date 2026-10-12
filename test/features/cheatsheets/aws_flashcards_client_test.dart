import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/features/cheatsheets/api/aws_flashcards_client.dart';
import 'package:synapse_health/features/cheatsheets/model/cheatsheet_model.dart';
import 'package:synapse_health/features/auth_login/cognito/api/cognito_auth_service.dart';
import 'package:synapse_health/features/auth_login/cognito/model/cognito_session.dart';

class TestCognito extends Fake implements CognitoAuthService {
  CognitoSession? session;
  final refreshes = <bool>[];
  @override
  CognitoSession? get currentSession => session;
  @override
  Future<CognitoSession?> validSession({bool forceRefresh = false}) async {
    refreshes.add(forceRefresh);
    return session;
  }
}

void main() {
  final item = <String, dynamic>{
    'id': 'card-1',
    'areaId': 'area',
    'topicId': 'topic',
    'title': 'Test fixture',
    'contentMarkdown': 'Test only',
    'version': 2,
    'createdAt': '2026-01-01T00:00:00Z',
    'updatedAt': '2026-01-02T00:00:00Z',
    'readDurationInMinutes': 3,
  };
  AwsFlashcardsClient client(ApiTransport transport) => AwsFlashcardsClient(
    api: AwsApiClient(
      baseUrl: 'https://api.example.test/stage',
      tokenSupplier: (_) async => 'cognito-test-access',
      sessionUidSupplier: () => 'test-sub',
      transport: transport,
    ),
  );
  ApiResponse response(Map<String, dynamic> data, [int status = 200]) =>
      ApiResponse(status, jsonEncode({'data': data}));
  Matcher failure(ApiFailure type) =>
      isA<AwsApiException>().having((error) => error.failure, 'failure', type);

  test(
    'list sends filters and cursor and maps existing cheatsheet fields',
    () async {
      final api = client((uri, headers, method, body) async {
        expect(uri.path, '/stage/api/v1/flashcards');
        expect(uri.queryParameters, {
          'areaId': 'area',
          'topicId': 'topic',
          'limit': '10',
          'cursor': 'opaque',
        });
        expect(method, 'GET');
        expect(headers['Authorization'], 'Bearer cognito-test-access');
        expect(body, isNull);
        return response({
          'items': [item],
          'nextCursor': 'next',
        });
      });
      final page = await api.list(
        areaId: 'area',
        topicId: 'topic',
        limit: 10,
        cursor: 'opaque',
      );
      expect(page.items.single.cheatsheet.title, 'Test fixture');
      expect(page.items.single.cheatsheet.readDurationInMinutes, 3);
      expect(page.items.single.version, 2);
      expect(page.nextCursor, 'next');
    },
  );

  test('empty list remains genuinely empty', () async {
    final page = await client(
      (_, _, _, _) async => response({'items': [], 'nextCursor': null}),
    ).list(areaId: 'area');
    expect(page.items, isEmpty);
    expect(page.nextCursor, isNull);
  });

  test('detail maps server generated version and dates', () async {
    final card = await client((uri, _, method, _) async {
      expect(uri.path, '/stage/api/v1/flashcards/card-1');
      expect(method, 'GET');
      return response(item);
    }).get('card-1');
    expect(card.createdAt, DateTime.utc(2026));
    expect(card.updatedAt, DateTime.utc(2026, 1, 2));
  });

  test(
    'create sends canonical fields without server generated identity',
    () async {
      await client((_, _, method, body) async {
        expect(method, 'POST');
        final data = jsonDecode(body!) as Map;
        expect(data['readDurationInMinutes'], 4);
        expect(data.containsKey('readMinutes'), isFalse);
        expect(data.containsKey('id'), isFalse);
        expect(data.containsKey('version'), isFalse);
        return response(item, 201);
      }).create(
        const CheatsheetModel(
          id: '',
          areaId: 'area',
          topicId: 'topic',
          title: 'Test fixture',
          contentMarkdown: 'Test only',
          readDurationInMinutes: 4,
        ),
      );
    },
  );

  test(
    'update sends only changes with optimistic concurrency version',
    () async {
      await client(
        (_, headers, method, body) async {
          expect(method, 'PATCH');
          expect(headers['If-Match'], '"2"');
          expect(jsonDecode(body!), {'title': 'Updated fixture'});
          return response(item);
        },
      ).update(id: 'card-1', version: 2, changes: {'title': 'Updated fixture'});
    },
  );

  test('delete accepts empty 204 and sends required version', () async {
    await client((_, headers, method, body) async {
      expect(method, 'DELETE');
      expect(headers['If-Match'], '"2"');
      expect(body, isNull);
      return const ApiResponse(204, '');
    }).delete(id: 'card-1', version: 2);
  });

  for (final invalid in ['', '../secret', 'card/other', 'card?token=x']) {
    test('rejects unsafe identifier $invalid before transport', () async {
      await expectLater(
        client((_, _, _, _) => throw StateError('not called')).get(invalid),
        throwsArgumentError,
      );
    });
  }
  test('rejects invalid pagination before transport', () async {
    await expectLater(
      client((_, _, _, _) => throw StateError('not called'))
          .list(areaId: 'area', limit: 0),
      throwsArgumentError,
    );
  });
  test('rejects invalid version before transport', () async {
    await expectLater(
      client((_, _, _, _) => throw StateError('not called'))
          .delete(id: 'card', version: 0),
      throwsArgumentError,
    );
  });

  for (final code in [403, 404, 409, 429]) {
    test('HTTP $code propagates safe category without server body', () async {
      final type = {
        403: ApiFailure.forbidden,
        404: ApiFailure.notFound,
        409: ApiFailure.conflict,
        429: ApiFailure.rateLimited,
      }[code]!;
      await expectLater(
        client((_, _, _, _) async => ApiResponse(code, '{"secret":"hidden"}'))
            .get('card'),
        throwsA(failure(type)),
      );
    });
  }
  test('malformed item reports invalid response', () async {
    await expectLater(
      client((_, _, _, _) async => response({'id': 'card', 'version': 0}))
          .get('card'),
      throwsA(failure(ApiFailure.invalidResponse)),
    );
  });
  test('malformed page reports invalid response', () async {
    await expectLater(
      client((_, _, _, _) async => response({'items': 'wrong'}))
          .list(areaId: 'area'),
      throwsA(failure(ApiFailure.invalidResponse)),
    );
  });

  test(
    'Cognito factory never uses Firebase and requires an existing session',
    () async {
      final service = TestCognito();
      final api = AwsFlashcardsClient.withCognito(
        service: service,
        baseUrl: 'https://api.example.test',
        transport: (_, _, _, _) => throw StateError('not called'),
      );
      await expectLater(
        api.list(areaId: 'area'),
        throwsA(failure(ApiFailure.unauthenticated)),
      );
    },
  );
  test(
    'Cognito factory sends access token and refreshes once on 401',
    () async {
      final service = TestCognito()
        ..session = CognitoSession(
          sub: 'test-sub',
          accessToken: 'test-access',
          idToken: 'test-id',
          refreshToken: 'test-refresh',
          expiresAt: DateTime.utc(2099),
        );
      var calls = 0;
      final api = AwsFlashcardsClient.withCognito(
        service: service,
        baseUrl: 'https://api.example.test',
        transport: (_, headers, _, _) async {
          expect(headers['Authorization'], 'Bearer test-access');
          return ++calls == 1 ? const ApiResponse(401, '{}') : response(item);
        },
      );
      await api.get('card');
      expect(service.refreshes, [false, true]);
      expect(calls, 2);
    },
  );
}
