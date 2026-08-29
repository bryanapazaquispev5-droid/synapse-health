import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';

void main() {
  testWidgets('Carga de Tema y Estilos de Synapse Health', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: Text('Synapse Health'))),
      ),
    );
    expect(find.text('Synapse Health'), findsOneWidget);
  });
}