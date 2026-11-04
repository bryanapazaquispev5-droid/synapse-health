import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/core/widgets/states/app_async_content.dart';

import 'fixtures/async_content_fixture.dart';

void main() {
  late FakeConnectivity connection;
  late StreamController<List<String>> source;
  setUp(() {
    connection = FakeConnectivity();
    source = StreamController<List<String>>.broadcast();
  });
  tearDown(() async {
    await source.close();
    await connection.changes.close();
  });

  testWidgets('waiting becomes a genuine empty result', (tester) async {
    await tester.pumpWidget(content(source.stream, connection));
    await tester.pump();
    await tester.pump();
    expect(find.byType(AppLoadingState), findsOneWidget);
    source.add([]);
    await tester.pump();
    await tester.pump();
    expect(find.text('No notes'), findsOneWidget);
    expect(find.byType(AppLoadingState), findsNothing);
  });

  testWidgets('permission denial remains an error while offline', (
    tester,
  ) async {
    connection.online = false;
    await tester.pumpWidget(content(source.stream, connection));
    await tester.pump();
    await tester.pump();
    source.addError(
      const AwsApiException(ApiFailure.forbidden),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.byType(AppOfflineState), findsNothing);
    expect(
      find.text('You do not have permission to view this content.'),
      findsOneWidget,
    );
    expect(find.textContaining('private internal'), findsNothing);
    expect(find.text('Retry'), findsNothing);
  });

  for (final online in [true, false]) {
    testWidgets('unavailable with online=$online is never empty', (
      tester,
    ) async {
      connection.online = online;
      await tester.pumpWidget(content(source.stream, connection));
      await tester.pump();
      await tester.pump();
      source.addError(
        const AwsApiException(ApiFailure.unavailable),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.byType(online ? AppErrorState : AppOfflineState),
        findsOneWidget,
      );
      expect(find.byType(AppEmptyState), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
    });
  }

  testWidgets('offline preserves delivered content and stream subscription', (
    tester,
  ) async {
    var subscriptions = 0;
    var cancellations = 0;
    final tracked = StreamController<List<String>>.broadcast(
      onListen: () => subscriptions++,
      onCancel: () => cancellations++,
    );
    await tester.pumpWidget(content(tracked.stream, connection));
    await tester.pump();
    await tester.pump();
    tracked.add(['Anatomy']);
    await tester.pump();
    await tester.pump();
    connection.setOnline(false);
    await tester.pump();
    await tester.pump();
    expect(find.text('Anatomy'), findsOneWidget);
    expect(
      find.text('Offline. Showing previously loaded data.'),
      findsOneWidget,
    );
    expect(subscriptions, 1);
    expect(cancellations, 0);
    await tester.pumpWidget(const SizedBox());
    addTearDown(tracked.close);
  });

  testWidgets('retry replaces subscription while keeping delivered content', (
    tester,
  ) async {
    final replacement = StreamController<List<String>>();
    var retries = 0;
    await tester.pumpWidget(
      content(
        source.stream,
        connection,
        retryStream: () {
          retries++;
          return replacement.stream;
        },
      ),
    );
    await tester.pump();
    await tester.pump();
    source.add(['First']);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Refresh'));
    await tester.pump();
    await tester.pump();
    expect(retries, 1);
    expect(find.text('First'), findsOneWidget);
    expect(find.byType(AppLoadingState), findsOneWidget);
    source.add(['Obsoleto']);
    await tester.pump();
    await tester.pump();
    expect(find.text('Obsoleto'), findsNothing);
    replacement.add(['Updated']);
    await tester.pump();
    await tester.pump();
    expect(find.text('Updated'), findsOneWidget);
    expect(find.text('First'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    addTearDown(replacement.close);
  });

  testWidgets('revoked authorization clears previously delivered content', (
    tester,
  ) async {
    await tester.pumpWidget(content(source.stream, connection));
    await tester.pump();
    await tester.pump();
    source.add(['Private content']);
    await tester.pump();
    await tester.pump();
    source.addError(
      const AwsApiException(ApiFailure.forbidden),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Private content'), findsNothing);
    expect(find.byType(AppErrorState), findsOneWidget);
  });

  testWidgets('dispose cancels content and connectivity subscriptions', (
    tester,
  ) async {
    await tester.pumpWidget(content(source.stream, connection));
    await tester.pump();
    await tester.pump();
    expect(source.hasListener, isTrue);
    expect(connection.changes.hasListener, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await tester.pump();
    expect(source.hasListener, isFalse);
    expect(connection.changes.hasListener, isFalse);
    source.add(['Late']);
    connection.setOnline(false);
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('delivered null progress differs from waiting for progress', (
    tester,
  ) async {
    final progress = StreamController<int?>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppAsyncStreamBuilder<int?>(
            stream: progress.stream,
            connectivity: connection,
            builder: (context, snapshot, retry) => Text(
              snapshot.hasData ? 'Received: ${snapshot.data}' : 'Waiting',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    progress.add(null);
    await tester.pump();
    await tester.pump();
    expect(find.text('Received: null'), findsOneWidget);
    expect(find.text('Waiting'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    addTearDown(progress.close);
  });
}
