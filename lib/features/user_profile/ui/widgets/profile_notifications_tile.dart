// ============================================================================
// File: profile_notifications_tile.dart
// Purpose: Modular interface component [profile_notifications_tile] for displaying user data and settings.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/notifications/channels/notification_channels.dart';
import '../../../../core/notifications/models/push_notification_payload.dart';
import '../../../../core/notifications/services/local_notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ios_top_banner.dart';

/// Profile section for testing on-device local notifications.
class ProfileNotificationsTile extends StatefulWidget {
  const ProfileNotificationsTile({super.key});

  @override
  State<ProfileNotificationsTile> createState() => _ProfileNotificationsTileState();
}

// Reactive state and lifecycle management for [ProfileNotificationsTile]
class _ProfileNotificationsTileState extends State<ProfileNotificationsTile> {
  bool _isTestingNotification = false;

  Future<void> _sendTestNotification() async {
    if (_isTestingNotification) return;
    setState(() => _isTestingNotification = true);
    HapticFeedback.mediumImpact();

    try {
      final now = DateTime.now();
      final payload = PushNotificationPayload(
        id: 'test_alert_${now.millisecondsSinceEpoch}',
        title: '🚨 Test Medical Alert',
        body: 'Blue code protocol active. Sound and vibration verified.',
        type: NotificationType.medicalAlert,
        channelId: NotificationChannels.medicalAlertsId,
        receivedAt: now,
        data: const {'type': 'medical_alert', 'is_test': 'true'},
      );

      await LocalNotificationService().showNotification(payload);

      if (mounted) {
        IosTopBanner.info(
          context,
          'Medical alert sent with sound and vibration.',
        );
      }
    } catch (_) {
      if (mounted) {
        IosTopBanner.error(
          context,
          'Could not send the local medical alert.',
        );
      }
    } finally {
      if (mounted) setState(() => _isTestingNotification = false);
    }
  }

  // Reactive widget tree rendering
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'LOCAL NOTIFICATIONS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.4),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: _NotificationItemTile(
            icon: CupertinoIcons.bell_fill,
            iconColor: AppColors.systemOrange,
            iconBgColor: AppColors.systemOrange.withValues(alpha: 0.12),
            title: 'Test Local Notification',
            subtitle: 'Send a medical alert with sound and vibration',
            trailing: _isTestingNotification
                ? const CupertinoActivityIndicator(radius: 8)
                : const Icon(CupertinoIcons.play_arrow_solid, size: 16, color: AppColors.accent),
            onTap: _sendTestNotification,
          ),
        ),
      ],
    );
  }
}

// Modular visual component [_NotificationItemTile]
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

  // Reactive widget tree rendering
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
