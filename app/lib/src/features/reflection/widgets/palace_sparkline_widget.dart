import 'dart:math';
import 'package:flutter/material.dart';

class PalaceSparklineWidget extends StatelessWidget {
  final String title;
  final List<double> scores;
  final Color color;

  const PalaceSparklineWidget({
    super.key,
    required this.title,
    required this.scores,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If less than 2 data points, show a flat baseline line
    final dataPoints = scores.isEmpty
        ? [5.0, 5.0]
        : scores.length == 1
            ? [scores.first, scores.first]
            : scores;

    final latestScore = scores.isEmpty ? 5.0 : scores.last;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Skor Saat Ini: ${latestScore.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 36,
                child: CustomPaint(
                  painter: _SparklinePainter(dataPoints, color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final double widthBetweenPoints = size.width / (data.length - 1);

    // Bound values strictly to 1.0 - 10.0 scale
    double getX(int index) => index * widthBetweenPoints;
    double getY(double val) {
      final normalized = (val - 1.0) / 9.0; // Normalized between 0.0 and 1.0
      return size.height - (normalized * size.height);
    }

    path.moveTo(getX(0), getY(data[0]));
    fillPath.moveTo(getX(0), size.height);
    fillPath.lineTo(getX(0), getY(data[0]));

    for (int i = 1; i < data.length; i++) {
      path.lineTo(getX(i), getY(data[i]));
      fillPath.lineTo(getX(i), getY(data[i]));
    }

    fillPath.lineTo(getX(data.length - 1), size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw active dot at the last point
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(getX(data.length - 1), getY(data[data.length - 1])),
      3.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
