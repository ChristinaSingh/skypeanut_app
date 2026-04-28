import 'package:flutter/material.dart';

class SunPathPainter extends CustomPainter {
  final double progress;

  SunPathPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint curvePaint = Paint()
      ..color = Colors.lightBlueAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final Paint darkPaint = Paint()
      ..color = Colors.blue.shade900
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    final darkPath = Path();

    final start = Offset(0, size.height);
    final peak = Offset(size.width / 2, 0);
    final end = Offset(size.width, size.height);

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(peak.dx, peak.dy, end.dx, end.dy);

    // dark side
    darkPath.moveTo(start.dx, start.dy);
    darkPath.quadraticBezierTo(peak.dx, peak.dy, end.dx, end.dy);

    // Clip path for only the visible part before the sun
    final visibleLength = size.width * progress;
    final clipPath = Path();
    clipPath.addRect(Rect.fromLTWH(0, 0, visibleLength, size.height));

    canvas.save();
    canvas.clipPath(clipPath);
    canvas.drawPath(path, curvePaint);
    canvas.restore();

    canvas.drawPath(darkPath, darkPaint);

    // Draw sun
    final sunX = size.width * progress;
    final sunY = _calculateY(start, peak, end, sunX);
    canvas.drawCircle(Offset(sunX, sunY), 6, Paint()..color = Colors.white);
  }

  double _calculateY(Offset start, Offset peak, Offset end, double x) {
    double t = x / end.dx;
    return (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * peak.dy + t * t * end.dy;
  }

  @override
  bool shouldRepaint(covariant SunPathPainter oldDelegate) => true;
}
