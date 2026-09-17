import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_health/core/theme/app_theme.dart';
import 'package:synapse_health/features/user_profile/ui/widgets/profile_notifications_tile.dart';

void main() {
  testWidgets('ProfileNotificationsTile renders FCM token and local notification options',
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

    expect(find.text('NOTIFICACIONES PUSH & FCM'), findsOneWidget);
    expect(find.text('Ver Token FCM del Dispositivo'), findsOneWidget);
    expect(find.text('Probar Notificación Local'), findsOneWidget);
  });
}
