import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import 'progress_appearance.dart';

class ProgressAccuracyCard extends StatelessWidget {
  const ProgressAccuracyCard({
    super.key,
    required this.accuracy,
    required this.correct,
    required this.answers,
  });

  final double? accuracy;
  final int correct;
  final int answers;

  @override
  Widget build(BuildContext context) {
    final percentage = accuracy;
    final showDonut =
        percentage != null && MediaQuery.textScalerOf(context).scale(14) <= 19;
    final score = percentage == null
        ? 'No disponible'
        : '${percentage.toStringAsFixed(1)} %';
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                CupertinoIcons.scope,
                color: ProgressAppearance.accent,
                size: 22,
              ),
              const SizedBox(height: 7),
              const Text(
                'Aciertos actuales',
                style: TextStyle(
                  color: ProgressAppearance.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!showDonut) ...[
                const SizedBox(height: 4),
                Text(
                  score,
                  style: TextStyle(
                    color: ProgressAppearance.accent,
                    fontSize: percentage == null ? 24 : 54,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '$correct de $answers respuestas correctas',
                style: const TextStyle(
                  color: ProgressAppearance.muted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (showDonut) ...[
          const SizedBox(width: 12),
          _AccuracyDonut(percentage: percentage, score: score),
        ],
      ],
    );
  }
}

class _AccuracyDonut extends StatelessWidget {
  const _AccuracyDonut({required this.percentage, required this.score});

  final double percentage;
  final String score;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: percentage.clamp(0, 100) / 100),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 520),
    curve: Curves.easeOutCubic,
    builder: (context, fraction, child) =>
        CustomPaint(painter: _DonutPainter(fraction), child: child),
    child: SizedBox(
      width: 132,
      height: 104,
      child: Align(
        alignment: const Alignment(0, .08),
        child: SizedBox(
          width: 62,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              score,
              style: const TextStyle(
                color: Color(0xFF176C84),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.fraction);

  static const _start = -math.pi / 2;
  static const _blueWall = Color(0xFF176782);
  static const _rest = Color(0xFFD5E5ED);
  static const _restWall = Color(0xFF92AFBF);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const depth = 10.0;
    final outer = Rect.fromLTWH(3, 4, size.width - 6, size.height - 16);
    final inner = Rect.fromCenter(
      center: outer.center,
      width: outer.width * .5,
      height: outer.height * .49,
    );
    final end = _start + fraction * 2 * math.pi;

    _drawWall(canvas, outer, 0, math.pi, depth, _restWall);
    _drawWall(canvas, outer, 0, math.min(end, math.pi), depth, _blueWall);
    _drawWall(canvas, inner, -math.pi, 0, depth, _restWall);
    _drawWall(canvas, inner, _start, math.min(end, 0), depth, _blueWall);
    _drawWall(canvas, inner, math.pi, end, depth, _blueWall);

    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(outer)
      ..addOval(inner);
    canvas.drawPath(ring, Paint()..color = _rest);
    final blue = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF32AFC7), Color(0xFF137CA5)],
      ).createShader(outer);
    if (fraction == 1) {
      canvas.drawPath(ring, blue);
    } else if (fraction > 0) {
      final sweep = end - _start;
      final sector = Path()
        ..arcTo(outer, _start, sweep, true)
        ..arcTo(inner, end, -sweep, false)
        ..close();
      canvas.drawPath(sector, blue);
    }
  }

  void _drawWall(
    Canvas canvas,
    Rect ellipse,
    double start,
    double end,
    double depth,
    Color color,
  ) {
    if (end <= start) return;
    final sweep = end - start;
    final wall = Path()
      ..arcTo(ellipse, start, sweep, true)
      ..arcTo(ellipse.shift(Offset(0, depth)), end, -sweep, false)
      ..close();
    canvas.drawPath(wall, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
