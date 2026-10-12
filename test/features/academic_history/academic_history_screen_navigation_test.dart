import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/personal_progress/ui/personal_progress_screen.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';
import '../personal_progress/personal_progress_widget_fixture.dart';
import '../personal_progress/personal_progress_repository_fakes.dart';
import 'academic_history_screen_fixture.dart';

void main() {
  testWidgets('personal progress links history without removing ranking', (
    tester,
  ) async {
    final repo = WidgetProgressRepository();
    final connection = FakeConnectivity();
    addTearDown(repo.close);
    addTearDown(connection.changes.close);
    String? openedUid;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: PersonalProgressScreen(
          repository: repo,
          connectivity: connection,
          historyBuilder: (user) {
            openedUid = user.uid;
            return const Scaffold(body: Text('Historial conectado'));
          },
        ),
      ),
    );
    expect(find.text('Ranking global'), findsOneWidget);
    await tester.tap(find.text('Mi historial'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(openedUid, 'alice');
    expect(find.text('Historial conectado'), findsOneWidget);
  });
  testWidgets('stale progress session cannot open former user history', (
    tester,
  ) async {
    final repo = WidgetProgressRepository();
    final connection = FakeConnectivity();
    addTearDown(repo.close);
    addTearDown(connection.changes.close);
    bool opened = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: PersonalProgressScreen(
          repository: repo,
          connectivity: connection,
          historyBuilder: (user) {
            opened = true;
            return const SizedBox();
          },
        ),
      ),
    );
    repo.user = FakeIdentity('bob');
    await tester.tap(find.text('Mi historial'));
    await historyFrames(tester);
    expect(opened, isFalse);
  });
  testWidgets('twenty records render before show more action', (tester) async {
    final repo = HistoryScreenRepository();
    final connection = FakeConnectivity();
    addTearDown(repo.close);
    addTearDown(connection.changes.close);
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add(
      List.generate(21, (index) => entry(id: 'answer-$index')),
    );
    await historyFrames(tester);
    final showMore = find.text('Mostrar más');
    await tester.scrollUntilVisible(showMore, 400);
    await tester.pump();
    await tester.tap(showMore);
    await historyFrames(tester);
    expect(showMore, findsNothing);
    expect(repo.areaReads, 1);
    expect(repo.topicReads, 1);
    expect(repo.quizReads, 1);
  });
  testWidgets('AWS pages load only after available rows have been revealed', (
    tester,
  ) async {
    final repo = HistoryScreenRepository();
    final connection = FakeConnectivity();
    addTearDown(repo.close);
    addTearDown(connection.changes.close);
    repo.hasNextPage = true;
    repo.pageGate = Completer<void>();
    repo.nextEntries = List.generate(22, (index) => entry(id: 'answer-$index'));
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add(repo.nextEntries.take(21).toList());
    await historyFrames(tester);
    final more = find.text('Mostrar más');
    await tester.scrollUntilVisible(more, 400);
    await tester.tap(more);
    await historyFrames(tester);
    expect(repo.pageLoads, 0);
    await tester.scrollUntilVisible(more, 400);
    await tester.tap(more);
    await historyFrames(tester);
    expect(repo.pageLoads, 1);
    expect(find.text('Cargando más…'), findsOneWidget);
    expect(find.text('Pregunta de prueba'), findsWidgets);
    repo.pageGate!.complete();
    await historyFrames(tester);
    expect(find.text('Cargando más…'), findsNothing);
    expect(more, findsNothing);
  });
  testWidgets('offline preserves already loaded records', (tester) async {
    final repo = HistoryScreenRepository();
    final connection = FakeConnectivity();
    addTearDown(repo.close);
    addTearDown(connection.changes.close);
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    connection.setOnline(false);
    await historyFrames(tester);
    expect(find.text('Pregunta de prueba'), findsOneWidget);
    expect(
      find.text('Sin conexión. Mostrando datos ya cargados.'),
      findsOneWidget,
    );
  });
  testWidgets('list discards previous user records on session switch', (
    tester,
  ) async {
    final repo = HistoryScreenRepository();
    final connection = FakeConnectivity();
    addTearDown(repo.close);
    addTearDown(connection.changes.close);
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    repo.changeUser('bob');
    await historyFrames(tester);
    expect(find.text('Pregunta de prueba'), findsNothing);
    expect(repo.historyReads, ['alice', 'bob']);
    repo.histories['bob']!.add([]);
    await historyFrames(tester);
    expect(find.text('Aún no hay actividades'), findsOneWidget);
  });
}
