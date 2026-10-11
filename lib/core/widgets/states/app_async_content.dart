import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

import '../../theme/app_theme.dart';
import 'app_async_stream_builder.dart';
import 'app_states.dart';

export 'app_async_stream_builder.dart';
export 'app_states.dart';

bool isNetworkFailure(Object? error) =>
    error is SocketException ||
    error is TimeoutException ||
    (error is FirebaseException &&
        [
          'unavailable',
          'deadline-exceeded',
          'network-request-failed',
        ].contains(error.code));

String safeContentError(Object? error, String fallback) {
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'No tienes permiso para ver este contenido.';
    }
    if (error.code == 'unauthenticated') {
      return 'Inicia sesión para acceder a este contenido.';
    }
  }
  return fallback;
}

class AppAsyncStatus<T> extends StatelessWidget {
  const AppAsyncStatus({
    super.key,
    required this.snapshot,
    required this.isEmpty,
    required this.onRetry,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyIcon = CupertinoIcons.folder_badge_minus,
    this.errorMessage = 'No se pudo cargar el contenido. Inténtalo de nuevo.',
  });

  final AppAsyncSnapshot<T> snapshot;
  final bool isEmpty;
  final VoidCallback onRetry;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    if (snapshot.isAccessFailure) {
      return AppErrorState(
        message: safeContentError(snapshot.error, errorMessage),
      );
    }
    if (snapshot.isRetrying) {
      return const AppLoadingState(message: 'Reintentando…');
    }
    if (snapshot.hasError) {
      if (!snapshot.isOnline && isNetworkFailure(snapshot.error)) {
        return AppOfflineState(onRetry: onRetry);
      }
      return AppErrorState(
        message: safeContentError(snapshot.error, errorMessage),
        onRetry: onRetry,
      );
    }
    if (!snapshot.isOnline && (!snapshot.hasData || isEmpty)) {
      return AppOfflineState(onRetry: onRetry);
    }
    if (!snapshot.hasData) return const AppLoadingState();
    if (isEmpty) {
      return AppEmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: emptyIcon,
      );
    }
    return const SizedBox.shrink();
  }
}

/// A partial status keeps already loaded content available during interruption.
class AppAsyncNotice<T> extends StatelessWidget {
  const AppAsyncNotice({
    super.key,
    required this.snapshot,
    required this.onRetry,
  });
  final AppAsyncSnapshot<T> snapshot;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (snapshot.isRetrying || snapshot.isWaiting) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: AppLoadingState(compact: true),
      );
    }
    if (snapshot.isOnline && !snapshot.hasError) return const SizedBox.shrink();
    final message = !snapshot.hasData
        ? 'No se pudo cargar el contenido. Inténtalo de nuevo.'
        : snapshot.hasError && !isNetworkFailure(snapshot.error)
        ? 'No se pudo actualizar el contenido. Mostrando datos ya cargados.'
        : snapshot.isOnline
        ? 'No se pudo actualizar el contenido. Inténtalo de nuevo.'
        : 'Sin conexión. Mostrando datos ya cargados.';
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              snapshot.isOnline
                  ? CupertinoIcons.exclamationmark_circle
                  : CupertinoIcons.wifi_slash,
              size: 18,
              color: AppColors.accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.35,
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: onRetry,
              child: const Icon(
                CupertinoIcons.arrow_clockwise,
                size: 20,
                semanticLabel: 'Reintentar',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
