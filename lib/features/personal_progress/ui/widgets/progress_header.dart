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
              fontSize: 27,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -.65,
              color: ProgressAppearance.ink,
            ),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(48, 48),
          onPressed: onRanking,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ProgressAppearance.blueTint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 7),
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
        ),
      ],
    ),
  );
}
