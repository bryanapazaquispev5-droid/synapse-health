import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum PasswordStrength { NONE, FORBIDDEN, WEAK, MEDIUM, STRONG }

class PasswordStrengthBar extends StatelessWidget {
  final String password;
  final String? email;

  const PasswordStrengthBar({
    super.key,
    required this.password,
    this.email,
  });

  bool get _isSameAsEmail {
    if (email == null || email!.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }
    final cleanEmail = email!.trim().toLowerCase();
    final cleanPass = password.trim().toLowerCase();

    if (cleanPass == cleanEmail) return true;

    if (cleanEmail.contains('@')) {
      final prefix = cleanEmail.split('@')[0];
      if (prefix.length >= 3 && cleanPass == prefix) {
        return true;
      }
    }
    return false;
  }

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.NONE;
    if (_isSameAsEmail) return PasswordStrength.FORBIDDEN;

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
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
        return const Color(0xFFEF4444); // Rojo
      case PasswordStrength.MEDIUM:
        return const Color(0xFFF59E0B); // Ambar / Naranja
      case PasswordStrength.STRONG:
        return const Color(0xFF10B981); // Verde
      case PasswordStrength.NONE:
        return AppColors.border;
    }
  }

  String _formatStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.FORBIDDEN:
        return '¡Peligro! La contraseña no puede ser igual a tu correo';
      case PasswordStrength.WEAK:
        return 'Seguridad: Débil (Agrega números y mayúsculas)';
      case PasswordStrength.MEDIUM:
        return 'Seguridad: Media (Agrega símbolos o más longitud)';
      case PasswordStrength.STRONG:
        return 'Seguridad: Fuerte (Excelente contraseña médica)';
      case PasswordStrength.NONE:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final currentStrength = strength;
    final strengthColor = _calculateStrengthColor(currentStrength);
    final activeSegmentsCount = (currentStrength == PasswordStrength.WEAK || currentStrength == PasswordStrength.FORBIDDEN)
        ? 1
        : currentStrength == PasswordStrength.MEDIUM
            ? 2
            : 3;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index < activeSegmentsCount;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0.0),
                  decoration: BoxDecoration(
                    color: isActive ? strengthColor : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (currentStrength == PasswordStrength.FORBIDDEN) ...[
                const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  _formatStrengthLabel(currentStrength),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: strengthColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}