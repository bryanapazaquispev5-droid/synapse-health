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
        'Progreso personal',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      const Text(
        'Tu práctica, a partir de las respuestas guardadas.',
        style: TextStyle(fontSize: 15, color: AppColors.textMuted),
      ),
      if (onHistory != null)
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8),
          onPressed: onHistory,
          child: const Text('Mi historial'),
        ),
      CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        onPressed: onRanking,
        child: const Text('Ranking global'),
      ),
    ],
  );
}
