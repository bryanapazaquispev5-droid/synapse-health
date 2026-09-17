import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/notifications/channels/notification_channels.dart';
import '../../../../core/notifications/models/push_notification_payload.dart';
import '../../../../core/notifications/services/local_notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'profile_fcm_token_dialog.dart';

/// Sección atómica para gestión y prueba de notificaciones Push (FCM) y locales.
class ProfileNotificationsTile extends StatefulWidget {
  const ProfileNotificationsTile({super.key});

  @override
  State<ProfileNotificationsTile> createState() => _ProfileNotificationsTileState();
}

class _ProfileNotificationsTileState extends State<ProfileNotificationsTile> {
  bool _isTestingNotification = false;

  void _openTokenDialog() {
    HapticFeedback.lightImpact();
    ProfileFcmTokenDialog.show(context: context);
  }

  Future<void> _sendTestNotification() async {
    if (_isTestingNotification) return;
    setState(() => _isTestingNotification = true);
    HapticFeedback.mediumImpact();

    try {
      final now = DateTime.now();
      final payload = PushNotificationPayload(
        id: 'test_alert_${now.millisecondsSinceEpoch}',
        title: '🚨 Alerta Médica de Prueba',
        body: 'Protocolo de código azul activo. Sonido y vibración verificados.',
        type: NotificationType.medicalAlert,
        channelId: NotificationChannels.medicalAlertsId,
        receivedAt: now,
        data: const {'type': 'medical_alert', 'is_test': 'true'},
      );

      await LocalNotificationService().showNotification(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(CupertinoIcons.bell_fill, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Alerta médica emitida con sonido y vibración',
                    style: TextStyle(fontWeight: FontWeight.w600, fontFamily: '.SF Pro Text'),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo emitir la alerta médica local.', style: TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.systemRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isTestingNotification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'NOTIFICACIONES PUSH & FCM',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: Column(
            children: [
              _NotificationItemTile(
                icon: CupertinoIcons.device_phone_portrait,
                iconColor: AppColors.accent,
                iconBgColor: AppColors.accent.withValues(alpha: 0.12),
                title: 'Ver Token FCM del Dispositivo',
                subtitle: 'Consultar y copiar token para Firebase',
                trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: AppColors.textTertiary),
                onTap: _openTokenDialog,
              ),
              const Divider(height: 0.8, thickness: 0.8, indent: 66, endIndent: 16, color: AppColors.border),
              _NotificationItemTile(
                icon: CupertinoIcons.bell_fill,
                iconColor: AppColors.systemOrange,
                iconBgColor: AppColors.systemOrange.withValues(alpha: 0.12),
                title: 'Probar Notificación Local',
                subtitle: 'Emitir alerta médica con sonido y vibración',
                trailing: _isTestingNotification
                    ? const CupertinoActivityIndicator(radius: 8)
                    : const Icon(CupertinoIcons.play_arrow_solid, size: 16, color: AppColors.accent),
                onTap: _sendTestNotification,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationItemTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const _NotificationItemTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.border.withValues(alpha: 0.3),
        highlightColor: AppColors.border.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
