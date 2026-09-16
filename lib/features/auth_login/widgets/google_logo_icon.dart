import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Icono vectorial nítido del logotipo oficial de Google (4 colores)
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width * 0.20;
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Arcos de los 4 cuadrantes oficiales de Google
    // Rojo (superior)
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 0.50, false, redPaint);
    // Amarillo (izquierda)
    canvas.drawArc(rect, -math.pi * 1.25, math.pi * 0.50, false, yellowPaint);
    // Verde (inferior)
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.50, false, greenPaint);
    // Azul (arco derecho y barra horizontal)
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.50, false, bluePaint);

    final Paint blueBarPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Barra horizontal central del 'G'
    canvas.drawLine(
      Offset(center.dx - strokeWidth * 0.2, center.dy),
      Offset(size.width, center.dy),
      blueBarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
