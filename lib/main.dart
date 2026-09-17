// ============================================================================
// Archivo: main.dart
// Propósito: Punto de entrada principal de Synapse Health. Inicializa Firebase, Crashlytics, Performance, FCM y orquesta el árbol de widgets raíz.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/notifications/services/push_notification_service.dart';
import 'core/services/app_settings_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/performance_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth_login/ui/auth_screen.dart';
import 'features/navigation/ui/main_navigation_wrapper.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloque: Inicialización de la infraestructura Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Bloque: Inicialización de servicios de telemetría y observabilidad en tiempo real
  await CrashlyticsService.initialize();
  await PerformanceService.initialize();
  await AppSettingsService().init();

  // Bloque: Inicialización de canales FCM y orquestador de notificaciones push
  await PushNotificationService().initialize(
    navigatorKey: appNavigatorKey,
  );

  // Bloque: Configuración de seguridad volátil (desactivación de persistencia en disco)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  // Bloque: Lanzamiento de la aplicación raíz en el framework
  runApp(const SynapseHealthApp());
}

/// Componente de interfaz de usuario reutilizable [SynapseHealthApp].
class SynapseHealthApp extends StatelessWidget {
  const SynapseHealthApp({super.key});

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Synapse Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
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
          if (user == null) {
            return const AuthScreen();
          }

          return MainNavigationWrapper(user: user);
        },
      ),
    );
  }
}
