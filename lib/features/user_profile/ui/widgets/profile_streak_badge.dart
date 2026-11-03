// ============================================================================
// File: profile_streak_badge.dart
// Purpose: Modular interface component [profile_streak_badge] for displaying user data and settings.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Main definition of class [ProfileStreakBadge]
class ProfileStreakBadge extends StatelessWidget {
  final int streakDays;

  const ProfileStreakBadge({super.key, required this.streakDays});

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.6),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/fire.gif', width: 18, height: 18, fit: BoxFit.contain),
          const SizedBox(width: 5),
          Text(
            '$streakDays days',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
