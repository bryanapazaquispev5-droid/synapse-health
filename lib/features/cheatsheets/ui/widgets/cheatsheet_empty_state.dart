// ============================================================================
// File: cheatsheet_empty_state.dart
// Purpose: Atomic visual component [cheatsheet_empty_state] for structured medical content and summaries.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/widgets/states/app_states.dart';

// Reactive state and lifecycle management for [CheatsheetEmpty]
class CheatsheetEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CheatsheetEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = CupertinoIcons.folder_badge_minus,
    this.actionLabel,
    this.onAction,
  });

  // Reactive rendering of the widget tree
  // Block: Reactive rendering of the main widget tree
  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      message: subtitle,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}
