// ============================================================================
// File: widget_test.dart
// Purpose: Unit and widget test suite for validating [widget_test].
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';

void main() {
  testWidgets('Load Synapse Health Theme and Styles', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: Text('Synapse Health'))),
      ),
    );
    expect(find.text('Synapse Health'), findsOneWidget);
  });
}
