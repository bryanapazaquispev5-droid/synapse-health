// ============================================================================
// File: profile_notifications_tile_test.dart
// Purpose: Modular UI component [profile_notifications_tile_test] for displaying user data and settings.
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

    expect(find.text('LOCAL NOTIFICATIONS'), findsOneWidget);
    expect(find.text('View Device FCM Token'), findsNothing);
    expect(find.text('Test Local Notification'), findsOneWidget);
  });
}
