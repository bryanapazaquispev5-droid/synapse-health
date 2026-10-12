import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/features/academic_history/api/academic_history_repository.dart';
import 'package:synapse_health/features/academic_history/utils/academic_history_builder.dart';
import 'package:synapse_health/features/quizzes/api/quiz_service.dart';

import '../personal_progress/personal_progress_widget_fixture.dart';

class _UnusedQuizSource extends Fake implements QuizService {}

void main() {
  late WidgetProgressRepository progress;
  late Map<String, dynamic> entry;
  setUp(() {
    progress = WidgetProgressRepository();
    entry = buildAcademicHistory({'t': recordedProgress()}).single.toJson();
  });
  tearDown(() async => progress.close());

  AcademicHistoryRepository repository({ApiTransport? transport}) =>
      AcademicHistoryRepository(
        progress: progress,
        quizzes: _UnusedQuizSource(),
        api: AwsApiClient(
          baseUrl: transport == null ? '' : 'https://example.invalid/dev/',
          tokenSupplier: (_) async => 'test-token',
          sessionUidSupplier: () => progress.user?.uid,
          transport: transport,
        ),
      );
  ApiResponse page(List<Map<String, dynamic>> items, {String? cursor}) =>
      ApiResponse(
        200,
        jsonEncode({
          'data': {'items': items, 'nextCursor': cursor},
        }),
      );

  test(
    'Firestore remains the live source when AWS is not configured',
    () async {
      final repo = repository();
      final result = repo.watchHistory('alice').first;
      await Future<void>.delayed(Duration.zero);
      progress.sources['alice']!.add({'t': recordedProgress()});
      expect((await result).single.quizId, entry['quizId']);
      expect(repo.usesAws, isFalse);
      expect(progress.reads, 1);
    },
  );
  test('foreign UID blocked before opening the source', () async {
    await expectLater(
      repository().watchHistory('bob').first,
      throwsA(isA<FirebaseAuthException>()),
    );
    expect(progress.reads, 0);
  });
  test('no session blocked before source query', () async {
    progress.user = null;
    await expectLater(
      repository().watchHistory('alice').first,
      throwsA(isA<FirebaseAuthException>()),
    );
    expect(progress.reads, 0);
  });
  test('AWS pages load incrementally only after the More action', () async {
    var calls = 0;
    final repo = repository(
      transport: (uri, headers, method, body) async {
        calls++;
        expect(uri.path, '/dev/api/v1/history');
        expect(headers['Authorization'], 'Bearer test-token');
        expect(method, 'GET');
        expect(uri.queryParameters['limit'], '50');
        if (calls == 1) return page([entry], cursor: 'next-page');
        expect(uri.queryParameters['cursor'], 'next-page');
        return page([]);
      },
    );
    final events = StreamIterator(repo.watchHistory('alice'));
    expect(await events.moveNext(), isTrue);
    expect(events.current.single.id, entry['id']);
    expect(calls, 1);
    expect(repo.hasMore('alice'), isTrue);
    await repo.loadMore('alice');
    expect(await events.moveNext(), isTrue);
    expect(calls, 2);
    expect(repo.hasMore('alice'), isFalse);
    expect(progress.reads, 0);
    await events.cancel();
  });
  test(
    'AWS403 invalidates content and never falls back to Firestore',
    () async {
      final repo = repository(
        transport: (_, _, _, _) async => const ApiResponse(403, '{}'),
      );
      await expectLater(
        repo.watchHistory('alice').first,
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
      expect(progress.reads, 0);
    },
  );
  test('network outage retains its distinct safe category', () async {
    final repo = repository(
      transport: (_, _, _, _) async => throw const SocketException('test-only'),
    );
    await expectLater(
      repo.watchHistory('alice').first,
      throwsA(
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'network-request-failed',
        ),
      ),
    );
  });
  test(
    'changed session while fetching cannot publish previous private history',
    () async {
      final pending = Completer<ApiResponse>();
      final repo = repository(transport: (_, _, _, _) => pending.future);
      final result = repo.watchHistory('alice').first;
      final assertion = expectLater(result, throwsA(isA<FirebaseException>()));
      await Future<void>.delayed(Duration.zero);
      progress.changeUser('bob');
      pending.complete(page([entry]));
      await assertion;
    },
  );
  test(
    'repeated cursor fails explicitly after retaining the first page',
    () async {
      final repo = repository(
        transport: (_, _, _, _) async => page([], cursor: 'repeat'),
      );
      final events = StreamIterator(repo.watchHistory('alice'));
      expect(await events.moveNext(), isTrue);
      await repo.loadMore('alice');
      await expectLater(events.moveNext(), throwsA(isA<FirebaseException>()));
      await events.cancel();
    },
  );
  test('malformed page is not converted to an empty history', () async {
    final repo = repository(
      transport: (_, _, _, _) async =>
          const ApiResponse(200, '{"data":{"items":{}}}'),
    );
    await expectLater(
      repo.watchHistory('alice').first,
      throwsA(isA<FirebaseException>()),
    );
  });
  test('detail calls owner-scoped AWS endpoint', () async {
    final repo = repository(
      transport: (uri, _, _, _) async {
        expect(uri.path, '/dev/api/v1/history/${entry['id']}');
        return ApiResponse(200, jsonEncode({'data': entry}));
      },
    );
    expect(
      (await repo.watchEntry('alice', entry['id'] as String).first).single.id,
      entry['id'],
    );
    expect(progress.reads, 0);
  });
  test(
    'retired attempt detail is unavailable rather than fabricated',
    () async {
      final repo = repository(
        transport: (_, _, _, _) async => const ApiResponse(404, '{}'),
      );
      expect(
        await repo.watchEntry('alice', entry['id'] as String).first,
        isEmpty,
      );
    },
  );
  test('empty AWS result is a genuine empty history', () async {
    expect(
      await repository(transport: (_, _, _, _) async => page([]))
          .watchHistory('alice')
          .first,
      isEmpty,
    );
  });
}
