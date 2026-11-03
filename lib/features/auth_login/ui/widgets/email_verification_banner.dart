// ============================================================================
// File: email_verification_banner.dart
// Purpose: Supporting visual widget [email_verification_banner] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/app_auth.dart';
import 'auth_code_dialog.dart';

// Main definition of [EmailVerificationBanner].
class EmailVerificationBanner extends StatelessWidget {
  final AppUser user;

  const EmailVerificationBanner({super.key, required this.user});

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.mail_solid,
            color: Color(0xFFD97706),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Verify your email address',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Verify your email to enable account recovery.',
                  style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            onPressed: () async {
              try {
                await user.sendEmailVerification();
                if (!context.mounted) return;
                await AuthCodeDialog.show(
                  context,
                  email: user.email ?? '',
                  isEmailVerification: true,
                  onResend: user.sendEmailVerification,
                  onSubmit: (code, _) => user.verifyEmail(code),
                );
                await user.reload();
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not verify email: $error')),
                  );
                }
              }
            },
            child: const Text(
              'Verify',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
