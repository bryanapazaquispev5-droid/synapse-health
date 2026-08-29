import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth_login/screens/auth_screen.dart';

void main() {
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
      home: const AuthScreen(),
    );
  }
}