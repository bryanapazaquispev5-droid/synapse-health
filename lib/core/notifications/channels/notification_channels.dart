// ============================================================================
// File: notification_channels.dart
// Purpose: Configuration and declaration of Android local notification channels for medical priorities and reminders.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/push_notification_payload.dart';

/// Official Synapse Health Android notification channels
class NotificationChannels {
  static const String medicalAlertsId = 'synapse_medical_alerts';
  static const String dailyQuizzesId = 'synapse_daily_quizzes';
  static const String announcementsId = 'synapse_announcements';

  static const Color accentColor = Color(0xFF0052CC);

  /// Highest-priority channel for medical emergencies and critical guides
  static const AndroidNotificationChannel medicalAlerts =
      AndroidNotificationChannel(
    medicalAlertsId,
    'Critical Medical Alerts',
    description:
        'Notifications about medical emergencies, clinical guides, and high-priority alerts.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// High-priority channel for daily quizzes and streak reminders
  static const AndroidNotificationChannel dailyQuizzes =
      AndroidNotificationChannel(
    dailyQuizzesId,
    'Daily Quizzes and Streaks',
    description:
        'Daily reminders for active review, question of the day, and maintaining study streaks.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Standard-priority channel for updates, study notes, and platform announcements
  static const AndroidNotificationChannel announcements =
      AndroidNotificationChannel(
    announcementsId,
    'Anuncios y Novedades',
    description:
        'Academic updates, new medical study notes, and system announcements.',
    importance: Importance.defaultImportance,
    playSound: true,
    showBadge: true,
  );

  /// List of all channels to create on the Android system
  static List<AndroidNotificationChannel> get allChannels => [
        medicalAlerts,
        dailyQuizzes,
        announcements,
      ];

  /// Returns the appropriate channel for the requested ID, with a safe fallback
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

  /// Returns the appropriate channel for the notification type
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

  /// Builds NotificationDetails for displaying heads-up banners in the foreground
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
