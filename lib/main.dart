// ============================================================================
// File: main.dart
// Purpose: Synapse Health entry point with AWS authentication and data services.
// ============================================================================

import 'package:flutter/material.dart';

import 'core/auth/app_auth.dart';

import 'core/notifications/handlers/notification_router.dart';
import 'core/notifications/services/local_notification_service.dart';
import 'core/services/app_settings_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth_login/ui/auth_screen.dart';
import 'features/auth_login/auth_session_gate.dart';
import 'features/auth_login/model/trial_mode_session.dart';
import 'features/trial_mode/ui/trial_mode_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppAuth.instance.initialize();
  await AppSettingsService().init();

  NotificationRouter.setNavigatorKey(appNavigatorKey);
  await LocalNotificationService().initialize();

  // Medical catalogs are served from AWS; this process keeps only transient UI data.
  runApp(const SynapseHealthApp());
}

// Main definition of [SynapseHealthApp].
class SynapseHealthApp extends StatelessWidget {
  const SynapseHealthApp({super.key});

  // Reactive rendering of the widget tree.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Synapse Health',
      locale: const Locale('en'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ValueListenableBuilder<bool>(
        valueListenable: TrialModeSession.active,
        builder: (context, trialActive, _) {
          if (trialActive) return const TrialModeScreen();
          return StreamBuilder<AppUser?>(
            stream: AppAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: AppColors.background,
                  body: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                );
              }
              final user = authSnapshot.data;
              if (user == null) return const AuthScreen();
              return AuthSessionGate(key: ValueKey(user.uid), user: user);
            },
          );
        },
      ),
    );
  }
}
