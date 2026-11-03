// ============================================================================
// File: password_strength_bar.dart
// Purpose: Supporting visual widget [password_strength_bar] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../utils/auth_validators.dart';

// Enum defining the available [PasswordStrength] variants.
enum PasswordStrength { NONE, FORBIDDEN, WEAK, MEDIUM, STRONG }

// Modular visual component [PasswordStrengthBar]
class PasswordStrengthBar extends StatelessWidget {
  final String password;
  final String? email;

  const PasswordStrengthBar({
    super.key,
    required this.password,
    this.email,
  });

  bool get _isSameAsEmail {
    if (email == null || email!.isEmpty || password.isEmpty) return false;
    final cleanEmail = email!.toLowerCase().trim();
    final cleanPass = password.toLowerCase().trim();
    final emailPrefix = cleanEmail.contains('@') ? cleanEmail.split('@')[0] : '';

    return cleanPass == cleanEmail || (emailPrefix.length >= 3 && cleanPass == emailPrefix);
  }

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.NONE;
    if (_isSameAsEmail) return PasswordStrength.FORBIDDEN;
    if (AuthValidators.meetsCognitoPasswordPolicy(password)) {
      return PasswordStrength.STRONG;
    }

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;

    if (score <= 1) return PasswordStrength.WEAK;
    if (score <= 3) return PasswordStrength.MEDIUM;
    return PasswordStrength.STRONG;
  }

  Color _calculateStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.FORBIDDEN:
      case PasswordStrength.WEAK:
        return const Color(0xFFEF4444);
      case PasswordStrength.MEDIUM:
        return const Color(0xFFF59E0B);
      case PasswordStrength.STRONG:
        return const Color(0xFF10B981);
      case PasswordStrength.NONE:
        return AppColors.border;
    }
  }

  String _formatStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.FORBIDDEN:
        return 'Warning! Your password cannot match your email address';
      case PasswordStrength.WEAK:
        return 'Security: Weak (Add numbers and uppercase letters)';
      case PasswordStrength.MEDIUM:
        return 'Security: Medium (Add symbols or use a longer password)';
      case PasswordStrength.STRONG:
        return 'Security: Excellent for a medical account';
      case PasswordStrength.NONE:
        return '';
    }
  }

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    final currentStrength = strength;
    final color = _calculateStrengthColor(currentStrength);
    final label = _formatStrengthLabel(currentStrength);

    if (currentStrength == PasswordStrength.NONE) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: currentStrength == PasswordStrength.MEDIUM ||
                            currentStrength == PasswordStrength.STRONG
                        ? color
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: currentStrength == PasswordStrength.STRONG
                        ? color
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
