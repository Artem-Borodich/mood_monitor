import 'package:flutter/material.dart';

/// Soft abstract “bloom” for wellness cards (no raster assets).
class SoftBloomPainter extends CustomPainter {
  SoftBloomPainter({required this.color, this.spread = 1.0});

  final Color color;
  final double spread;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.85, size.height * 0.12);
    final r = size.shortestSide * 0.55 * spread;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, paint);

    final c2 = Offset(size.width * 0.08, size.height * 0.88);
    final r2 = size.shortestSide * 0.4 * spread;
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.14),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: c2, radius: r2));
    canvas.drawCircle(c2, r2, paint2);
  }

  @override
  bool shouldRepaint(covariant SoftBloomPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spread != spread;
}
