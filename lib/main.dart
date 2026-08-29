import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth_login/screens/auth_screen.dart';
import 'features/auth_login/screens/complete_profile_screen.dart';
import 'features/auth_login/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }
          final user = authSnapshot.data;
          if (user == null) {
            return const AuthScreen();
          }

          // Los invitados no requieren perfil formal
          if (user.isAnonymous) {
            return WelcomeScreen(user: user);
          }

          // Verificar si el usuario ya tiene su carrera registrada en Firestore
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, userDocSnapshot) {
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                );
              }

              final data = userDocSnapshot.data?.data();
              final String? career = data?['career'];

              // Si ingreso con Google por primera vez y aun no tiene carrera
              if (career == null || career.trim().isEmpty) {
                return CompleteProfileScreen(user: user);
              }

              return WelcomeScreen(user: user);
            },
          );
        },
      ),
    );
  }
}