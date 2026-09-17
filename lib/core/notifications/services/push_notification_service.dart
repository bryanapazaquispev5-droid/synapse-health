// ============================================================================
// Archivo: push_notification_service.dart
// Propósito: Fachada orquestadora para inicializar listeners de FCM, solicitar permisos al sistema y gestionar el ciclo de vida de notificaciones.
// ============================================================================

import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../handlers/notification_background_handler.dart';
import '../handlers/notification_router.dart';
import '../models/push_notification_payload.dart';
import 'fcm_token_service.dart';
import 'local_notification_service.dart';

/// Servicio de arquitectura y lógica de negocio para [PushNotificationService].
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotifications =
      LocalNotificationService();
  final FcmTokenService _tokenService = FcmTokenService();

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<User?>? _authSub;

  bool _isInitialized = false;

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_isInitialized) return;

    // Bloque: Ejecución protegida de operación asíncrona
    try {
      NotificationRouter.setNavigatorKey(navigatorKey);

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _localNotifications.initialize();

      await _requestNotificationPermissions();

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _handleColdStartNotification();

      _setupMessageListeners();

      _setupTokenSync();

      _isInitialized = true;
      developer.log(
        'PushNotificationService configurado con éxito',
        name: 'PushNotificationService',
      );
    } catch (e, stack) {
      developer.log(
        'Error durante la inicialización de PushNotificationService: $e',
        name: 'PushNotificationService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _requestNotificationPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    developer.log(
      'Estado de autorización de notificaciones: ${settings.authorizationStatus}',
      name: 'PushNotificationService',
    );
  }

  Future<void> _handleColdStartNotification() async {
    // Bloque: Ejecución protegida de operación asíncrona
    try {
      final RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();
      if (initialMessage != null) {
        developer.log(
          'Notificación detectada en Cold Start: ${initialMessage.messageId}',
          name: 'PushNotificationService',
        );
        final payload =
            PushNotificationPayload.fromRemoteMessage(initialMessage);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NotificationRouter.routeFromPayload(payload);
        });
      }
    // Bloque: Captura de excepciones y gestión de retroalimentación
    } catch (e) {
      developer.log('Error en Cold Start notification: $e',
          name: 'PushNotificationService');
    }
  }

  void _setupMessageListeners() {
    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        'FCM recibido en Foreground: [${message.messageId}]',
        name: 'PushNotificationService',
      );
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _localNotifications.showNotification(payload);
    });

    _onMessageOpenedAppSub?.cancel();
    _onMessageOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log(
        'Notificación presionada desde bandeja del sistema: [${message.messageId}]',
        name: 'PushNotificationService',
      );
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      NotificationRouter.routeFromPayload(payload);
    });
  }

  void _setupTokenSync() {
    _tokenService.monitorTokenRefresh(
      () => FirebaseAuth.instance.currentUser?.uid,
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _tokenService.syncTokenToFirestore(currentUser.uid);
    }

    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _tokenService.syncTokenToFirestore(user.uid);
      }
    });
  }

  Future<void> handleLogout(String uid) async {
    await _tokenService.deleteTokenOnLogout(uid);
  }

  // Bloque: Liberación de recursos y controladores para evitar fugas de memoria
  void dispose() {
    _onMessageSub?.cancel();
    _onMessageSub = null;
    _onMessageOpenedAppSub?.cancel();
    _onMessageOpenedAppSub = null;
    _authSub?.cancel();
    _authSub = null;
    _tokenService.dispose();
    _isInitialized = false;
  }
}
