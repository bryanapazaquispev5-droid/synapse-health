import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/services/app_settings_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/performance_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth_login/ui/auth_screen.dart';
import 'features/navigation/ui/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar Observabilidad y Monitoreo en Tiempo Real
  await CrashlyticsService.initialize();
  await PerformanceService.initialize();
  await AppSettingsService().init();

  // DESACTIVAR PERSISTENCIA EN DISCO (Seguridad y protección contra ingeniería inversa)
  // Todo el contenido médico y chuletas residen únicamente en memoria volátil (RAM)
  // y requieren conexión activa a internet para ser consultados.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );
  runApp(const SynapseHealthApp());
}

class SynapseHealthApp extends StatelessWidget {
  const SynapseHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

          // Usuario autenticado (con persistencia de sesión segura en Firebase Auth)
          return MainNavigationWrapper(user: user);
        },
      ),
    );
  }
}