import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(find.text('Cargando…'), findsOneWidget);
    repo.histories['alice']!.add([]);
    await historyFrames(tester);
    expect(find.text('Aún no hay actividades'), findsOneWidget);
    expect(find.text('Mi historial'), findsOneWidget);
  });
  testWidgets('real saved values and catalog names without identifiers', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Pregunta de prueba'), findsOneWidget);
    expect(find.text('Área de prueba · Tema de prueba'), findsOneWidget);
    expect(find.text('Intento 2'), findsOneWidget);
    expect(find.text('2 / 2 estrellas'), findsOneWidget);
    expect(find.text('11/10/2026 12:30'), findsOneWidget);
    expect(find.textContaining('private-record'), findsNothing);
  });
  testWidgets('detail route shows saved result and absent duration honestly', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    await tester.tap(find.text('Pregunta de prueba'));
    await tester.pump(const Duration(milliseconds: 500));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Resultado'), findsWidgets);
    expect(find.text('No registrado'), findsOneWidget);
    expect(find.text('Correcta'), findsWidgets);
    expect(find.text('Historial'), findsWidgets);
  });
  testWidgets('deleted retained record becomes unavailable in detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      historyScreen(repo, connection, entryId: 'private-record'),
    );
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Pregunta de prueba'), findsOneWidget);
    repo.histories['alice']!.add([]);
    await historyFrames(tester);
    expect(find.text('Resultado no disponible'), findsOneWidget);
    expect(find.text('Pregunta de prueba'), findsNothing);
  });
  testWidgets('server error is not rendered as empty and retry starts read', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.addError(StateError('private internal message'));
    await historyFrames(tester);
    expect(
      find.text('No se pudo cargar tu historial. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.textContaining('private internal'), findsNothing);
    expect(find.text('Aún no hay actividades'), findsNothing);
    await tester.tap(find.text('Reintentar'));
    await historyFrames(tester);
    expect(repo.historyReads, ['alice', 'alice']);
  });
  testWidgets('offline network failure uses offline state', (tester) async {
    connection.online = false;
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.addError(const SocketException('network'));
    await historyFrames(tester);
    expect(find.text('Sin conexión a Internet'), findsOneWidget);
  });
  testWidgets('access revoked clears previously delivered entries', (
    tester,
  ) async {
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    repo.histories['alice']!.addError(
      FirebaseException(plugin: 'test', code: 'permission-denied'),
    );
    await historyFrames(tester);
    expect(
      find.text('No tienes permiso para ver este contenido.'),
      findsOneWidget,
    );
    expect(find.text('Pregunta de prueba'), findsNothing);
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
    expect(find.text('Pregunta de prueba'), findsNothing);
    expect(
      find.text('Inicia sesión para acceder a este historial.'),
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
      find.text('Inicia sesión para acceder a este historial.'),
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
    expect(find.text('Quiz no disponible'), findsOneWidget);
    expect(
      find.text('Área no disponible · Tema no disponible'),
      findsOneWidget,
    );
    expect(find.text('Fecha no disponible'), findsOneWidget);
  });
  testWidgets('missing area name never exposes document fallback ID', (
    tester,
  ) async {
    repo.areaName = 'a';
    await tester.pumpWidget(historyScreen(repo, connection));
    repo.histories['alice']!.add([entry()]);
    await historyFrames(tester);
    expect(find.text('Área no disponible · Tema de prueba'), findsOneWidget);
    expect(find.text('a · Tema de prueba'), findsNothing);
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
        find.text('Algunos nombres no están disponibles.'),
        findsOneWidget,
      );
      expect(find.text('2 / 2 estrellas'), findsOneWidget);
      repo.catalogError = null;
      await tester.tap(find.text('Reintentar'));
      await historyFrames(tester);
      expect(repo.areaReads, 2);
      expect(find.text('Área de prueba · Tema de prueba'), findsOneWidget);
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
