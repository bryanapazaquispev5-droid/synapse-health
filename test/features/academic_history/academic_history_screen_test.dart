import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';
import 'academic_history_screen_fixture.dart';

void main() {
  late HistoryScreenRepository repo;
  late FakeConnectivity connection;
  setUp(() {
    repo = HistoryScreenRepository();
    connection = FakeConnectivity();
  });
  tearDown(() async {
    await repo.close();
    await connection.changes.close();
  });
  testWidgets('loading then genuine empty history', (tester) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    expect(find.text('Loading…'), findsOneWidget);
    repo.histories['alice']!.add([]);
    await historyFrames(tester);
    expect(find.text('No activities yet'), findsOneWidget);
    expect(find.text('My History'), findsOneWidget);
  });
  testWidgets('real saved values and catalog names without identifiers', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Test Question'), findsOneWidget);
    expect(find.text('Test Area · Test Topic'), findsOneWidget);
    expect(find.text('Attempt 2'), findsOneWidget);
    expect(find.text('2 / 2 stars'), findsOneWidget);
    expect(find.text('11/10/2026 12:30'), findsOneWidget);
    expect(find.textContaining('private-record'), findsNothing);
  });
  testWidgets('detail route shows saved result and absent duration honestly', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    await tester.tap(find.text('Test Question'));
    await tester.pump(const Duration(milliseconds: 500));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Result'), findsWidgets);
    expect(find.text('Not recorded'), findsOneWidget);
    expect(find.text('Correct'), findsWidgets);
    expect(find.text('History'), findsWidgets);
  });
  testWidgets('deleted retained record becomes unavailable in detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      historyScreen(repo, connection, entryId: 'private-record'),
    );
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Test Question'), findsOneWidget);
    repo.histories['alice']!.add([]);
    await historyFrames(tester);
    expect(find.text('Result unavailable'), findsOneWidget);
    expect(find.text('Test Question'), findsNothing);
  });
  testWidgets('server error is not rendered as empty and retry starts read', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.addError(StateError('private internal message'));
    await historyFrames(tester);
    expect(
      find.text('Could not load your history. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('private internal'), findsNothing);
    expect(find.text('There are no activities yet'), findsNothing);
    await tester.tap(find.text('Retry'));
    await historyFrames(tester);
    expect(repo.historyReads, ['alice', 'alice']);
  });
  testWidgets('offline network failure uses offline state', (tester) async {
    connection.online = false;
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.addError(const SocketException('network'));
    await historyFrames(tester);
    expect(find.text('No internet connection'), findsOneWidget);
  });
  testWidgets('access revoked clears previously delivered entries', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    repo.histories['alice']!.addError(
      const AwsApiException(ApiFailure.forbidden),
    );
    await historyFrames(tester);
    expect(
      find.text('You do not have permission to view this content.'),
      findsOneWidget,
    );
    expect(find.text('Test Question'), findsNothing);
  });
  testWidgets('different session clears history and owner scoped detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      historyScreen(
        repo,
        connection,
        entryId: 'private-record',
        expectedUid: 'alice',
      ),
    );
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    repo.changeUser('bob');
    await historyFrames(tester);
    expect(find.text('Test Question'), findsNothing);
    expect(
      find.text('Sign in to access this history.'),
      findsOneWidget,
    );
    expect(repo.historyReads, ['alice']);
  });
  testWidgets('signed out session never starts private queries', (
    tester,
  ) async {
    repo.user = null;
    await tester.pumpWidget(historyScreen(repo, connection));
    expect(repo.historyReads, isEmpty);
    expect(
      find.text('Sign in to access this history.'),
      findsOneWidget,
    );
  });
  testWidgets('missing catalog and dates use safe unavailable messages', (
    tester,
  ) async {
    repo.hasCatalog = false;
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry(dated: false)]);
    await historyFrames(tester);
    expect(find.text('Quiz unavailable'), findsOneWidget);
    expect(
      find.text('Area unavailable · Topic unavailable'),
      findsOneWidget,
    );
    expect(find.text('Date unavailable'), findsOneWidget);
  });
  testWidgets('missing area name never exposes document fallback ID', (
    tester,
  ) async {
    repo.areaName = 'a';
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Area unavailable · Test Topic'), findsOneWidget);
    expect(find.text('a · Test Topic'), findsNothing);
  });
  testWidgets(
    'metadata queries are shared per area and topic across refreshes',
    (tester) async {
      await tester.pumpWidget(historyScreen(repo, connection));
      repo.histories['alice']!.add([entry(), entry(id: 'second')]);
      await historyFrames(tester);
      repo.histories['alice']!.add([entry(), entry(id: 'second')]);
      await historyFrames(tester);
      expect(repo.areaReads, 1);
      expect(repo.topicReads, 1);
      expect(repo.quizReads, 1);
    },
  );
  testWidgets(
    'catalog failure keeps academic result and offers metadata retry',
    (tester) async {
      repo.catalogError = StateError('internal catalog');
      await tester.pumpWidget(historyScreen(repo, connection));
      repo.histories['alice']!.add([entry()]);
      await historyFrames(tester);
      expect(
        find.text('Some names are unavailable.'),
        findsOneWidget,
      );
      expect(find.text('2 / 2 stars'), findsOneWidget);
      repo.catalogError = null;
      await tester.tap(find.text('Retry'));
      await historyFrames(tester);
      expect(repo.areaReads, 2);
      expect(find.text('Test Area · Test Topic'), findsOneWidget);
    },
  );
  testWidgets('narrow viewport with large text has no overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      historyScreen(repo, connection, scaler: const TextScaler.linear(2.5)),
    );
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(tester.takeException(), isNull);
  });
}
