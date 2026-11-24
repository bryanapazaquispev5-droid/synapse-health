import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/core/widgets/states/app_async_content.dart';
import 'package:synapse_health/features/leaderboard/api/leaderboard_service.dart';
import 'package:synapse_health/features/leaderboard/model/leaderboard_user_model.dart';
import 'package:synapse_health/features/leaderboard/ui/leaderboard_screen.dart';
import 'package:synapse_health/features/leaderboard/ui/widgets/leaderboard_preview.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';

final user = _RankingTestUser();

class _RankingTestUser extends Fake implements User {
  @override
  String get uid => '7';
}

class TestLeaderboard extends Fake implements LeaderboardService {
  TestLeaderboard(this.open);
  final Stream<List<LeaderboardUserModel>> Function() open;
  @override
  Stream<List<LeaderboardUserModel>> getLeaderboardStream({int limit = 50}) =>
      open();
  @override
  void clearCache() {}
}

List<LeaderboardUserModel> entries(int count) => List.generate(
  count,
  (i) => LeaderboardUserModel(
    userId: '${i + 1}',
    rank: i + 1,
    displayName: i == 6
        ? 'Alejandra María Fernández de la Cruz'
        : 'Participant ${i + 1}',
    career: 'Medicine',
    gender: 'Mujer',
    totalStars: 1234567 - i,
    totalQuizTimeSeconds: 600,
    completedQuizzesCount: 3,
    averageTimeSeconds: 25,
  ),
);

void main() {
  testWidgets('Preview opens the full ranking and returns to the same screen', (
    tester,
  ) async {
    final connection = FakeConnectivity();
    addTearDown(connection.changes.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: LeaderboardPreview(
            user: user,
            service: TestLeaderboard(() => Stream.value(entries(20))),
            connectivity: connection,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Tu posición: #7'), findsOneWidget);
    expect(
      find.textContaining('Participant 3', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('Ranking global'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Primeros puestos'), findsOneWidget);
    expect(find.text('#7'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Participant 15'), 300);
    expect(find.text('Participant 15'), findsOneWidget);
    Navigator.of(tester.element(find.byType(LeaderboardScreen))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Tu posición: #7'), findsOneWidget);
  });

  testWidgets(
    'Narrow layout shows real ranks, long names and scores at large text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final connection = FakeConnectivity();
      addTearDown(connection.changes.close);
      Widget app(int count) => MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.8)),
          child: child!,
        ),
        home: LeaderboardScreen(
          key: ValueKey(count),
          currentUser: user,
          connectivity: connection,
          service: TestLeaderboard(() => Stream.value(entries(count))),
        ),
      );
      for (final count in [1, 2, 3]) {
        await tester.pumpWidget(app(count));
        await tester.pump();
        expect(find.text('Sin clasificar'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('Participant $count'), 140);
        expect(find.text('Participant $count'), findsOneWidget);
        expect(find.text('Participant ${count + 1}'), findsNothing);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(app(50));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Alejandra María Fernández de la Cruz'),
        300,
      );
      expect(find.text('Tú'), findsOneWidget);
      expect(find.text('1234561'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Loading, empty, error, offline and retry use existing states', (
    tester,
  ) async {
    final connection = FakeConnectivity();
    final events = StreamController<List<LeaderboardUserModel>>();
    addTearDown(connection.changes.close);
    addTearDown(events.close);
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LeaderboardScreen(
          currentUser: user,
          connectivity: connection,
          service: TestLeaderboard(
            () => calls++ == 0 ? events.stream : Stream.value(entries(3)),
          ),
        ),
      ),
    );
    expect(find.byType(AppLoadingState), findsOneWidget);
    events.add([]);
    await tester.pump();
    expect(find.text('Aún no hay participantes en el ranking'), findsOneWidget);
    events.addError(StateError('test'));
    await tester.pump();
    expect(find.byType(AppErrorState), findsOneWidget);
    connection.setOnline(false);
    events.addError(const SocketException('test'));
    await tester.pump();
    expect(find.byType(AppOfflineState), findsOneWidget);
    connection.setOnline(true);
    await tester.pump();
    await tester.pump();
    expect(calls, 2);
    expect(find.text('Primeros puestos'), findsOneWidget);
  });
}
