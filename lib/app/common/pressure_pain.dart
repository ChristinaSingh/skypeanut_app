import 'dart:math';

import 'package:flutter/material.dart';

class PressureGaugePainter extends CustomPainter {
  final double percent;

  PressureGaugePainter(this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final int totalTicks = 60;
    final double radius = size.width / 2.5;
    final Offset center = Offset(radius, radius);

    for (int i = 0; i < totalTicks; i++) {
      double angle = (i / totalTicks) * 2 * 3.1415926;
      double outerX = center.dx + radius * 0.9 * cos(angle);
      double outerY = center.dy + radius * 0.9 * sin(angle);
      double innerX = center.dx + radius * 0.75 * cos(angle);
      double innerY = center.dy + radius * 0.75 * sin(angle);

      final Paint paint = i <= (percent * totalTicks).floor() ? progressPaint : basePaint;

      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), paint);
    }

    // Pointer
    double pointerAngle = percent * 2 * 3.1415926;
    double pointerX = center.dx + radius * 0.75 * cos(pointerAngle);
    double pointerY = center.dy + radius * 0.75 * sin(pointerAngle);

    canvas.drawCircle(Offset(pointerX, pointerY), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant PressureGaugePainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}
