import 'package:flutter/widgets.dart';

class LeaderboardEntrance extends StatelessWidget {
  const LeaderboardEntrance({super.key, required this.child, this.order = 0});
  final Widget child;
  final int order;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 310 + order * 48),
      curve: Interval(order * .085, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 9 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}
