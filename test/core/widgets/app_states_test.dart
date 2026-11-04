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
        app(const AppLoadingState(message: 'Loading notes')),
      );
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.text('Loading notes'), findsOneWidget);
      expect(find.bySemanticsLabel('Loading notes'), findsOneWidget);
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
      expect(find.text('Loading…'), findsNothing);
    },
  );

  testWidgets('empty content shows contextual copy and action', (tester) async {
    var cleared = 0;
    await tester.pumpWidget(
      app(
        AppEmptyState(
          title: 'No results',
          message: 'Try another term.',
          actionLabel: 'Clear search',
          onAction: () => cleared++,
        ),
      ),
    );
    expect(find.text('No results'), findsOneWidget);
    expect(find.text('Try another term.'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
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
                    message: 'Could not load the notes.',
                    onRetry: () => retries++,
                  ),
          ),
        );
        expect(
          find.text(
            offline
                ? 'No internet connection'
                : 'Could not load the content',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Retry'));
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
          message: 'You do not have permission to view this content.',
        ),
      ),
    );
    expect(find.text('Retry'), findsNothing);
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
      await tester.ensureVisible(find.text('Retry'));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'states also support sliver layouts without intrinsic sizing errors',
    (tester) async {
      for (final state in [
        const AppLoadingState(),
        const AppEmptyState(
          title: 'No notes',
          message: 'There are no notes yet.',
        ),
        AppErrorState(onRetry: () {}),
        AppOfflineState(onRetry: () {}),
      ]) {
        await tester.pumpWidget(
          app(
            CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: Text('Notes')),
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
