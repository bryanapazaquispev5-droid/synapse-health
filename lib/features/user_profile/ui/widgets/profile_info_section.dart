// ============================================================================
// Archivo: profile_info_section.dart
// Propósito: Componente de interfaz modular [profile_info_section] para la gestión y presentación de opciones de perfil.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Componente de interfaz de usuario reutilizable [ProfileInfoSection].
class ProfileInfoSection extends StatelessWidget {
  final String career;
  final String gender;
  final String uid;
  final bool isEmailVerified;
  final bool isAnonymous;
  final bool isGoogle;
  final VoidCallback onEditCareer;
  final VoidCallback onEditGender;
  final VoidCallback onResendEmail;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onShowFeedback;

  const ProfileInfoSection({
    super.key,
    required this.career,
    required this.gender,
    required this.uid,
    required this.isEmailVerified,
    required this.isAnonymous,
    required this.isGoogle,
    required this.onEditCareer,
    required this.onEditGender,
    required this.onResendEmail,
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
              const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
            ],
          ],
        ),
      ),
    );
  }

  // Bloque: Renderizado reactivo del árbol de widgets principal
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('INFORMACIÓN MÉDICA'),
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
                  title: 'Género',
                  value: gender,
                  onTap: onEditGender,
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
                  icon: CupertinoIcons.checkmark_seal_fill,
                  iconBgColor: isEmailVerified ? AppColors.systemGreen : AppColors.systemOrange,
                  title: 'Estado Médico',
                  value: isEmailVerified ? 'Verificado' : 'Pendiente',
                  trailing: isEmailVerified
                      ? const Icon(CupertinoIcons.checkmark_circle_fill, size: 18, color: AppColors.systemGreen)
                      : (!isAnonymous
                          ? CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: onResendEmail,
                              child: const Text('Reenviar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.systemOrange)),
                            )
                          : null),
                ),
                const Divider(height: 0.5, indent: 54, color: AppColors.border),
                _buildAppleListTile(
                  icon: CupertinoIcons.person_badge_plus_fill,
                  iconBgColor: AppColors.systemIndigo,
                  title: 'ID de Estudiante',
                  value: uid.length >= 8 ? '${uid.substring(0, 8)}...' : uid,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: uid));
                    onShowFeedback('ID copiado al portapapeles');
                  },
                  trailing: const Icon(CupertinoIcons.doc_on_doc, size: 16, color: AppColors.textMuted),
                ),
                const Divider(height: 0.5, indent: 54, color: AppColors.border),
                _buildAppleListTile(
                  icon: CupertinoIcons.lock_shield_fill,
                  iconBgColor: const Color(0xFF636366),
                  title: 'Proveedor',
                  value: isGoogle ? 'Google' : isAnonymous ? 'Invitado' : 'Correo',
                ),
                const Divider(height: 0.5, indent: 54, color: AppColors.border),
                _buildAppleListTile(
                  icon: CupertinoIcons.gear_alt_fill,
                  iconBgColor: const Color(0xFF8E8E93),
                  title: 'Ajustes',
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
