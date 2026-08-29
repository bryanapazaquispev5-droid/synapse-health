import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum PasswordStrength { none, forbidden, weak, medium, strong }

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
    if (password.isEmpty) return PasswordStrength.none;
    if (_isSameAsEmail) return PasswordStrength.forbidden;

    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 3) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Color _getColor(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.forbidden:
      case PasswordStrength.weak:
        return const Color(0xFFEF4444); // Rojo
      case PasswordStrength.medium:
        return const Color(0xFFF59E0B); // Ambar / Naranja
      case PasswordStrength.strong:
        return const Color(0xFF10B981); // Verde
      case PasswordStrength.none:
        return AppColors.border;
    }
  }

  String _getLabel(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.forbidden:
        return '¡Peligro! La contraseña no puede ser igual a tu correo';
      case PasswordStrength.weak:
        return 'Seguridad: Débil (Agrega números y mayúsculas)';
      case PasswordStrength.medium:
        return 'Seguridad: Media (Agrega símbolos o más longitud)';
      case PasswordStrength.strong:
        return 'Seguridad: Fuerte (Excelente contraseña médica)';
      case PasswordStrength.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final s = strength;
    final color = _getColor(s);
    final activeSegments = (s == PasswordStrength.weak || s == PasswordStrength.forbidden)
        ? 1
        : s == PasswordStrength.medium
            ? 2
            : 3;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index < activeSegments;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0.0),
                  decoration: BoxDecoration(
                    color: isActive ? color : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (s == PasswordStrength.forbidden) ...[
                const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  _getLabel(s),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
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