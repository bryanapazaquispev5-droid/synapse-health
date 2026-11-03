// ============================================================================
// File: auth_header_widget.dart
// Purpose: Supporting visual widget [auth_header_widget] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Modular visual component [AuthHeaderWidget]
class AuthHeaderWidget extends StatelessWidget {
  final bool isLogin;

  const AuthHeaderWidget({super.key, required this.isLogin});

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/app_logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          isLogin ? 'Sign In' : 'Create Account',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isLogin
              ? 'Access your study notes and quizzes'
              : 'Join to track your streak and progress',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
