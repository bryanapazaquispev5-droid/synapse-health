// Section: Settings modal with a translucent action sheet design
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/auth/app_auth.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../quizzes/api/quiz_progress_service.dart';

// Section: Static presenter for the settings modal sheet
class ProfileSettingsSheet {
  static void show({required BuildContext context}) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: const Color(0x5A000000),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, anim, secAnim) => const _SettingsSheetContent(),
      transitionBuilder: (context, anim, secAnim, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic),
        ),
        child: Align(alignment: Alignment.bottomCenter, child: child),
      ),
    );
  }
}

// Section: Inner content of the translucent settings modal
class _SettingsSheetContent extends StatelessWidget {
  const _SettingsSheetContent();

  Widget _buildWaveSwitch() => ValueListenableBuilder<bool>(
    valueListenable: AppSettingsService().isLiquidWaveEnabled,
    builder: (context, on, _) => CupertinoSwitch(
      value: on,
      activeTrackColor: AppColors.accent,
      onChanged: (v) {
        HapticFeedback.lightImpact();
        AppSettingsService().setLiquidWaveEnabled(v);
      },
    ),
  );

  Future<void> _confirmResetProgress(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reiniciar progreso'),
        content: const Text(
          '¿Deseas reiniciar tu progreso de quizzes y estrellas para comenzar de nuevo?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      try {
        await QuizProgressService().resetAllProgress();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progreso académico reiniciado correctamente.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al reiniciar: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar permanentemente tu cuenta y datos en DynamoDB? Esta acción no se puede deshacer.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      HapticFeedback.heavyImpact();
      Navigator.pop(context);
      await AppAuth.instance.deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final cardColor = const Color(0xFFFFFFFF).withValues(alpha: 0.90);
    const divider = Divider(height: 0.5, thickness: 0.5, color: AppColors.border);

    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: '.SF Pro Text', decoration: TextDecoration.none, color: AppColors.primary),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: bottomPadding > 0 ? 8 : 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('System Settings', textAlign: TextAlign.center, style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                            SizedBox(height: 4),
                            Text('Customize animations, progress and account data', textAlign: TextAlign.center, style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 13, color: AppColors.textMuted)),
                          ]),
                        ),
                        divider,
                        _buildRow(
                          icon: CupertinoIcons.waveform_path,
                          iconColor: AppColors.accent,
                          title: 'Wave Transition',
                          subtitle: 'Efecto fluido entre menús',
                          trailing: _buildWaveSwitch(),
                        ),
                        divider,
                        _buildRow(
                          icon: CupertinoIcons.arrow_counterclockwise_circle_fill,
                          iconColor: AppColors.systemOrange,
                          title: 'Reiniciar Progreso',
                          subtitle: 'Borrar historial y estrellas de quizzes',
                          trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.textMuted),
                          onTap: () => _confirmResetProgress(context),
                        ),
                        divider,
                        _buildRow(
                          icon: CupertinoIcons.trash_fill,
                          iconColor: AppColors.systemRed,
                          title: 'Eliminar Cuenta',
                          subtitle: 'Borrar usuario y perfil en DynamoDB',
                          trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.textMuted),
                          onTap: () => _confirmDeleteAccount(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Material(
                    color: cardColor,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      highlightColor: const Color(0xFFE5E5EA).withValues(alpha: 0.5),
                      splashColor: Colors.transparent,
                      child: const SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Center(
                          child: Text('Done', style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accent)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontFamily: '.SF Pro Text', fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
        trailing,
      ]),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, highlightColor: const Color(0xFFE5E5EA).withValues(alpha: 0.5), splashColor: Colors.transparent, child: content),
    );
  }
}
