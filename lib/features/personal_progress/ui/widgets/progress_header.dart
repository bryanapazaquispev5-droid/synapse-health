import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key, required this.onRanking, this.onHistory});
  final VoidCallback onRanking;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Personal Progress',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        'Your practice, based on saved answers.',
        style: TextStyle(fontSize: 15, color: AppColors.textMuted),
      ),
      if (onHistory != null)
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8),
          onPressed: onHistory,
          child: const Text('My History'),
        ),
      CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        onPressed: onRanking,
        child: const Text('Global leaderboard'),
      ),
    ],
  );
}
