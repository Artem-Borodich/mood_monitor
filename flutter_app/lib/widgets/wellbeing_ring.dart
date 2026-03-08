import 'dart:math';

import 'package:flutter/material.dart';

class WellbeingRing extends StatelessWidget {
  const WellbeingRing({
    super.key,
    required this.value,
    this.maxValue = 10,
  });

  final double? value;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized =
        value == null ? 0.0 : (value! / maxValue).clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: normalized),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) {
        return CustomPaint(
          painter: _RingPainter(
            progress: animated,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.25),
          ),
          child: SizedBox(
            width: 140,
            height: 140,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value?.toStringAsFixed(2) ?? '--',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wellbeing',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final rect = Offset.zero & size;
    final startAngle = -pi / 2;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round;

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * pi,
      colors: [
        color.withOpacity(0.2),
        color,
      ],
    );

    final foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final circleRect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      circleRect,
      startAngle,
      2 * pi,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      circleRect,
      startAngle,
      2 * pi * progress,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

