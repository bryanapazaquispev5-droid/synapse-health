// Bloque: Componente modal de ajustes con estilo translúcido de acción
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/app_settings_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'profile_fcm_token_dialog.dart';

// Bloque: Presentador estático de la hoja modal de ajustes
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

// Bloque: Contenido interno del modal translúcido de ajustes
class _SettingsSheetContent extends StatelessWidget {
  const _SettingsSheetContent();

  void _openTokenDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    ProfileFcmTokenDialog.show(context: context);
  }

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

  // Bloque: Construcción del árbol de widgets con diseño idéntico a OpaqueActionSheet
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
                            Text('Ajustes del Sistema', textAlign: TextAlign.center, style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                            SizedBox(height: 4),
                            Text('Personaliza animaciones y notificaciones Firebase', textAlign: TextAlign.center, style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 13, color: AppColors.textMuted)),
                          ]),
                        ),
                        divider,
                        _buildRow(
                          icon: CupertinoIcons.waveform_path,
                          iconColor: AppColors.accent,
                          title: 'Transición tipo Ola',
                          subtitle: 'Efecto líquido entre menús',
                          trailing: _buildWaveSwitch(),
                        ),
                        divider,
                        _buildRow(
                          icon: CupertinoIcons.device_phone_portrait,
                          iconColor: AppColors.accent,
                          title: 'Token FCM del Dispositivo',
                          subtitle: 'Consultar y copiar token Firebase',
                          trailing: const Icon(CupertinoIcons.chevron_forward, size: 14, color: Color(0xFFC7C7CC)),
                          onTap: () => _openTokenDialog(context),
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
                          child: Text('Listo', style: TextStyle(fontFamily: '.SF Pro Text', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accent)),
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

  // Bloque: Constructor de fila de acción modular
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
