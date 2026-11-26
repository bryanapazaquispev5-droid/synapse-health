import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/academic_history/ui/academic_history_screen.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';
import '../personal_progress/personal_progress_widget_fixture.dart';
import 'academic_history_screen_fixture.dart';

void main() {
  testWidgets('Progress shows chronological history and filters in place', (
    tester,
  ) async {
    final progress = WidgetProgressRepository();
    final history = HistoryScreenRepository()
      ..extraAreaNames = {'b': 'Pediatría'};
    final connection = FakeConnectivity();
    addTearDown(progress.close);
    addTearDown(history.close);
    addTearDown(connection.changes.close);

    await tester.pumpWidget(
      screen(progress, connection, historyRepository: history),
    );
    progress.sources['alice']!.add({});
    final answers = [
      entry(id: 'old', date: DateTime(2026, 10, 10), isCorrect: false),
      entry(id: 'new', date: DateTime(2026, 10, 12), areaId: 'b'),
      entry(id: 'undated', dated: false),
    ];
    history.histories['alice']!.add(answers);
    await tester.pumpAndSettle();
    await tapProgressHistoryControl(tester, find.text('Recientes'));
    final oldDate = find.text('10 oct 2026');
    final newDate = find.text('12 oct 2026');
    final undated = find.text('Fecha no disponible');
    expect(find.text('Ranking global'), findsOneWidget);
    expect(find.text('Actividad'), findsOneWidget);
    expect(find.byType(AcademicHistoryScreen), findsNothing);
    expect(
      tester.getTopLeft(newDate).dy,
      lessThan(tester.getTopLeft(oldDate).dy),
    );
    expect(
      tester.getTopLeft(oldDate).dy,
      lessThan(tester.getTopLeft(undated).dy),
    );

    await tester.ensureVisible(find.text('Incorrectas'));
    await tester.tap(find.text('Incorrectas'));
    await tester.pumpAndSettle();
    expect(oldDate, findsOneWidget);
    expect(newDate, findsNothing);
    expect(undated, findsNothing);
    expect(find.text('0/2 estrellas'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar por área'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pediatría'));
    await tester.pumpAndSettle();
    expect(find.text('Sin coincidencias'), findsOneWidget);
    await tester.tap(find.text('Correctas'));
    await tester.pumpAndSettle();
    expect(newDate, findsOneWidget);
    expect(oldDate, findsNothing);
    expect(find.byType(AcademicHistoryScreen), findsNothing);
    expect(history.historyReads, ['alice']);
  });

  testWidgets('Progress gives each result a detail and blocks stale identity', (
    tester,
  ) async {
    final progress = WidgetProgressRepository();
    final history = HistoryScreenRepository();
    final connection = FakeConnectivity();
    addTearDown(progress.close);
    addTearDown(history.close);
    addTearDown(connection.changes.close);

    await tester.pumpWidget(
      screen(progress, connection, historyRepository: history),
    );
    progress.sources['alice']!.add({});
    final answer = entry();
    history.histories['alice']!.add([answer]);
    await tester.pumpAndSettle();
    await tapProgressHistoryControl(tester, find.text('Recientes'));
    final row = find.text('Pregunta de prueba');
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final detail = tester.widget<AcademicHistoryScreen>(
      find.byType(AcademicHistoryScreen),
    );
    expect(detail.entryId, answer.id);
    expect(detail.expectedUid, 'alice');
    history.histories['alice']!.add([answer]);
    await historyFrames(tester);
    expect(find.text('Estrellas obtenidas'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    history.user = HistoryTestUser('bob');
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(AcademicHistoryScreen), findsNothing);
    progress.changeUser('bob');
    await historyFrames(tester);
    expect(row, findsNothing);
    expect(history.histories['alice']!.hasListener, isFalse);
    expect(history.historyReads.last, 'bob');
  });

  testWidgets('Progress reveals more results on a narrow large-text screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final progress = WidgetProgressRepository();
    final history = HistoryScreenRepository();
    final connection = FakeConnectivity();
    addTearDown(progress.close);
    addTearDown(history.close);
    addTearDown(connection.changes.close);

    await tester.pumpWidget(
      screen(
        progress,
        connection,
        historyRepository: history,
        textScaler: const TextScaler.linear(2.0),
      ),
    );
    progress.sources['alice']!.add({'t': recordedProgress(history: true)});
    history.histories['alice']!.add([
      for (var index = 0; index < 6; index++)
        entry(id: 'row-$index', date: DateTime(2026, 10, 11 - index)),
    ]);
    await tester.pumpAndSettle();
    await tapProgressHistoryControl(tester, find.text('Recientes'));
    final showMore = find.text('Mostrar más');
    final lastDate = find.text('6 oct 2026');
    expect(lastDate, findsNothing);
    final scrollable = find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(showMore, 270, scrollable: scrollable);
    await Scrollable.ensureVisible(tester.element(showMore), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(showMore);
    await tester.pumpAndSettle();
    expect(lastDate, findsOneWidget);
    expect(showMore, findsNothing);
    expect(tester.takeException(), isNull);
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
