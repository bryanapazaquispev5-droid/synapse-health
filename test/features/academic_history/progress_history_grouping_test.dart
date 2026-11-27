import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/features/academic_history/ui/academic_history_screen.dart';

import '../../core/widgets/fixtures/async_content_fixture.dart';
import '../personal_progress/personal_progress_widget_fixture.dart';
import 'academic_history_screen_fixture.dart';

void main() {
  late WidgetProgressRepository progress;
  late HistoryScreenRepository history;
  late FakeConnectivity connection;

  setUp(() {
    progress = WidgetProgressRepository();
    history = HistoryScreenRepository();
    connection = FakeConnectivity();
    addTearDown(progress.close);
    addTearDown(history.close);
    addTearDown(connection.changes.close);
  });

  testWidgets(
    'Activity opens collapsed by area and expands to the saved result',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      history.extraTopicNames = {('a', 'alternative'): 'Otro tema de prueba'};
      final dated = entry(date: DateTime(2026, 10, 11, 8, 45));
      final undated = entry(
        id: 'other-topic',
        topicId: 'alternative',
        dated: false,
      );

      await tester.pumpWidget(
        screen(
          progress,
          connection,
          historyRepository: history,
          textScaler: const TextScaler.linear(2),
        ),
      );
      progress.sources['alice']!.add({});
      history.histories['alice']!.add([undated, dated]);
      await tester.pumpAndSettle();

      final area = find.text('Área de prueba');
      final topic = find.text('Tema de prueba');
      final otherTopic = find.text('Otro tema de prueba');
      final question = find.text('Pregunta de prueba');
      final groupedView = find.text('Por área');
      final scrollable = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(groupedView, 220, scrollable: scrollable);
      expect(groupedView, findsOneWidget);
      expect(area, findsOneWidget);
      expect(topic, findsNothing);
      expect(question, findsNothing);

      await tapProgressHistoryControl(tester, area);
      expect(topic, findsOneWidget);
      expect(otherTopic, findsOneWidget);
      expect(question, findsNothing);
      expect(
        tester.getTopLeft(topic).dy,
        lessThan(tester.getTopLeft(otherTopic).dy),
      );
      await tapProgressHistoryControl(tester, topic);
      expect(question, findsOneWidget);
      expect(find.textContaining('11 oct 2026'), findsOneWidget);
      expect(find.textContaining('08:45'), findsOneWidget);
      expect(find.text('2/2 estrellas'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(question);
      await tester.tap(question);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final detail = tester.widget<AcademicHistoryScreen>(
        find.byType(AcademicHistoryScreen),
      );
      expect(detail.entryId, dated.id);
      expect(detail.expectedUid, 'alice');
      history.histories['alice']!.add([dated, undated]);
      await historyFrames(tester);
      expect(find.text('Stars earned'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Grouped Activity applies outcome filters and resets empty results',
    (tester) async {
      history.extraAreaNames = {'b': 'Pediatría'};
      await tester.pumpWidget(
        screen(progress, connection, historyRepository: history),
      );
      progress.sources['alice']!.add({});
      history.histories['alice']!.add([
        entry(id: 'incorrect', isCorrect: false, areaId: 'b'),
        entry(id: 'correct'),
      ]);
      await tester.pumpAndSettle();

      final primaryArea = find.text('Área de prueba');
      final otherArea = find.text('Pediatría');
      expect(primaryArea, findsOneWidget);
      expect(otherArea, findsOneWidget);
      expect(
        tester.getTopLeft(primaryArea).dy,
        lessThan(tester.getTopLeft(otherArea).dy),
      );

      await tapProgressHistoryControl(tester, find.text('Correctas'));
      expect(primaryArea, findsOneWidget);
      expect(otherArea, findsNothing);
      await tapProgressHistoryControl(tester, find.text('Incorrectas'));
      expect(primaryArea, findsNothing);
      expect(otherArea, findsOneWidget);

      history.histories['alice']!.add([
        entry(id: 'now-correct', areaId: 'b'),
        entry(id: 'correct'),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Sin coincidencias'), findsOneWidget);
      await tapProgressHistoryControl(tester, find.text('Ver todas'));
      expect(primaryArea, findsOneWidget);
      expect(otherArea, findsOneWidget);
      expect(find.text('Sin coincidencias'), findsNothing);
      expect(history.historyReads, ['alice']);
      expect(find.byType(AcademicHistoryScreen), findsNothing);
    },
  );

  testWidgets(
    'Grouped Activity retains answers with removed catalog metadata',
    (tester) async {
      history.hasCatalog = false;
      await tester.pumpWidget(
        screen(progress, connection, historyRepository: history),
      );
      progress.sources['alice']!.add({});
      history.histories['alice']!.add([entry(dated: false)]);
      await tester.pumpAndSettle();

      await tapProgressHistoryControl(tester, find.text('Área no disponible'));
      await tapProgressHistoryControl(tester, find.text('Tema no disponible'));
      expect(find.text('Quiz unavailable'), findsOneWidget);
      expect(find.text('Fecha no disponible'), findsOneWidget);
      expect(find.text('2/2 estrellas'), findsOneWidget);
    },
  );

  testWidgets(
    'Grouped Activity keeps loaded results and can fetch another page',
    (tester) async {
      final page = [
        for (var index = 0; index < 6; index++) entry(id: 'result-$index'),
      ];
      history.hasNextPage = true;
      history.nextEntries = [
        ...page,
        entry(id: 'next-page', date: DateTime(2026, 10, 8, 9, 15)),
      ];
      await tester.pumpWidget(
        screen(progress, connection, historyRepository: history),
      );
      progress.sources['alice']!.add({});
      history.histories['alice']!.add(page);
      await tester.pumpAndSettle();

      await tapProgressHistoryControl(tester, find.text('Área de prueba'));
      await tapProgressHistoryControl(tester, find.text('Tema de prueba'));
      final question = find.text('Pregunta de prueba');
      expect(question, findsNWidgets(6));
      expect(history.pageLoads, 0);

      final more = find.text('Mostrar más');
      await tapProgressHistoryControl(tester, more);
      expect(history.pageLoads, 1);
      expect(question, findsNWidgets(7));
      expect(find.textContaining('8 oct 2026'), findsOneWidget);
      expect(more, findsNothing);
    },
  );
}
