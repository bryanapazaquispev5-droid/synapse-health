// ============================================================================
// File: auth_action_buttons.dart
// Purpose: Supporting visual widget [auth_action_buttons] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';

// Main definition of class [AuthActionButtons]
class AuthActionButtons extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final bool isLockoutActive;
  final int lockoutSeconds;
  final VoidCallback onSubmitEmailAuth;
  final VoidCallback? onGuestSignIn;

  const AuthActionButtons({
    super.key,
    required this.isLogin,
    required this.isLoading,
    required this.isLockoutActive,
    required this.lockoutSeconds,
    required this.onSubmitEmailAuth,
    this.onGuestSignIn,
  });

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary iOS button
        SizedBox(
          height: 50,
          child: CupertinoButton.filled(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(14),
            onPressed: (isLoading || isLockoutActive)
                ? null
                : onSubmitEmailAuth,
            child: isLoading
                ? const CupertinoActivityIndicator(color: AppColors.surface)
                : isLockoutActive
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.lock_fill,
                        size: 18,
                        color: AppColors.surface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Locked ($lockoutSeconds s)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surface,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'Sign In' : 'Create Medical Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.surface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        CupertinoIcons.arrow_right,
                        size: 16,
                        color: AppColors.surface,
                      ),
                    ],
                  ),
          ),
        ),
        if (onGuestSignIn != null) ...[
          const SizedBox(height: 18),
          Center(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: isLoading ? null : onGuestSignIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    CupertinoIcons.person_crop_circle,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Continue as Guest (Test Mode)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
