import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadarChartWidget extends StatelessWidget {
  final Map<String, double> scores;
  final Set<String> activeDomains;
  final String? selectedDomain;
  final ValueChanged<String>? onDomainSelected;

  const RadarChartWidget({
    super.key,
    required this.scores,
    required this.activeDomains,
    this.selectedDomain,
    this.onDomainSelected,
  });

  static const List<String> _domains = [
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi'
  ];

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
              'Ketuk nama domain pada radar untuk memfokuskan dasbor. Domain non-aktif diberi tanda (Soon).',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              width: 260,
              child: GestureDetector(
                onTapUp: (details) {
                  if (onDomainSelected == null) return;
                  const center = Offset(130, 130);
                  const maxRadius = 110.0;
                  const labelRadius = maxRadius + 14.0;

                  for (int i = 0; i < 6; i++) {
                    final angle = (i * 60) * math.pi / 180 - math.pi / 2;
                    final labelCenter = Offset(
                      center.dx + labelRadius * math.cos(angle),
                      center.dy + labelRadius * math.sin(angle),
                    );
                    final tapPos = details.localPosition;
                    final distance = (tapPos - labelCenter).distance;
                    if (distance < 30.0) { // Click target sensitivity radius
                      final clickedDomain = _domains[i];
                      onDomainSelected!(clickedDomain);
                      break;
                    }
                  }
                },
                child: CustomPaint(
                  painter: _RadarChartPainter(
                    scores: scores,
                    activeDomains: activeDomains,
                    selectedDomain: selectedDomain,
                    primaryColor: theme.colorScheme.primary,
                    onBackgroundColor: theme.colorScheme.onBackground,
                    cardColor: theme.cardTheme.color ?? theme.colorScheme.surface,
                  ),
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
  final Set<String> activeDomains;
  final String? selectedDomain;
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
    required this.activeDomains,
    required this.selectedDomain,
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
          path.lineTo(point.dx, point.dy);
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
      final domain = _domains[i];
      final angle = (i * 60) * math.pi / 180 - math.pi / 2;
      final outerPoint = Offset(
        center.dx + maxRadius * math.cos(angle),
        center.dy + maxRadius * math.sin(angle),
      );

      final isSelected = domain == selectedDomain;

      if (isSelected) {
        final selectedAxisPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawLine(center, outerPoint, selectedAxisPaint);
      } else {
        canvas.drawLine(center, outerPoint, axisPaint);
      }

      // Draw label
      final isActive = activeDomains.contains(domain);
      final isSoon = !isActive;
      final labelText = isSoon ? '$domain\n(Soon)' : domain;

      textPainter.text = TextSpan(
        text: labelText,
        style: TextStyle(
          fontSize: isSelected ? 10 : 9,
          fontWeight: isSelected ? FontWeight.bold : (isSoon ? FontWeight.normal : FontWeight.w600),
          color: isSelected
              ? primaryColor
              : (isSoon ? onBackgroundColor.withOpacity(0.35) : onBackgroundColor.withOpacity(0.85)),
        ),
      );
      textPainter.layout();

      // Calculate label positioning offset to prevent overlapping
      final labelRadius = maxRadius + 14;
      final labelX = center.dx + labelRadius * math.cos(angle) - textPainter.width / 2;
      final labelY = center.dy + labelRadius * math.sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(labelX, labelY));

      // Draw a glowing indicator dot if selected
      if (isSelected) {
        final dotPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill;
        final dotRadius = 3.0;
        final dotPos = Offset(
          center.dx + (labelRadius + 16) * math.cos(angle),
          center.dy + (labelRadius + 16) * math.sin(angle),
        );
        canvas.drawCircle(dotPos, dotRadius, dotPaint);
      }
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
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.activeDomains != activeDomains ||
        oldDelegate.selectedDomain != selectedDomain;
  }
}
