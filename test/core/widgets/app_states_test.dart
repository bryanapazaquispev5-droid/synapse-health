import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/core/widgets/states/app_states.dart';

Widget app(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  testWidgets(
    'loading presents Cupertino indicator and accessible description',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        app(const AppLoadingState(message: 'Cargando fichas')),
      );
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.text('Cargando fichas'), findsOneWidget);
      expect(find.bySemanticsLabel('Cargando fichas'), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets(
    'compact loading fits a partial operation without full-page layout',
    (tester) async {
      await tester.pumpWidget(
        app(
          const SizedBox(
            width: 32,
            height: 32,
            child: AppLoadingState(compact: true),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.text('Cargando…'), findsNothing);
    },
  );

  testWidgets('empty content shows contextual copy and action', (tester) async {
    var cleared = 0;
    await tester.pumpWidget(
      app(
        AppEmptyState(
          title: 'Sin resultados',
          message: 'Prueba con otro término.',
          actionLabel: 'Limpiar búsqueda',
          onAction: () => cleared++,
        ),
      ),
    );
    expect(find.text('Sin resultados'), findsOneWidget);
    expect(find.text('Prueba con otro término.'), findsOneWidget);
    await tester.tap(find.text('Limpiar búsqueda'));
    expect(cleared, 1);
  });

  for (final offline in [false, true]) {
    testWidgets(
      '${offline ? 'offline' : 'error'} presents safe copy and retries',
      (tester) async {
        var retries = 0;
        await tester.pumpWidget(
          app(
            offline
                ? AppOfflineState(onRetry: () => retries++)
                : AppErrorState(
                    message: 'No se pudieron cargar las fichas.',
                    onRetry: () => retries++,
                  ),
          ),
        );
        expect(
          find.text(
            offline
                ? 'Sin conexión a Internet'
                : 'No se pudo cargar el contenido',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Reintentar'));
        expect(retries, 1);
      },
    );
  }

  testWidgets('nonrecoverable error does not advertise a retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const AppErrorState(
          message: 'No tienes permiso para ver este contenido.',
        ),
      ),
    );
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets(
    'large accessibility text and compact viewport remain scrollable',
    (tester) async {
      tester.view.physicalSize = const Size(320, 240);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: AppOfflineState(onRetry: () {}),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await tester.ensureVisible(find.text('Reintentar'));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'states also support sliver layouts without intrinsic sizing errors',
    (tester) async {
      for (final state in [
        const AppLoadingState(),
        const AppEmptyState(
          title: 'Sin fichas',
          message: 'Todavía no hay fichas.',
        ),
        AppErrorState(onRetry: () {}),
        AppOfflineState(onRetry: () {}),
      ]) {
        await tester.pumpWidget(
          app(
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: Text('Fichas')),
                SliverFillRemaining(hasScrollBody: false, child: state),
              ],
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    },
  );
}
