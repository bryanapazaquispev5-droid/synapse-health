import 'package:flutter/material.dart';

class BottomPillIndicator extends StatelessWidget {
  final double left;
  final double right;
  final double slotWidth;
  final double totalWidth;
  final double scaleX;
  final double scaleY;

  const BottomPillIndicator({
    super.key,
    required this.left,
    required this.right,
    required this.slotWidth,
    required this.totalWidth,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left + 3,
      width: (right - left - 6).clamp(slotWidth * 0.6, totalWidth),
      top: 0,
      bottom: 0,
      child: IgnorePointer(
        child: Center(
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            child: Container(
              height: 53.5,
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.85),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
