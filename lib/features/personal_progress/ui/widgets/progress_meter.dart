import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_theme.dart';

/// The surrounding metric supplies the value read by accessibility services.
class ProgressMeter extends StatelessWidget {
  const ProgressMeter({
    super.key,
    required this.percentage,
    this.color = AppColors.accent,
  });

  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 6,
        child: ColoredBox(
          color: color.withValues(alpha: .12),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: percentage.clamp(0, 100) / 100),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, fraction, child) => FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart.resolve(
                Directionality.of(context),
              ),
              widthFactor: fraction,
              heightFactor: 1,
              child: child,
            ),
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: color,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
