// ============================================================================
// File: welcome_profile_card.dart
// Purpose: Supporting visual widget [welcome_profile_card] for the sign-in and registration form flow.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/app_auth.dart';
import '../../../../core/theme/app_theme.dart';

// Modular visual component [WelcomeProfileCard]
class WelcomeProfileCard extends StatelessWidget {
  final AppUser user;
  final String name;
  final String email;
  final String career;
  final int streak;
  final bool isAnonymous;

  const WelcomeProfileCard({
    super.key,
    required this.user,
    required this.name,
    required this.email,
    required this.career,
    required this.streak,
    required this.isAnonymous,
  });

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlight ? const Color(0xFFFF9500) : AppColors.accent,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlight ? const Color(0xFFFF9500) : AppColors.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Reactive widget tree rendering
  // Section: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          user.photoURL != null
              ? CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(user.photoURL!),
                  backgroundColor: AppColors.border,
                )
              : CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: CupertinoIcons.book,
                  label: 'Especialidad',
                  value: career,
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(
                child: _buildInfoItem(
                  icon: CupertinoIcons.flame_fill,
                  label: 'Study Streak',
                  value: '$streak days',
                  isHighlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAnonymous ? CupertinoIcons.person : CupertinoIcons.mail,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Text(
                  isAnonymous
                      ? 'Guest Access'
                      : 'Email and Password Account',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
