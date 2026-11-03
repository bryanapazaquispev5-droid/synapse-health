// ============================================================================
// File: push_notification_payload.dart
// Purpose: Strongly typed immutable entity for local notification content.
// ============================================================================

import 'dart:convert';

/// Notification types supported by Synapse Health
enum NotificationType {
  medicalAlert,
  dailyQuiz,
  cheatsheet,
  announcement,
  general;

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'medical_alert':
      case 'medicalalert':
      case 'alert':
        return NotificationType.medicalAlert;
      case 'daily_quiz':
      case 'dailyquiz':
      case 'quiz':
        return NotificationType.dailyQuiz;
      case 'cheatsheet':
      case 'ficha':
        return NotificationType.cheatsheet;
      case 'announcement':
      case 'anuncio':
        return NotificationType.announcement;
      default:
        return NotificationType.general;
    }
  }

  String get defaultChannelId {
    switch (this) {
      case NotificationType.medicalAlert:
        return 'synapse_medical_alerts';
      case NotificationType.dailyQuiz:
        return 'synapse_daily_quizzes';
      case NotificationType.announcement:
      case NotificationType.cheatsheet:
      case NotificationType.general:
        return 'synapse_announcements';
    }
  }
}

/// Typed immutable entity that encapsulates a local notification payload
class PushNotificationPayload {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String channelId;
  final String? route;
  final String? targetId;
  final Map<String, dynamic> data;
  final DateTime receivedAt;

  const PushNotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.channelId,
    this.route,
    this.targetId,
    this.data = const {},
    required this.receivedAt,
  });

  /// Deserializes from a JSON Map
  factory PushNotificationPayload.fromJson(Map<String, dynamic> json) {
    final parsedType = NotificationType.fromString(json['type']?.toString());
    return PushNotificationPayload(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Synapse Health',
      body: json['body']?.toString() ?? '',
      type: parsedType,
      channelId:
          json['channelId']?.toString() ?? parsedType.defaultChannelId,
      route: json['route']?.toString(),
      targetId: json['targetId']?.toString(),
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : {},
      receivedAt: json['receivedAt'] != null
          ? DateTime.tryParse(json['receivedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Serializes to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'channelId': channelId,
      'route': route,
      'targetId': targetId,
      'data': data,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  /// Serializes to a JSON-encoded String for the flutter_local_notifications payload
  String toJsonString() => jsonEncode(toJson());

  /// Deserializes from a JSON-encoded String
  static PushNotificationPayload? fromJsonString(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    // Block: Protected execution of an asynchronous operation
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return PushNotificationPayload.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
