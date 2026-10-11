import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('Sin fichas'), findsOneWidget);
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
      FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'private internal detail',
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.byType(AppOfflineState), findsNothing);
    expect(
      find.text('No tienes permiso para ver este contenido.'),
      findsOneWidget,
    );
    expect(find.textContaining('private internal'), findsNothing);
    expect(find.text('Reintentar'), findsNothing);
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
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.byType(online ? AppErrorState : AppOfflineState),
        findsOneWidget,
      );
      expect(find.byType(AppEmptyState), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
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
    tracked.add(['Anatomía']);
    await tester.pump();
    await tester.pump();
    connection.setOnline(false);
    await tester.pump();
    await tester.pump();
    expect(find.text('Anatomía'), findsOneWidget);
    expect(
      find.text('Sin conexión. Mostrando datos ya cargados.'),
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
    source.add(['Primero']);
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Actualizar'));
    await tester.pump();
    await tester.pump();
    expect(retries, 1);
    expect(find.text('Primero'), findsOneWidget);
    expect(find.byType(AppLoadingState), findsOneWidget);
    source.add(['Obsoleto']);
    await tester.pump();
    await tester.pump();
    expect(find.text('Obsoleto'), findsNothing);
    replacement.add(['Actualizado']);
    await tester.pump();
    await tester.pump();
    expect(find.text('Actualizado'), findsOneWidget);
    expect(find.text('Primero'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    addTearDown(replacement.close);
  });

  testWidgets('revoked authorization clears previously delivered content', (
    tester,
  ) async {
    await tester.pumpWidget(content(source.stream, connection));
    await tester.pump();
    await tester.pump();
    source.add(['Contenido privado']);
    await tester.pump();
    await tester.pump();
    source.addError(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Contenido privado'), findsNothing);
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
              snapshot.hasData ? 'Recibido: ${snapshot.data}' : 'Esperando',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Esperando'), findsOneWidget);
    progress.add(null);
    await tester.pump();
    await tester.pump();
    expect(find.text('Recibido: null'), findsOneWidget);
    expect(find.text('Esperando'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    addTearDown(progress.close);
  });
}
