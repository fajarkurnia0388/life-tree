import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> scores;

  const RadarChartWidget({
    super.key,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Radar Keseimbangan Hidup 🎡',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Distribusi kemajuan di 6 domain kehidupan. Domain non-aktif terkunci di batas aman.',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              width: 200,
              child: CustomPaint(
                painter: _RadarChartPainter(
                  scores: scores,
                  primaryColor: theme.colorScheme.primary,
                  onBackgroundColor: theme.colorScheme.onBackground,
                  cardColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<String, double> scores;
  final Color primaryColor;
  final Color onBackgroundColor;
  final Color cardColor;

  static const List<String> _domains = [
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi'
  ];

  _RadarChartPainter({
    required this.scores,
    required this.primaryColor,
    required this.onBackgroundColor,
    required this.cardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width / 2, size.height / 2) - 20;

    // Paints
    final gridPaint = Paint()
      ..color = onBackgroundColor.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final axisPaint = Paint()
      ..color = onBackgroundColor.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final dataPaint = Paint()
      ..color = primaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw concentric hexagons
    const int levels = 3;
    for (int i = 1; i <= levels; i++) {
      final radius = maxRadius * (i / levels);
      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = (j * 60) * math.pi / 180 - math.pi / 2;
        final point = Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.pointY(angle, radius, center)); // helper function replacement
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines and labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180 - math.pi / 2;
      final outerPoint = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );
      canvas.drawLine(center, outerPoint, axisPaint);

      // Draw label
      final domain = _domains[i];
      final isSoon = domain != 'Tubuh';
      final labelText = isSoon ? '$domain\n(Soon)' : domain;

      textPainter.text = TextSpan(
        text: labelText,
        style: TextStyle(
          fontSize: 9,
          fontWeight: isSoon ? FontWeight.normal : FontWeight.bold,
          color: isSoon ? onBackgroundColor.withOpacity(0.4) : primaryColor,
        ),
      );
      textPainter.layout();

      // Calculate label positioning offset to prevent overlapping
      final labelRadius = maxRadius + 14;
      final labelX = center.dx + labelRadius * math.cos(angle) - textPainter.width / 2;
      final labelY = center.dy + labelRadius * math.sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(labelX, labelY));
    }

    // Draw filled scores polygon
    final dataPath = Path();
    for (int i = 0; i < 6; i++) {
      final domain = _domains[i];
      final rawScore = scores[domain] ?? 0.0;
      // Normalise score from 1-10
      final normalizedScore = rawScore.clamp(0.0, 10.0) / 10.0;
      final radius = maxRadius * normalizedScore;
      final angle = (i * 60) * math.pi / 180 - math.pi / 2;

      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

extension OffsetHelper on Offset {
  double pointY(double angle, double radius, Offset center) {
    return center.dy + radius * math.sin(angle);
  }
}
