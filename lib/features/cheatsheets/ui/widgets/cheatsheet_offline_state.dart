// ============================================================================
// File: cheatsheet_offline_state.dart
// Purpose: Atomic visual component [cheatsheet_offline_state] for structured medical content and summaries.
// ============================================================================

import 'package:flutter/cupertino.dart';

import '../../../../core/widgets/states/app_states.dart';

class CheatsheetOfflineState extends StatelessWidget {
  const CheatsheetOfflineState({
    super.key,
    this.message = 'Check your internet connection to load study notes.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) =>
      AppOfflineState(message: message, onRetry: onRetry);
}
