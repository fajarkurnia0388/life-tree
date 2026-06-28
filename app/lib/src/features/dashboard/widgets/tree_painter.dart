import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Seeded Random helper to generate deterministic but organic-looking distributions.
/// Prevents the tree foliage and branches from flickering during smooth animation.
class SeededRandom {
  int seed;
  SeededRandom(this.seed);

  double nextDouble() {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed / 0x7fffffff;
  }

  double range(double min, double max) => min + nextDouble() * (max - min);
}

/// Structural branch definition for the continuous growth model.
class BranchConfig {
  final double startT; // Position along parent trunk/branch (0.0 to 1.0)
  final double angle; // Angle in radians relative to parent direction
  final double lengthFactor; // Max length relative to parent length
  final double minDays; // Day on which this branch starts emerging

  const BranchConfig({
    required this.startT,
    required this.angle,
    required this.lengthFactor,
    required this.minDays,
  });
}

/// A highly organic, generative tree painter.
/// Simulates continuous growth from 0 to 100 days:
/// - Days 0-2: Seed germinates.
/// - Days 3-7: Sprout grows, winding up with small leaves.
/// - Days 8-100: Custom curvy trunk, wood grain patterns, concentric knots,
///   and a recursive branching system with tapered wavy twigs and detailed leaf clusters.
class OrganicTreePainter extends CustomPainter {
  final double days;
  final String skinId;
  final bool isRecovery;

  const OrganicTreePainter({
    required this.days,
    required this.skinId,
    this.isRecovery = false,
  });

  // ─── Color Palettes ────────────────────────────────────────────────────────

  Color get _trunkBase =>
      isRecovery ? const Color(0xFF9E8B7D) : const Color(0xFF8B6B4F);
  Color get _trunkDark =>
      isRecovery ? const Color(0xFF7A6458) : const Color(0xFF5D4037);
  Color get _trunkHighlight =>
      isRecovery ? const Color(0xFFB0A090) : const Color(0xFFBFA07A);

  List<Color> get _leafColors {
    if (isRecovery) {
      return [
        const Color(0xFFE0F7FA), // Ice white
        const Color(0xFFB2EBF2), // Pale blue
        const Color(0xFF80DEEA), // Soft cyan
        const Color(0xFF4DD0E1), // Bright icy blue
      ];
    }
    return switch (skinId) {
      'Sakura' => [
          const Color(0xFFF48FB1), // Soft pink
          const Color(0xFFF06292), // Medium pink
          const Color(0xFFE91E63), // Magenta
          const Color(0xFFF8BBD0), // Light blush
          const Color(0xFFFFF5F7), // White cherry petal
        ],
      'Maple' => [
          const Color(0xFFE65100), // Deep orange
          const Color(0xFFBF360C), // Red-orange
          const Color(0xFFFF9800), // Bright gold
          const Color(0xFFFFB74D), // Light warm yellow
        ],
      'Bonsai' => [
          const Color(0xFF1B5E20), // Dark pine green
          const Color(0xFF2E7D32), // Forest green
          const Color(0xFF388E3C), // Bright green
          const Color(0xFF1b4332), // Deep olive shadow
        ],
      _ => [
          const Color(0xFF2E7D32), // Deep green
          const Color(0xFF4CAF50), // Leaf green
          const Color(0xFF8BC34A), // Lime green
          const Color(0xFFC5E1A5), // Light spring green
        ],
    };
  }

  // ─── Branch Layout ─────────────────────────────────────────────────────────

  static const List<BranchConfig> _primaryBranches = [
    // Lower level branches
    BranchConfig(startT: 0.35, angle: 0.58, lengthFactor: 0.46, minDays: 10), // Right
    BranchConfig(startT: 0.42, angle: 2.56, lengthFactor: 0.44, minDays: 14), // Left
    // Mid level branches
    BranchConfig(startT: 0.58, angle: 0.68, lengthFactor: 0.40, minDays: 18), // Right
    BranchConfig(startT: 0.64, angle: 2.46, lengthFactor: 0.38, minDays: 22), // Left
    // Upper level branches
    BranchConfig(startT: 0.78, angle: 0.78, lengthFactor: 0.34, minDays: 26), // Right
    BranchConfig(startT: 0.83, angle: 2.36, lengthFactor: 0.32, minDays: 30), // Left
    // Apex crown branches
    BranchConfig(startT: 0.95, angle: 1.05, lengthFactor: 0.28, minDays: 35), // Right
    BranchConfig(startT: 0.98, angle: 2.09, lengthFactor: 0.26, minDays: 40), // Left
  ];

  // ─── Paint Dispatch ────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    if (days < 3.0) {
      _paintSeed(canvas, size);
    } else if (days < 8.0) {
      _paintSprout(canvas, size);
    } else {
      _paintTree(canvas, size);
    }
  }

  // ─── SEED ──────────────────────────────────────────────────────────────────

  void _paintSeed(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;
    final r = size.width * 0.055;
    final t = days.clamp(0.0, 3.0) / 3.0; // Growth interpolation

    // Soil mound
    final mound = Path()
      ..moveTo(cx - r * 4, gy + r * 0.5)
      ..quadraticBezierTo(cx, gy - r * (1.2 + 0.4 * t), cx + r * 4, gy + r * 0.5)
      ..close();
    canvas.drawPath(mound, Paint()..color = const Color(0xFF6D4C41));

    // Seed body
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, gy - r * (0.6 + 0.4 * t)),
        width: r * (1.6 + 0.8 * t),
        height: r * (2.0 + 1.0 * t),
      ),
      Paint()..color = const Color(0xFF795548),
    );

    // Seed cap
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, gy - r * (1.1 + 0.7 * t)),
        width: r * (1.8 + 1.0 * t),
        height: r * (1.2 + 0.6 * t),
      ),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF5D4037),
    );

    // Sprout tip emerging (only after day 1)
    if (days > 1.0) {
      final sproutGrow = (days - 1.0) / 2.0;
      final spPaint = Paint()
        ..color = const Color(0xFF8BC34A)
        ..strokeWidth = r * 0.25 * sproutGrow
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final spPath = Path()
        ..moveTo(cx, gy - r * 1.8)
        ..quadraticBezierTo(
          cx + r * 0.3 * sproutGrow,
          gy - r * (1.8 + 0.8 * sproutGrow),
          cx - r * 0.1 * sproutGrow,
          gy - r * (1.8 + 1.4 * sproutGrow),
        );
      canvas.drawPath(spPath, spPaint);
    }
  }

  // ─── SPROUT ────────────────────────────────────────────────────────────────

  void _paintSprout(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;
    final progress = (days - 3.0) / 5.0; // 0.0 to 1.0

    final stemH = size.height * (0.12 + 0.16 * progress);
    final stemW = size.width * (0.01 + 0.01 * progress);

    // Soil base
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, gy + 2),
        width: stemW * 12,
        height: stemW * 4,
      ),
      Paint()..color = const Color(0xFF8D6E63),
    );

    // Organic wavy stem path
    final stemPath = Path()
      ..moveTo(cx, gy)
      ..cubicTo(
        cx - stemW * 3 * math.sin(progress * math.pi),
        gy - stemH * 0.4,
        cx + stemW * 4 * math.cos(progress * math.pi),
        gy - stemH * 0.75,
        cx,
        gy - stemH,
      );

    canvas.drawPath(
      stemPath,
      Paint()
        ..color = const Color(0xFF689F38)
        ..strokeWidth = stemW * 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Draw small leaves along the growing stem
    final leafCount = (2 + 4 * progress).toInt();
    for (int i = 0; i < leafCount; i++) {
      final t = (i + 1) / (leafCount + 1);
      final ly = gy - stemH * t;
      final lx = cx + math.sin(t * math.pi * 2) * stemW * 2;
      final leafSide = i.isEven ? 1.0 : -1.0;
      final angle = leafSide * (0.3 + 0.2 * t);

      _drawOrganicLeaf(
        canvas,
        Offset(lx, ly),
        size.width * (0.05 + 0.04 * progress),
        angle,
        _leafColors[i % _leafColors.length],
      );
    }
  }

  // ─── TREE (GROWTH & ORGANIC PATTERNS) ──────────────────────────────────────

  // Cubic Bezier center curve for the winding trunk
  Offset _getTrunkPoint(double t, double cx, double gy, double trunkH, double trunkW) {
    final p0 = Offset(cx, gy);
    // Wavy control points to give natural trunk curvature/bends
    final p1 = Offset(cx - trunkW * 0.65, gy - trunkH * 0.32);
    final p2 = Offset(cx + trunkW * 0.45, gy - trunkH * 0.68);
    final p3 = Offset(cx - trunkW * 0.15, gy - trunkH);

    final mt = 1.0 - t;
    return p0 * (mt * mt * mt) +
        p1 * (3 * mt * mt * t) +
        p2 * (3 * mt * t * t) +
        p3 * (t * t * t);
  }

  void _paintTree(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;

    // Continuous dynamic scaling from day 8 to 100
    final tProgress = ((days - 8.0) / 92.0).clamp(0.0, 1.0);
    final smoothProgress = Curves.easeInOut.transform(tProgress);

    final trunkH = size.height * (0.24 + 0.26 * smoothProgress);
    final trunkW = size.width * (0.035 + 0.075 * smoothProgress);

    // 1. Draw Root Flares
    _drawRootFlares(canvas, cx, gy, trunkW, smoothProgress);

    // 2. Build and Draw Curvy Trunk Path
    final trunkPath = Path();
    trunkPath.moveTo(cx - trunkW / 2, gy);

    // Left boundary curve
    for (double t = 0.02; t <= 1.0; t += 0.02) {
      final pt = _getTrunkPoint(t, cx, gy, trunkH, trunkW);
      final w = trunkW * (1.0 - t * 0.52); // Tapering
      trunkPath.lineTo(pt.dx - w / 2, pt.dy);
    }
    // Right boundary curve
    for (double t = 1.0; t >= 0.0; t -= 0.02) {
      final pt = _getTrunkPoint(t, cx, gy, trunkH, trunkW);
      final w = trunkW * (1.0 - t * 0.52);
      trunkPath.lineTo(pt.dx + w / 2, pt.dy);
    }
    trunkPath.close();

    // Fill trunk with gradient shading
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_trunkDark, _trunkHighlight, _trunkBase, _trunkDark],
        stops: const [0.0, 0.28, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(cx - trunkW / 2, gy - trunkH, trunkW, trunkH));

    canvas.drawPath(trunkPath, trunkPaint);

    // 3. Draw wood grain/texture patterns inside the trunk
    canvas.save();
    canvas.clipPath(trunkPath);

    final grainPaint = Paint()
      ..color = _trunkDark.withOpacity(0.30)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw wavy fiber lines
    for (double shift in [-0.3, 0.0, 0.3]) {
      final fiberPath = Path();
      final startPt = _getTrunkPoint(0.0, cx, gy, trunkH, trunkW);
      fiberPath.moveTo(startPt.dx + shift * trunkW * 0.4, startPt.dy);

      for (double t = 0.05; t <= 1.0; t += 0.05) {
        final pt = _getTrunkPoint(t, cx, gy, trunkH, trunkW);
        final w = trunkW * (1.0 - t * 0.52);
        // Add a wobble pattern
        final wobble = math.sin(t * math.pi * 5.0) * (trunkW * 0.03);
        fiberPath.lineTo(pt.dx + shift * w * 0.4 + wobble, pt.dy);
      }
      canvas.drawPath(fiberPath, grainPaint);
    }

    // Concentric knot rings (only for older trees)
    if (days >= 20.0) {
      final knotPt1 = _getTrunkPoint(0.32, cx, gy, trunkH, trunkW);
      canvas.drawOval(
        Rect.fromCenter(center: knotPt1, width: trunkW * 0.32, height: trunkW * 0.16),
        Paint()
          ..color = _trunkDark.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
      canvas.drawOval(
        Rect.fromCenter(center: knotPt1, width: trunkW * 0.16, height: trunkW * 0.08),
        Paint()..color = _trunkDark.withOpacity(0.45),
      );
    }

    canvas.restore();

    // 4. Draw Branches & Leaf Clusters recursively
    // A single seeded random to make animations smooth & stable
    final random = SeededRandom(skinId.hashCode + 88);

    for (final branch in _primaryBranches) {
      if (days < branch.minDays) continue;

      final trunkAttach = _getTrunkPoint(branch.startT, cx, gy, trunkH, trunkW);
      final bLength = trunkH * branch.lengthFactor;
      final bWidth = trunkW * 0.22;

      _drawOrganicBranch(
        canvas: canvas,
        start: trunkAttach,
        angle: branch.angle,
        length: bLength,
        startWidth: bWidth,
        currentDays: days,
        minDays: branch.minDays,
        depth: 0,
        random: random,
        r: size.width * 0.80,
      );
    }
  }

  /// Procedural recursive organic branch generator.
  /// Simulates natural tapering, wavy curvature, and splits into smaller sub-branches.
  void _drawOrganicBranch({
    required Canvas canvas,
    required Offset start,
    required double angle,
    required double length,
    required double startWidth,
    required double currentDays,
    required double minDays,
    required int depth,
    required SeededRandom random,
    required double r,
  }) {
    if (currentDays < minDays) return;

    // Calculate growth factor for this branch
    final age = currentDays - minDays;
    final bProgress = (age / 12.0).clamp(0.0, 1.0);
    final bGrow = Curves.easeOut.transform(bProgress);

    final actualLength = length * bGrow;

    // Divide the branch into 3 segments to draw organic curvature/bends
    const segments = 3;
    var currentPos = start;
    var currentAngle = angle;
    final points = <Offset>[currentPos];
    final widths = <double>[startWidth];

    final stepLen = actualLength / segments;

    for (int i = 1; i <= segments; i++) {
      final t = i / segments;
      // Wobbly curvature bend (wobbles more as it gets thinner)
      final bend = random.range(-0.16, 0.16) * (1.0 + depth * 0.3);
      currentAngle += bend;

      currentPos = currentPos + Offset(math.cos(currentAngle) * stepLen, -math.sin(currentAngle) * stepLen);
      points.add(currentPos);
      widths.add(startWidth * (1.0 - t * 0.52) * bGrow); // Tapering
    }

    // Paint the tapered wobbly branch segment by segment
    for (int i = 0; i < segments; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final avgW = (widths[i] + widths[i + 1]) / 2;

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = _trunkBase
          ..strokeWidth = avgW
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    final endPoint = points.last;

    // Recursive secondary and tertiary branching
    if (depth < 2) {
      final nextDepth = depth + 1;
      final subMinDays = minDays + 5 + depth * 4;

      if (currentDays >= subMinDays) {
        // Left sub-branch
        final leftAngle = currentAngle + random.range(0.32, 0.48);
        final leftLength = length * random.range(0.50, 0.65);
        _drawOrganicBranch(
          canvas: canvas,
          start: endPoint,
          angle: leftAngle,
          length: leftLength,
          startWidth: widths.last * 0.7,
          currentDays: currentDays,
          minDays: subMinDays,
          depth: nextDepth,
          random: random,
          r: r,
        );

        // Right sub-branch
        final rightAngle = currentAngle - random.range(0.32, 0.48);
        final rightLength = length * random.range(0.50, 0.65);
        _drawOrganicBranch(
          canvas: canvas,
          start: endPoint,
          angle: rightAngle,
          length: rightLength,
          startWidth: widths.last * 0.7,
          currentDays: currentDays,
          minDays: subMinDays + 2.0,
          depth: nextDepth,
          random: random,
          r: r,
        );
      }
    }

    // Put leaf clusters at the tips and along the branches
    if (depth == 2) {
      // Twigs get dense clusters at the tip and smaller clusters along their path
      _drawLeafCluster(canvas, endPoint, r * 0.16 * bGrow, 18, random);
      _drawLeafCluster(canvas, points[1], r * 0.12 * bGrow, 10, random);
    } else if (depth == 1) {
      // Secondary branches get leaf clusters at segment joints and the tip
      _drawLeafCluster(canvas, endPoint, r * 0.18 * bGrow, 22, random);
      _drawLeafCluster(canvas, points[2], r * 0.15 * bGrow, 16, random);
      _drawLeafCluster(canvas, points[1], r * 0.11 * bGrow, 10, random);
    } else if (depth == 0) {
      // Primary branches get leaf clusters along their mid/outer parts
      _drawLeafCluster(canvas, points[2], r * 0.20 * bGrow, 24, random);
      _drawLeafCluster(canvas, points[1], r * 0.15 * bGrow, 14, random);
    }
  }

  // ─── ROOT FLARES ───────────────────────────────────────────────────────────

  void _drawRootFlares(Canvas canvas, double cx, double gy, double trunkW, double progress) {
    final rootPaint = Paint()..color = _trunkDark.withOpacity(0.58);
    final maxSpread = trunkW * (1.2 + 0.8 * progress);

    // Left Root
    final leftRoot = Path()
      ..moveTo(cx - trunkW * 0.4, gy)
      ..quadraticBezierTo(cx - maxSpread, gy - trunkW * 0.2, cx - maxSpread * 1.5, gy + trunkW * 0.15)
      ..quadraticBezierTo(cx - maxSpread * 0.8, gy + trunkW * 0.22, cx - trunkW * 0.2, gy + trunkW * 0.05)
      ..close();
    canvas.drawPath(leftRoot, rootPaint);

    // Right Root
    final rightRoot = Path()
      ..moveTo(cx + trunkW * 0.4, gy)
      ..quadraticBezierTo(cx + maxSpread, gy - trunkW * 0.18, cx + maxSpread * 1.4, gy + trunkW * 0.18)
      ..quadraticBezierTo(cx + maxSpread * 0.7, gy + trunkW * 0.22, cx + trunkW * 0.2, gy + trunkW * 0.05)
      ..close();
    canvas.drawPath(rightRoot, rootPaint);
  }

  // ─── LEAF CLUSTERS ("HIMPUNAN DAUN-DAUN KECIL") ──────────────────────────────

  /// Draws a dense, beautiful cluster of tiny organic leaves at branch endpoints.
  void _drawLeafCluster(Canvas canvas, Offset center, double maxRadius, int leafCount, SeededRandom random) {
    if (maxRadius < 1.5) return;

    // Draw leaves in 3 depth layers to create natural shading & volume
    final layers = [
      (count: (leafCount * 0.35).toInt(), colorOpacity: 0.9, scale: 0.85, shadow: true),  // Dark back layer
      (count: (leafCount * 0.45).toInt(), colorOpacity: 1.0, scale: 1.0, shadow: false),  // Mid base layer
      (count: (leafCount * 0.20).toInt(), colorOpacity: 1.0, scale: 0.75, shadow: false),  // Light crown layer
    ];

    for (int l = 0; l < layers.length; l++) {
      final layer = layers[l];
      for (int i = 0; i < layer.count; i++) {
        // Distribute leaves using golden ratio/sunflower style distribution for organic feel
        final dist = maxRadius * math.sqrt(random.nextDouble()) * layer.scale;
        final angle = random.range(0.0, 2 * math.pi);
        final leafPos = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist * 0.8);

        final leafAngle = random.range(0.0, 2 * math.pi);
        final leafSize = maxRadius * random.range(0.12, 0.25) * layer.scale;

        // Choose color from palette based on layer depth
        final colorIndex = switch (l) {
          0 => 0, // Darkest base
          1 => random.range(1.0, 3.0).toInt(), // Mid-light tones
          _ => _leafColors.length - 1, // Bright highlight
        };
        final color = _leafColors[colorIndex].withOpacity(layer.colorOpacity);

        // Draw leaf drop shadow
        if (layer.shadow) {
          canvas.drawCircle(
            leafPos + const Offset(1, 1.5),
            leafSize * 0.4,
            Paint()..color = Colors.black.withOpacity(0.05),
          );
        }

        _drawOrganicLeaf(canvas, leafPos, leafSize, leafAngle, color);
      }
    }
  }

  void _drawOrganicLeaf(Canvas canvas, Offset pos, double size, double angle, Color color) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size * 0.5, -size * 0.38, size, 0)
      ..quadraticBezierTo(size * 0.5, size * 0.38, 0, 0)
      ..close();

    canvas.drawPath(leafPath, Paint()..color = color);

    // Leaf center vein
    canvas.drawLine(
      Offset.zero,
      Offset(size * 0.8, 0),
      Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..strokeWidth = size * 0.08
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(OrganicTreePainter old) =>
      old.days != days || old.skinId != skinId || old.isRecovery != isRecovery;
}
