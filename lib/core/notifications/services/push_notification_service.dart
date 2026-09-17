// ============================================================================
// Archivo: push_notification_service.dart
// Propósito: Fachada orquestadora para inicializar y gestionar el ciclo de vida completo de notificaciones push y permisos del sistema.
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

/// Fachada orquestadora para la gestión global de notificaciones Push (FCM).
/// Controla permisos, handlers de ciclo de vida (primer plano, segundo plano, arranque en frío)
/// y vinculación con la navegación de la app.
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

  /// Inicializa permisos, canales nativos, listeners reactivos y deep links
  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_isInitialized) return;

    try {
      NotificationRouter.setNavigatorKey(navigatorKey);

      // Registrar el handler de background isolate
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Inicializar adaptador de notificaciones locales y canales del sistema
      await _localNotifications.initialize();

      // Solicitar permisos de notificación interactivos al usuario
      await _requestNotificationPermissions();

      // Configurar presentación visual de notificaciones en primer plano
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Manejar arranque en frío (Cold Start: app terminada y abierta desde notificación)
      await _handleColdStartNotification();

      // Configurar listeners reactivos en primer plano y reapertura
      _setupMessageListeners();

      // Configurar sincronización del token FCM con Firestore
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

  /// Solicita permisos de notificación Push
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

  /// Procesa notificaciones recibidas cuando la aplicación estaba totalmente cerrada
  Future<void> _handleColdStartNotification() async {
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
    } catch (e) {
      developer.log('Error en Cold Start notification: $e',
          name: 'PushNotificationService');
    }
  }

  /// Configura los oyentes de mensajes en primer plano y en segundo plano
  void _setupMessageListeners() {
    // 1. Mensaje recibido con la app abierta (Foreground) -> Heads-Up Banner
    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log(
        'FCM recibido en Foreground: [${message.messageId}]',
        name: 'PushNotificationService',
      );
      final payload = PushNotificationPayload.fromRemoteMessage(message);
      _localNotifications.showNotification(payload);
    });

    // 2. Mensaje abierto desde la bandeja con app en segundo plano (Background -> Foreground)
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

  /// Configura la sincronización de tokens y monitorea cambios de usuario
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

  /// Notifica cierre de sesión para purgar el token asociado al usuario
  Future<void> handleLogout(String uid) async {
    await _tokenService.deleteTokenOnLogout(uid);
  }

  /// Cierra streams y libera observadores
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
