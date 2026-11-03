// ============================================================================
// File: local_notification_service.dart
// Purpose: Local notification service for displaying foreground heads-up alerts with sound and vibration support.
// ============================================================================

import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../channels/notification_channels.dart';
import '../handlers/notification_router.dart';
import '../models/push_notification_payload.dart';

/// Service responsible for creating native Android channels
/// and displaying heads-up notification banners while the app is in the foreground.
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() => _instance;

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initializes native adapters and registers Android channels
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Block: Protected execution of an asynchronous operation
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
        'LocalNotificationService initialized successfully',
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

  /// Creates all configured channels in the Android operating system
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

  /// Displays a local notification in a heads-up banner
  Future<void> showNotification(PushNotificationPayload payload) async {
    // Block: Protected execution of an asynchronous operation
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
        'Notification banner displayed successfully: [id: $notificationId]',
        name: 'LocalNotificationService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to display local banner: $e',
        name: 'LocalNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handles taps on the local notification banner
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      'User tapped local notification: ${response.id}',
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

  /// Cancels a specific notification
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Clears all notifications issued by the app
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
