import 'dart:math' as math;
import 'package:flutter/material.dart';

class DrawProgress extends StatelessWidget {
  final double total;
  final double completed;
  final double inProgress;
  final double delayed;
  final String totalTimeText;
  final String totalCountText;

  const DrawProgress({
    super.key,
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.delayed,
    required this.totalTimeText,
    required this.totalCountText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _DrawProgress(
            total: total,
            completed: completed,
            inProgress: inProgress,
            delayed: delayed,
          ),
          size: const Size(120, 120),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              totalCountText,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              totalTimeText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DrawProgress extends CustomPainter {
  final double total;
  final double completed;
  final double inProgress;
  final double delayed;

  _DrawProgress({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.delayed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    final strokeWidth = 10.0;

    final totalAngleRad = math.pi; // 180°
    final startAngle = -math.pi; // 从顶部开始

    double getAngle(double value) => (value / total) * totalAngleRad;

    final completedAngle = getAngle(completed);
    final inProgressAngle = getAngle(inProgress);
    final delayedAngle = getAngle(delayed);

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double currentAngle = startAngle;

    // 完成 - 绿色
    paint.color = Colors.green;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      currentAngle,
      completedAngle,
      false,
      paint,
    );
    currentAngle += completedAngle;

    // 进行中 - 蓝色
    paint.color = Colors.blue;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      currentAngle,
      inProgressAngle,
      false,
      paint,
    );
    currentAngle += inProgressAngle;

    // 延误 - 红色
    paint.color = Colors.red;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      currentAngle,
      delayedAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
