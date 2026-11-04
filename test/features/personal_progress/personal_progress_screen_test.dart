import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/api/aws_api_client.dart';
import 'package:synapse_health/core/widgets/states/app_async_content.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';
import 'personal_progress_widget_fixture.dart';

void main() {
  late WidgetProgressRepository repo;
  late FakeConnectivity connection;
  setUp(() {
    repo = WidgetProgressRepository();
    connection = FakeConnectivity();
  });
  tearDown(() async {
    await repo.close();
    await connection.changes.close();
  });

  testWidgets('new user has a real empty state and a visible ranking route', (
    tester,
  ) async {
    await tester.pumpWidget(screen(repo, connection));
    await frames(tester);
    expect(find.byType(AppLoadingState), findsOneWidget);
    repo.sources['alice']!.add({});
    await frames(tester);
    expect(find.text('Your progress starts here'), findsOneWidget);
    expect(find.text('Global leaderboard'), findsOneWidget);
    expect(find.text('Current Stars'), findsNothing);
  });

  testWidgets('partial practice renders actual metrics and area labels', (
    tester,
  ) async {
    await tester.pumpWidget(screen(repo, connection));
    await frames(tester);
    repo.sources['alice']!.add({'t': recordedProgress(stars: 7)});
    await frames(tester);
    await frames(tester);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('100.0 %'), findsOneWidget);
    await tester.ensureVisible(find.text('Test Area'));
    await frames(tester);
    expect(find.text('Test Area'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ranking action keeps the current authenticated identity', (
    tester,
  ) async {
    String? uid;
    await tester.pumpWidget(
      screen(repo, connection, ranking: (user) => uid = user.uid),
    );
    await frames(tester);
    await tester.tap(find.text('Global leaderboard'));
    await tester.pumpAndSettle();
    expect(find.text('Ranking preserved'), findsOneWidget);
    expect(uid, 'alice');
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 400));
    await frames(tester);
    expect(find.text('Personal Progress'), findsOneWidget);
  });

  for (final online in [true, false]) {
    testWidgets(
      'progress failure online=$online is never a new-user empty state',
      (tester) async {
        connection.online = online;
        await tester.pumpWidget(screen(repo, connection));
        await frames(tester);
        repo.sources['alice']!.addError(
          const AwsApiException(ApiFailure.unavailable),
        );
        await frames(tester);
        expect(
          find.byType(online ? AppErrorState : AppOfflineState),
          findsOneWidget,
        );
        expect(find.text('Your progress starts here'), findsNothing);
        expect(find.textContaining('internal detail'), findsNothing);
      },
    );
  }

  testWidgets('no valid session queries no progress', (tester) async {
    repo.changeUser(null);
    await tester.pumpWidget(screen(repo, connection));
    await frames(tester);
    expect(
      find.text('Sign in to view your personal progress.'),
      findsOneWidget,
    );
    expect(repo.reads, 0);
    expect(find.text('Global leaderboard'), findsNothing);
  });

  testWidgets('changing UID clears the previous student statistics', (
    tester,
  ) async {
    await tester.pumpWidget(screen(repo, connection));
    await frames(tester);
    repo.sources['alice']!.add({'t': recordedProgress(stars: 7)});
    await frames(tester);
    expect(find.text('7'), findsOneWidget);
    repo.changeUser('bob');
    await frames(tester);
    expect(find.text('7'), findsNothing);
    expect(repo.sources['alice']!.hasListener, isFalse);
    repo.sources['bob']!.add({});
    await frames(tester);
    expect(find.text('Your progress starts here'), findsOneWidget);
  });

  testWidgets('offline preserves previously loaded metrics', (tester) async {
    await tester.pumpWidget(screen(repo, connection));
    await frames(tester);
    repo.sources['alice']!.add({'t': recordedProgress(stars: 7)});
    await frames(tester);
    connection.setOnline(false);
    await frames(tester);
    expect(find.text('7'), findsOneWidget);
    expect(
      find.text('Offline. Showing previously loaded data.'),
      findsWidgets,
    );
  });

  testWidgets('large text renders without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      screen(repo, connection, textScaler: const TextScaler.linear(2.5)),
    );
    await frames(tester);
    repo.sources['alice']!.add({'t': recordedProgress(stars: 7)});
    await frames(tester);
    expect(tester.takeException(), isNull);
  });
}
