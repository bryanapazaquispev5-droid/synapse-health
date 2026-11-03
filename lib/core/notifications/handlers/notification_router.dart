// ============================================================================
// File: notification_router.dart
// Purpose: Centralized router for processing deep links and navigating to specific sections when users interact with a notification.
// ============================================================================

import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../auth/app_auth.dart';
import '../../../features/auth_login/ui/auth_screen.dart';
import '../../../features/navigation/ui/main_navigation_wrapper.dart';
import '../models/push_notification_payload.dart';

/// Centralized router for deep-link and push-notification navigation
class NotificationRouter {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static PushNotificationPayload? _pendingPayload;

  /// Assigns the global navigation key used by MaterialApp
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

  /// Processes the payload and performs the corresponding screen transition
  static void routeFromPayload(PushNotificationPayload payload) {
    final state = _navigatorKey?.currentState;
    if (state == null) {
      _pendingPayload = payload;
      developer.log(
        'NavigatorState is not available yet; payload queued: ${payload.id}',
        name: 'NotificationRouter',
      );
      return;
    }

    final BuildContext? context = _navigatorKey?.currentContext;
    final currentUser = AppAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log(
        'User is not authenticated; redirecting to the login screen',
        name: 'NotificationRouter',
      );
      state.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
      return;
    }

    developer.log(
      'Routing notification: [${payload.type}] ruta: ${payload.route}',
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

  /// Navigates the user to the requested BottomPill tab
  static void _navigateToTab(
    NavigatorState state,
    AppUser user, {
    required int targetIndex,
  }) {
    state.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            MainNavigationWrapper(user: user, initialIndex: targetIndex),
      ),
      (route) => false,
    );
  }

  /// Handles arbitrary string routes as deep links
  static void _handleCustomRoute(
    NavigatorState state,
    AppUser user,
    String route,
  ) {
    switch (route.toLowerCase().trim()) {
      case '/quizzes':
      case '/quiz':
        _navigateToTab(state, user, targetIndex: 1);
        break;
      case '/cheatsheets':
      case '/fichas':
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

  /// Modal dialog for high-priority medical alerts
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
            const Icon(
              CupertinoIcons.exclamationmark_shield_fill,
              color: CupertinoColors.destructiveRed,
              size: 22,
            ),
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
          child: Text(payload.body, style: const TextStyle(fontSize: 14)),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Got it'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  /// Informational modal for platform announcements or updates
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
            child: const Text('OK'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }
}
