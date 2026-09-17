// ============================================================================
// Archivo: local_notification_service.dart
// Propósito: Servicio de notificaciones locales para desplegar alertas heads-up en primer plano con canales de alta prioridad.
// ============================================================================

import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../channels/notification_channels.dart';
import '../handlers/notification_router.dart';
import '../models/push_notification_payload.dart';

/// Servicio de arquitectura y lógica de negocio para [LocalNotificationService].
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() => _instance;

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Bloque: Ejecución protegida de operación asíncrona
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      await _createAndroidChannels();
      _isInitialized = true;
      developer.log(
        'LocalNotificationService inicializado correctamente',
        name: 'LocalNotificationService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error inicializando LocalNotificationService: $e',
        name: 'LocalNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _createAndroidChannels() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      for (final channel in NotificationChannels.allChannels) {
        await androidImpl.createNotificationChannel(channel);
      }
    }
  }

  Future<void> showNotification(PushNotificationPayload payload) async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final int notificationId = payload.id.hashCode & 0x7FFFFFFF;
      final details = NotificationChannels.buildDetails(payload: payload);

      await _plugin.show(
        id: notificationId,
        title: payload.title,
        body: payload.body,
        notificationDetails: details,
        payload: payload.toJsonString(),
      );

      developer.log(
        'Banner de notificación mostrado exitosamente: [id: $notificationId]',
        name: 'LocalNotificationService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Fallo al emitir banner local: $e',
        name: 'LocalNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      'Usuario presionó notificación local: ${response.id}',
      name: 'LocalNotificationService',
    );

    final String? payloadStr = response.payload;
    if (payloadStr != null && payloadStr.isNotEmpty) {
      final payload = PushNotificationPayload.fromJsonString(payloadStr);
      if (payload != null) {
        NotificationRouter.routeFromPayload(payload);
      }
    }
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
