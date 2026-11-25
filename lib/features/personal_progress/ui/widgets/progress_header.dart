import 'package:flutter/cupertino.dart';

import 'progress_appearance.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key, required this.onRanking});
  final VoidCallback onRanking;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 2,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Progreso personal',
            style: TextStyle(
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: -.65,
              color: ProgressAppearance.ink,
            ),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onRanking,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                Icon(
                  CupertinoIcons.rosette,
                  size: 16,
                  color: ProgressAppearance.accent,
                ),
                Text(
                  'Ranking global',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ProgressAppearance.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
