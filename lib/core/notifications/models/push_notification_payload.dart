// ============================================================================
// Archivo: push_notification_payload.dart
// Propósito: Entidad inmutable fuertemente tipada para parsear, representar y transferir cargas utiles de notificaciones remotas.
// ============================================================================

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Tipos de notificaciones soportadas por Synapse Health
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
      case 'chuleta':
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

/// Entidad inmutable tipada que encapsula la carga útil de una notificación push
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

  /// Construye un payload tipado a partir de un RemoteMessage de Firebase
  factory PushNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(message.data);
    final notification = message.notification;

    final String title = notification?.title?.trim().isNotEmpty == true
        ? notification!.title!
        : (data['title']?.toString() ?? 'Synapse Health');

    final String body = notification?.body?.trim().isNotEmpty == true
        ? notification!.body!
        : (data['body']?.toString() ?? 'Nueva actualización disponible');

    final NotificationType parsedType = NotificationType.fromString(
      data['type']?.toString() ?? data['notification_type']?.toString(),
    );

    final String channelId = notification?.android?.channelId ??
        data['channel_id']?.toString() ??
        parsedType.defaultChannelId;

    final String? route = data['route']?.toString() ??
        data['click_action']?.toString() ??
        data['screen']?.toString();

    final String? targetId =
        data['target_id']?.toString() ?? data['id']?.toString();

    final String id = message.messageId ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return PushNotificationPayload(
      id: id,
      title: title,
      body: body,
      type: parsedType,
      channelId: channelId,
      route: route,
      targetId: targetId,
      data: data,
      receivedAt: message.sentTime ?? DateTime.now(),
    );
  }

  /// Deserializa desde un Map JSON
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

  /// Serializa a Map JSON
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

  /// Serializa a String JSON codificado para flutter_local_notifications payload
  String toJsonString() => jsonEncode(toJson());

  /// Deserializa desde un String JSON codificado
  static PushNotificationPayload? fromJsonString(String? source) {
    if (source == null || source.trim().isEmpty) return null;
    // Bloque: Ejecución protegida de operación asíncrona
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
