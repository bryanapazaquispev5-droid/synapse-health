// ============================================================================
// Archivo: profile_notifications_tile_test.dart
// Propósito: Componente de interfaz modular [profile_notifications_tile_test] para la visualizacion de datos de usuario y ajustes.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/user_profile/ui/widgets/profile_notifications_tile.dart';

void main() {
  testWidgets('ProfileNotificationsTile renders local notification options without FCM token',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ProfileNotificationsTile(),
          ),
        ),
      ),
    );

    expect(find.text('NOTIFICACIONES LOCALES'), findsOneWidget);
    expect(find.text('Ver Token FCM del Dispositivo'), findsNothing);
    expect(find.text('Probar Notificación Local'), findsOneWidget);
  });
}
