import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/widgets/states/app_async_content.dart';
import 'package:synapse_health/features/personal_progress/ui/widgets/progress_meter.dart';

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
    expect(find.text('Tu progreso empieza aquí'), findsOneWidget);
    expect(find.text('Ranking global'), findsOneWidget);
    expect(find.text('Estrellas actuales'), findsNothing);
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
    final scrollable = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byType(Scrollable),
    ).first;
    await tester.scrollUntilVisible(
      find.text('Área de prueba'),
      200,
      scrollable: scrollable,
    );
    await frames(tester);
    expect(find.text('Área de prueba'), findsOneWidget);
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
    await tester.tap(find.text('Ranking global'));
    await tester.pumpAndSettle();
    expect(find.text('Ranking conservado'), findsOneWidget);
    expect(uid, 'alice');
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 400));
    await frames(tester);
    expect(find.text('Progreso personal'), findsOneWidget);
  });

  for (final online in [true, false]) {
    testWidgets(
      'progress failure online=$online is never a new-user empty state',
      (tester) async {
        connection.online = online;
        await tester.pumpWidget(screen(repo, connection));
        await frames(tester);
        repo.sources['alice']!.addError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'internal detail',
          ),
        );
        await frames(tester);
        expect(
          find.byType(online ? AppErrorState : AppOfflineState),
          findsWidgets,
        );
        expect(find.text('Tu progreso empieza aquí'), findsNothing);
        expect(find.textContaining('internal detail'), findsNothing);
      },
    );
  }

  testWidgets('no valid session queries no progress', (tester) async {
    repo.changeUser(null);
    await tester.pumpWidget(screen(repo, connection));
    await frames(tester);
    expect(
      find.text('Inicia sesión para ver tu progreso personal.'),
      findsOneWidget,
    );
    expect(repo.reads, 0);
    expect(find.text('Ranking global'), findsNothing);
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
    expect(find.text('Tu progreso empieza aquí'), findsOneWidget);
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
      find.text('Sin conexión. Mostrando datos ya cargados.'),
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

  testWidgets('progress meter animates and respects reduced motion', (
    tester,
  ) async {
    Widget meter(bool reduceMotion) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: const Center(
          child: SizedBox(width: 200, child: ProgressMeter(percentage: 75)),
        ),
      ),
    );

    double fillWidth() => tester
        .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .widthFactor!;

    await tester.pumpWidget(meter(false));
    expect(fillWidth(), 0);
    await tester.pump(const Duration(milliseconds: 120));
    expect(fillWidth(), inExclusiveRange(0, .75));
    await tester.pumpAndSettle();
    expect(fillWidth(), .75);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(meter(true));
    expect(fillWidth(), .75);
  });
}
