// ============================================================================
// Archivo: notification_channels.dart
// Propósito: Configuracion y declaracion de canales de notificaciones locales de Android para prioridades medicas y recordatorios.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/push_notification_payload.dart';

/// Canales de notificación Android oficiales de Synapse Health
class NotificationChannels {
  static const String medicalAlertsId = 'synapse_medical_alerts';
  static const String dailyQuizzesId = 'synapse_daily_quizzes';
  static const String announcementsId = 'synapse_announcements';

  static const Color accentColor = Color(0xFF0052CC);

  /// Canal de máxima prioridad para emergencias médicas y guías críticas
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

  /// Canal de alta prioridad para quizzes diarios y recordatorio de rachas
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

  /// Canal de prioridad estándar para novedades, chuletas y anuncios de la plataforma
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

  /// Lista de todos los canales que deben crearse en el sistema Android
  static List<AndroidNotificationChannel> get allChannels => [
        medicalAlerts,
        dailyQuizzes,
        announcements,
      ];

  /// Devuelve el canal apropiado según el ID solicitado con fallback seguro
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

  /// Devuelve el canal apropiado según el tipo de notificación
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

  /// Construye los NotificationDetails para mostrar heads-up banners en primer plano
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
