import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum PasswordStrength { none, weak, medium, strong }

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.none;
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
    final activeSegments = s == PasswordStrength.weak
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
          Text(
            _getLabel(s),
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