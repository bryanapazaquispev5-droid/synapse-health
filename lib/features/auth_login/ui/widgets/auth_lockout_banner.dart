import 'package:flutter/cupertino.dart';

class AuthLockoutBanner extends StatelessWidget {
  final int failedAttemptsCount;
  final int lockoutSeconds;

  const AuthLockoutBanner({
    super.key,
    required this.failedAttemptsCount,
    required this.lockoutSeconds,
  });

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
              'Demasiados intentos fallidos ($failedAttemptsCount). Espera $lockoutSeconds segundos...',
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
