import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../firebase_options.dart';
import '../models/push_notification_payload.dart';
import '../services/local_notification_service.dart';

/// Handler de ejecución en segundo plano para Firebase Cloud Messaging.
/// Debe ser una función de nivel superior obligatoriamente anotada con @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Inicializar el core de Firebase si el isolate en background no lo ha hecho
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final payload = PushNotificationPayload.fromRemoteMessage(message);

    developer.log(
      'FCM Mensaje recibido en background isolate: [${payload.id}] - ${payload.title}',
      name: 'NotificationBackgroundHandler',
    );

    // Si el mensaje viene sin bloque notification (data-only payload),
    // creamos la notificación local para que el usuario no pierda el evento
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
