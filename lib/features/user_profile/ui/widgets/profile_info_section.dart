// ============================================================================
// File: profile_info_section.dart
// Purpose: Modular interface component [profile_info_section] for displaying user data and settings.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

// Main definition of class [ProfileInfoSection]
class ProfileInfoSection extends StatelessWidget {
  final String career;
  final String gender;
  final String uid;
  final VoidCallback onEditCareer;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onShowFeedback;

  const ProfileInfoSection({
    super.key,
    required this.career,
    required this.gender,
    required this.uid,
    required this.onEditCareer,
    required this.onOpenSettings,
    required this.onShowFeedback,
  });

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, top: 22, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildAppleListTile({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ] else if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Reactive widget tree rendering
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('MEDICAL INFORMATION'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.6),
            ),
            child: Column(
              children: [
                _buildAppleListTile(
                  icon: CupertinoIcons.book_fill,
                  iconBgColor: AppColors.accent,
                  title: 'Especialidad',
                  value: career,
                  onTap: onEditCareer,
                ),
                const Divider(height: 0.5, indent: 54, color: AppColors.border),
                _buildAppleListTile(
                  icon: CupertinoIcons.person_2_fill,
                  iconBgColor: AppColors.systemPink,
                  title: 'Gender',
                  value: gender,
                  onTap: null, // Read-only: gender is immutable once chosen
                ),
              ],
            ),
          ),
        ),
        _buildSectionHeader('SEGURIDAD Y ACCESO'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.6),
            ),
            child: Column(
              children: [
                _buildAppleListTile(
                  icon: CupertinoIcons.person_badge_plus_fill,
                  iconBgColor: AppColors.systemIndigo,
                  title: 'Student ID',
                  value: uid.length >= 8 ? '${uid.substring(0, 8)}...' : uid,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: uid));
                    onShowFeedback('ID copiado al portapapeles');
                  },
                  trailing: const Icon(
                    CupertinoIcons.doc_on_doc,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),
                const Divider(height: 0.5, indent: 54, color: AppColors.border),
                _buildAppleListTile(
                  icon: CupertinoIcons.lock_shield_fill,
                  iconBgColor: const Color(0xFF636366),
                  title: 'Proveedor',
                  value: 'Email',
                ),
                const Divider(height: 0.5, indent: 54, color: AppColors.border),
                _buildAppleListTile(
                  icon: CupertinoIcons.gear_alt_fill,
                  iconBgColor: const Color(0xFF8E8E93),
                  title: 'Settings',
                  value: 'Personalizar',
                  onTap: onOpenSettings,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
