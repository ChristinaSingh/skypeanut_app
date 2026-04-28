import 'package:flutter/material.dart';
import 'dart:math';

import 'colors.dart';


class SpiralLoader extends StatefulWidget {
  const SpiralLoader({super.key});

  @override
  State<SpiralLoader> createState() => _SpiralLoaderState();
}

class _SpiralLoaderState extends State<SpiralLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return CustomPaint(
          painter: SpiralPainter(_controller.value),
          child: const SizedBox(width: 100, height: 100),
        );
      },
    );
  }
}

class SpiralPainter extends CustomPainter {
  final double progress;
  SpiralPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(2 * pi * progress);

    final gradient = SweepGradient(
      colors: [primaryColor, primaryColor2],
      startAngle: 2,
      endAngle: 2 * pi,
    );

    final rect = Rect.fromCircle(center: Offset.zero, radius: size.width / 2);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawArc(canvas, paint, 30, 80, true);
    _drawArc(canvas, paint, 60, 260, true);
  }

  void _drawArc(Canvas canvas, Paint paint, double radius, double sweepAngle, bool reverse) {
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawArc(
      rect,
      reverse ? pi : -pi / 2,
      radians(sweepAngle),
      false,
      paint,
    );
  }

  double radians(double degrees) => degrees * (pi / 180);

  @override
  bool shouldRepaint(covariant SpiralPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
