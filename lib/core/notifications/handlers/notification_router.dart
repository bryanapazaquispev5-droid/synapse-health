// ============================================================================
// Archivo: notification_router.dart
// Propósito: Enrutador centralizado para procesar deep links y navegar a secciones especificas al interactuar con una notificacion.
// ============================================================================

import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/auth_login/ui/auth_screen.dart';
import '../../../features/navigation/ui/main_navigation_wrapper.dart';
import '../models/push_notification_payload.dart';

/// Enrutador centralizado para navegación por deep links y notificaciones push
class NotificationRouter {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static PushNotificationPayload? _pendingPayload;

  /// Asigna la clave global de navegación utilizada por MaterialApp
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    if (_pendingPayload != null) {
      final payload = _pendingPayload!;
      _pendingPayload = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        routeFromPayload(payload);
      });
    }
  }

  /// Procesa la carga útil y realiza la transición de pantalla correspondiente
  static void routeFromPayload(PushNotificationPayload payload) {
    final state = _navigatorKey?.currentState;
    if (state == null) {
      _pendingPayload = payload;
      developer.log(
        'NavigatorState aún no disponible, payload encolado: ${payload.id}',
        name: 'NotificationRouter',
      );
      return;
    }

    final BuildContext? context = _navigatorKey?.currentContext;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log(
        'Usuario no autenticado, redirigiendo a pantalla de login',
        name: 'NotificationRouter',
      );
      state.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
      return;
    }

    developer.log(
      'Enrutando notificación: [${payload.type}] ruta: ${payload.route}',
      name: 'NotificationRouter',
    );

    switch (payload.type) {
      case NotificationType.dailyQuiz:
        _navigateToTab(state, currentUser, targetIndex: 1);
        break;

      case NotificationType.cheatsheet:
        _navigateToTab(state, currentUser, targetIndex: 0);
        break;

      case NotificationType.medicalAlert:
        _navigateToTab(state, currentUser, targetIndex: 0);
        if (context != null && context.mounted) {
          _showMedicalAlertModal(context, payload);
        }
        break;

      case NotificationType.announcement:
      case NotificationType.general:
        if (payload.route != null && payload.route!.isNotEmpty) {
          _handleCustomRoute(state, currentUser, payload.route!);
        } else if (context != null && context.mounted) {
          _showAnnouncementModal(context, payload);
        }
        break;
    }
  }

  /// Conduce al usuario hacia la pestaña requerida del BottomPill
  static void _navigateToTab(
    NavigatorState state,
    User user, {
    required int targetIndex,
  }) {
    state.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavigationWrapper(
          user: user,
          initialIndex: targetIndex,
        ),
      ),
      (route) => false,
    );
  }

  /// Maneja rutas string arbitrarias tipo deep link
  static void _handleCustomRoute(
    NavigatorState state,
    User user,
    String route,
  ) {
    switch (route.toLowerCase().trim()) {
      case '/quizzes':
      case '/quiz':
        _navigateToTab(state, user, targetIndex: 1);
        break;
      case '/cheatsheets':
      case '/chuletas':
        _navigateToTab(state, user, targetIndex: 0);
        break;
      case '/progress':
      case '/progreso':
        _navigateToTab(state, user, targetIndex: 2);
        break;
      case '/profile':
      case '/perfil':
        _navigateToTab(state, user, targetIndex: 3);
        break;
      default:
        _navigateToTab(state, user, targetIndex: 0);
    }
  }

  /// Diálogo modal para alertas médicas de alta prioridad
  static void _showMedicalAlertModal(
    BuildContext context,
    PushNotificationPayload payload,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.exclamationmark_shield_fill,
                color: CupertinoColors.destructiveRed, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                payload.title,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            payload.body,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Entendido'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  /// Modal informativo para anuncios o novedades de la plataforma
  static void _showAnnouncementModal(
    BuildContext context,
    PushNotificationPayload payload,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(payload.title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(payload.body),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Aceptar'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }
}
