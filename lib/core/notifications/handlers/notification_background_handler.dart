// ============================================================================
// Archivo: notification_background_handler.dart
// Propósito: Manejador aislado en segundo plano para procesar mensajes remotos de FCM cuando la aplicación está cerrada o en segundo plano.
// ============================================================================

import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../firebase_options.dart';
import '../models/push_notification_payload.dart';
import '../services/local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Bloque: Ejecución protegida de operación asíncrona
  try {
    if (Firebase.apps.isEmpty) {
      // Bloque: Inicialización de la infraestructura Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final payload = PushNotificationPayload.fromRemoteMessage(message);

    developer.log(
      'FCM Mensaje recibido en background isolate: [${payload.id}] - ${payload.title}',
      name: 'NotificationBackgroundHandler',
    );

    if (message.notification == null && payload.body.isNotEmpty) {
      final localService = LocalNotificationService();
      await localService.initialize();
      await localService.showNotification(payload);
    }
  } catch (error, stackTrace) {
    developer.log(
      'Error procesando notificación en background: $error',
      name: 'NotificationBackgroundHandler',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
