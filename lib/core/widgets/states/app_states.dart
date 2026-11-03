import 'package:flutter/cupertino.dart';

import '../../theme/app_theme.dart';
import 'app_message_state.dart';

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.message = 'Loading…',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final indicator = Semantics(
      label: message,
      liveRegion: true,
      child: ExcludeSemantics(
        child: CupertinoActivityIndicator(radius: compact ? 8 : 14),
      ),
    );
    if (compact) return indicator;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(height: 16),
            ExcludeSemantics(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = CupertinoIcons.folder_badge_minus,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AppMessageState(
    title: title,
    message: message,
    icon: icon,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.message = 'Could not load the content. Please try again.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AppMessageState(
    title: 'Could not load the content',
    message: message,
    icon: CupertinoIcons.exclamationmark_circle,
    actionLabel: onRetry == null ? null : 'Retry',
    onAction: onRetry,
  );
}

class AppOfflineState extends StatelessWidget {
  const AppOfflineState({
    super.key,
    this.message = 'Check your internet connection to load the content.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AppMessageState(
    title: 'No internet connection',
    message: message,
    icon: CupertinoIcons.wifi_slash,
    actionLabel: onRetry == null ? null : 'Retry',
    onAction: onRetry,
  );
}
