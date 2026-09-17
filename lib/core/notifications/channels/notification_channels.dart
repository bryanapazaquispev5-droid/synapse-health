// ============================================================================
// Archivo: notification_channels.dart
// Propósito: Configuración y declaración de canales de notificación locales de Android para prioridades médicas y alertas.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/push_notification_payload.dart';

/// Componente de interfaz de usuario reutilizable [NotificationChannels].
class NotificationChannels {
  static const String medicalAlertsId = 'synapse_medical_alerts';
  static const String dailyQuizzesId = 'synapse_daily_quizzes';
  static const String announcementsId = 'synapse_announcements';

  static const Color accentColor = Color(0xFF0052CC);

  static const AndroidNotificationChannel medicalAlerts =
      AndroidNotificationChannel(
    medicalAlertsId,
    'Alertas Médicas Críticas',
    description:
        'Notificaciones de emergencias médicas, guías clínicas y alertas de alta prioridad.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static const AndroidNotificationChannel dailyQuizzes =
      AndroidNotificationChannel(
    dailyQuizzesId,
    'Quizzes Diarios y Rachas',
    description:
        'Recordatorios diarios para repaso activo, preguntas del día y preservación de rachas.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  static const AndroidNotificationChannel announcements =
      AndroidNotificationChannel(
    announcementsId,
    'Anuncios y Novedades',
    description:
        'Actualizaciones académicas, nuevas chuletas médicas y avisos del sistema.',
    importance: Importance.defaultImportance,
    playSound: true,
    showBadge: true,
  );

  static List<AndroidNotificationChannel> get allChannels => [
        medicalAlerts,
        dailyQuizzes,
        announcements,
      ];

  static AndroidNotificationChannel getChannelById(String? channelId) {
    switch (channelId) {
      case medicalAlertsId:
        return medicalAlerts;
      case dailyQuizzesId:
        return dailyQuizzes;
      case announcementsId:
        return announcements;
      default:
        return announcements;
    }
  }

  static AndroidNotificationChannel getChannelForType(NotificationType type) {
    switch (type) {
      case NotificationType.medicalAlert:
        return medicalAlerts;
      case NotificationType.dailyQuiz:
        return dailyQuizzes;
      case NotificationType.cheatsheet:
      case NotificationType.announcement:
      case NotificationType.general:
        return announcements;
    }
  }

  static NotificationDetails buildDetails({
    required PushNotificationPayload payload,
  }) {
    final AndroidNotificationChannel channel = getChannelById(payload.channelId);

    final androidSpecifics = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: channel.importance == Importance.max
          ? Priority.max
          : (channel.importance == Importance.high
              ? Priority.high
              : Priority.defaultPriority),
      color: accentColor,
      icon: '@mipmap/launcher_icon',
      playSound: channel.playSound,
      enableVibration: channel.enableVibration,
      styleInformation: BigTextStyleInformation(
        payload.body,
        contentTitle: payload.title,
        htmlFormatContentTitle: true,
        htmlFormatContent: true,
      ),
    );

    const darwinSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidSpecifics,
      iOS: darwinSpecifics,
    );
  }
}
