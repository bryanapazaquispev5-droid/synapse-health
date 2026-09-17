// ============================================================================
// Archivo: liquid_wave_clipper.dart
// Propósito: Controlador de navegacion principal [liquid_wave_clipper] con transiciones fluidas estilo liquid wave.
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';

// Definicion principal de la clase [LiquidWaveClipper]
class LiquidWaveClipper extends CustomClipper<Path> {
  final double progress;
  final bool fromRight;

  const LiquidWaveClipper({
    required this.progress,
    required this.fromRight,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();
    if (progress <= 0.0) return path;
    if (progress >= 1.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    final double w = size.width;
    final double h = size.height;

    // Fase 1 (0.0 -> 0.38): Se asoma al ~28% de la pantalla con oleaje orgánico
    // Fase 2 (0.38 -> 1.0): Expansión fluida y rápida hasta cubrir el 100%
    double baseFraction;
    if (progress <= 0.38) {
      final double p1 = Curves.easeOutCubic.transform(progress / 0.38);
      baseFraction = p1 * 0.28;
    } else {
      final double p2 = Curves.easeInOutCubic.transform((progress - 0.38) / 0.62);
      baseFraction = 0.28 + p2 * 0.80;
    }

    // Amplitud de la ola orgánica
    final double waveDecay = (1.0 - progress).clamp(0.0, 1.0);
    final double amplitude = math.sin(progress * math.pi) * 44.0 * waveDecay;
    final double waveOffset = progress * math.pi * 4.5;

    final int segments = 28;
    final double dy = h / segments;

    if (fromRight) {
      final double startX = w - (baseFraction * w);
      path.moveTo(w, 0);
      path.lineTo(startX, 0);

      for (int i = 1; i <= segments; i++) {
        final double y = i * dy;
        final double prevY = (i - 1) * dy;
        final double midY = (prevY + y) / 2;

        final double wave1 = math.sin((y / h) * math.pi * 2.8 + waveOffset) * amplitude;
        final double midWave = math.sin((midY / h) * math.pi * 2.8 + waveOffset) * amplitude;

        final double targetX = (startX + wave1).clamp(0.0, w);
        final double controlX = (startX + midWave).clamp(0.0, w);

        path.quadraticBezierTo(controlX, midY, targetX, y);
      }

      path.lineTo(w, h);
      path.close();
    } else {
      final double endX = baseFraction * w;
      path.moveTo(0, 0);
      path.lineTo(endX, 0);

      for (int i = 1; i <= segments; i++) {
        final double y = i * dy;
        final double prevY = (i - 1) * dy;
        final double midY = (prevY + y) / 2;

        final double wave1 = math.sin((y / h) * math.pi * 2.8 + waveOffset) * amplitude;
        final double midWave = math.sin((midY / h) * math.pi * 2.8 + waveOffset) * amplitude;

        final double targetX = (endX + wave1).clamp(0.0, w);
        final double controlX = (endX + midWave).clamp(0.0, w);

        path.quadraticBezierTo(controlX, midY, targetX, y);
      }

      path.lineTo(0, h);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant LiquidWaveClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.fromRight != fromRight;
  }
}

// Definicion principal de la clase [LiquidWaveEdgePainter]
class LiquidWaveEdgePainter extends CustomPainter {
  final double progress;
  final bool fromRight;
  final Color waveColor;

  const LiquidWaveEdgePainter({
    required this.progress,
    required this.fromRight,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01 || progress >= 0.98) return;

    final double w = size.width;
    final double h = size.height;

    double baseFraction;
    if (progress <= 0.38) {
      final double p1 = Curves.easeOutCubic.transform(progress / 0.38);
      baseFraction = p1 * 0.28;
    } else {
      final double p2 = Curves.easeInOutCubic.transform((progress - 0.38) / 0.62);
      baseFraction = 0.28 + p2 * 0.80;
    }

    final double waveDecay = (1.0 - progress).clamp(0.0, 1.0);
    final double amplitude = math.sin(progress * math.pi) * 44.0 * waveDecay;
    final double waveOffset = progress * math.pi * 4.5;

    final Path edgePath = Path();
    final int segments = 28;
    final double dy = h / segments;

    final double startX = fromRight ? (w - (baseFraction * w)) : (baseFraction * w);
    edgePath.moveTo(startX, 0);

    for (int i = 1; i <= segments; i++) {
      final double y = i * dy;
      final double prevY = (i - 1) * dy;
      final double midY = (prevY + y) / 2;

      final double wave1 = math.sin((y / h) * math.pi * 2.8 + waveOffset) * amplitude;
      final double midWave = math.sin((midY / h) * math.pi * 2.8 + waveOffset) * amplitude;

      final double targetX = (startX + wave1).clamp(0.0, w);
      final double controlX = (startX + midWave).clamp(0.0, w);

      edgePath.quadraticBezierTo(controlX, midY, targetX, y);
    }

    // Sombra de elevación líquida suave y sutil
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.10 * (1.0 - progress))
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    // Resplandor LED celeste claro difuso
    final Paint glowPaint = Paint()
      ..color = waveColor.withValues(alpha: 0.28 * (1.0 - progress))
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

    // Línea fina y elegante de la ola
    final Paint linePaint = Paint()
      ..color = waveColor.withValues(alpha: 0.72 * (1.0 - progress))
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(edgePath, shadowPaint);
    canvas.drawPath(edgePath, glowPaint);
    canvas.drawPath(edgePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant LiquidWaveEdgePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fromRight != fromRight ||
        oldDelegate.waveColor != waveColor;
  }
}
