// ============================================================================
// File: auth_lockout_banner.dart
// Purpose: Security manager to prevent brute-force attacks with temporary lockouts after failed attempts.
// ============================================================================

import 'package:flutter/cupertino.dart';

// Main definition of class [AuthLockoutBanner]
class AuthLockoutBanner extends StatelessWidget {
  final int failedAttemptsCount;
  final int lockoutSeconds;

  const AuthLockoutBanner({
    super.key,
    required this.failedAttemptsCount,
    required this.lockoutSeconds,
  });

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.timer, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Too many failed attempts ($failedAttemptsCount). Wait $lockoutSeconds seconds...',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF991B1B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
