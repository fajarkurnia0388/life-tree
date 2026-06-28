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

/// Internal record describing a place where foliage should grow.
/// Collected during the branch pass and rendered afterwards so the whole
/// canopy can be composed as one cohesive mass (back-to-front).
class _FoliageNode {
  final Offset pos;
  final double radius;
  final double grow;
  _FoliageNode(this.pos, this.radius, this.grow);
}

/// A highly organic, generative tree painter.
/// Simulates continuous growth from 0 to 100 days:
/// - Days 0-2: Seed germinates.
/// - Days 3-7: Sprout grows, winding up with small leaves.
/// - Days 8-100: Custom curvy trunk, wood grain patterns, concentric knots,
///   a recursive branching system, and a cohesive layered canopy built from
///   soft foliage masses rather than scattered floating leaves.
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

  /// Darkest tone of the active palette — used as the canopy shadow base.
  Color get _foliageShadow => _leafColors.first;

  /// A representative mid tone for the canopy body fill.
  Color get _foliageBody => _leafColors[(_leafColors.length / 2).floor()];

  /// Brightest tone — used for sun-lit highlights on top of the canopy.
  Color get _foliageHighlight => _leafColors.last;

  // ─── Branch Layout ─────────────────────────────────────────────────────────

  static const List<BranchConfig> _primaryBranches = [
    // Lower level branches
    BranchConfig(startT: 0.38, angle: 0.62, lengthFactor: 0.50, minDays: 10), // Right
    BranchConfig(startT: 0.45, angle: 2.52, lengthFactor: 0.48, minDays: 14), // Left
    // Mid level branches
    BranchConfig(startT: 0.60, angle: 0.80, lengthFactor: 0.44, minDays: 18), // Right
    BranchConfig(startT: 0.66, angle: 2.34, lengthFactor: 0.42, minDays: 22), // Left
    // Upper level branches
    BranchConfig(startT: 0.80, angle: 0.98, lengthFactor: 0.36, minDays: 26), // Right
    BranchConfig(startT: 0.85, angle: 2.16, lengthFactor: 0.34, minDays: 30), // Left
    // Apex crown branches
    BranchConfig(startT: 0.96, angle: 1.35, lengthFactor: 0.30, minDays: 35), // Right
    BranchConfig(startT: 0.99, angle: 1.79, lengthFactor: 0.28, minDays: 40), // Left
  ];

  // Accumulates every place foliage should sprout during the branch pass.
  // (Reset on each paint so the painter stays stateless across frames.)

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

    // 4. Walk the branch system. Branches are drawn immediately, but foliage
    //    spots are *collected* (not drawn) so the entire canopy can be composed
    //    as one cohesive mass afterwards — this is the key to a natural look.
    final random = SeededRandom(skinId.hashCode + 88);
    final foliageNodes = <_FoliageNode>[];
    final canopyScale = size.width;

    for (final branch in _primaryBranches) {
      if (days < branch.minDays) continue;

      final trunkAttach = _getTrunkPoint(branch.startT, cx, gy, trunkH, trunkW);
      final bLength = trunkH * branch.lengthFactor;
      final bWidth = trunkW * 0.26;

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
        canopyScale: canopyScale,
        foliageNodes: foliageNodes,
      );
    }

    // 4b. Fill the inner crown so a mature tree has a full body (no hollow
    //     arch). These sit just above the upper trunk where the big limbs fork.
    if (days >= 28) {
      final crownGrow = ((days - 28) / 24).clamp(0.0, 1.0);
      final apex = _getTrunkPoint(0.96, cx, gy, trunkH, trunkW);
      final innerSpots = <Offset>[
        apex.translate(0, -canopyScale * 0.04),
        apex.translate(-canopyScale * 0.10, canopyScale * 0.02),
        apex.translate(canopyScale * 0.10, canopyScale * 0.02),
        apex.translate(-canopyScale * 0.05, -canopyScale * 0.10),
        apex.translate(canopyScale * 0.05, -canopyScale * 0.09),
      ];
      for (final s in innerSpots) {
        foliageNodes.add(_FoliageNode(s, canopyScale * 0.105 * crownGrow, crownGrow));
      }
    }

    // 5. Compose the canopy from the collected nodes, back-to-front.
    _drawCanopy(canvas, foliageNodes, random, smoothProgress);
  }

  /// Procedural recursive organic branch generator.
  /// Draws tapered, wavy branches and records (does not draw) foliage spots.
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
    required double canopyScale,
    required List<_FoliageNode> foliageNodes,
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
      final bend = random.range(-0.14, 0.14) * (1.0 + depth * 0.3);
      currentAngle += bend;

      currentPos = currentPos + Offset(math.cos(currentAngle) * stepLen, -math.sin(currentAngle) * stepLen);
      points.add(currentPos);
      widths.add(startWidth * (1.0 - t * 0.48) * bGrow); // Tapering
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
        final leftAngle = currentAngle + random.range(0.30, 0.46);
        final leftLength = length * random.range(0.52, 0.66);
        _drawOrganicBranch(
          canvas: canvas,
          start: endPoint,
          angle: leftAngle,
          length: leftLength,
          startWidth: widths.last * 0.72,
          currentDays: currentDays,
          minDays: subMinDays,
          depth: nextDepth,
          random: random,
          canopyScale: canopyScale,
          foliageNodes: foliageNodes,
        );

        // Right sub-branch
        final rightAngle = currentAngle - random.range(0.30, 0.46);
        final rightLength = length * random.range(0.52, 0.66);
        _drawOrganicBranch(
          canvas: canvas,
          start: endPoint,
          angle: rightAngle,
          length: rightLength,
          startWidth: widths.last * 0.72,
          currentDays: currentDays,
          minDays: subMinDays + 2.0,
          depth: nextDepth,
          random: random,
          canopyScale: canopyScale,
          foliageNodes: foliageNodes,
        );
      }
    }

    // Record foliage spots. Outer/thinner branches carry the densest foliage.
    // Radii are intentionally tied to branch position so clumps overlap their
    // neighbours and read as one continuous canopy instead of floating dots.
    if (depth == 2) {
      foliageNodes.add(_FoliageNode(endPoint, canopyScale * 0.115 * bGrow, bGrow));
      foliageNodes.add(_FoliageNode(points[2], canopyScale * 0.090 * bGrow, bGrow));
    } else if (depth == 1) {
      foliageNodes.add(_FoliageNode(endPoint, canopyScale * 0.130 * bGrow, bGrow));
      foliageNodes.add(_FoliageNode(points[2], canopyScale * 0.100 * bGrow, bGrow));
    } else if (depth == 0) {
      // Only seed a foliage spot at the very tip of a primary branch when it
      // has no children yet (young tree) so the base of big limbs stays clean.
      if (currentDays < minDays + 9) {
        foliageNodes.add(_FoliageNode(endPoint, canopyScale * 0.110 * bGrow, bGrow));
      }
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

  // ─── CANOPY (COHESIVE FOLIAGE MASS) ─────────────────────────────────────────

  /// Composes the whole crown in four passes so it reads as one connected,
  /// volumetric mass rather than scattered floating leaves:
  ///   1. A soft unifying shadow blob behind everything.
  ///   2. Dark base clumps (the body of the canopy).
  ///   3. Mid-tone clumps offset up-left to suggest form.
  ///   4. A scattering of individual leaves *only near clump centres* plus
  ///      bright highlights on the top-left (sun side) for texture.
  void _drawCanopy(
    Canvas canvas,
    List<_FoliageNode> nodes,
    SeededRandom random,
    double progress,
  ) {
    if (nodes.isEmpty) return;

    // ── Pass 1: unifying soft shadow that binds the clumps together ──
    // Slightly enlarged, blurred dark shapes merge neighbouring clumps so
    // there are no hard gaps between them.
    final shadowPaint = Paint()
      ..color = _foliageShadow.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    for (final n in nodes) {
      if (n.radius < 2) continue;
      canvas.drawCircle(n.pos, n.radius * 1.18, shadowPaint);
    }

    // ── Pass 2: dark base clumps (canopy body) ──
    final bodyPaint = Paint()..color = _foliageBody;
    for (final n in nodes) {
      if (n.radius < 2) continue;
      _drawClump(canvas, n.pos, n.radius, random, bodyPaint, jitter: 0.32);
    }

    // ── Pass 3: mid-tone form clumps for volume (slightly up-left) ──
    final lightOffset = Offset(-1, -1.6); // direction of the light source
    final midPaint = Paint()..color = _leafColors[1].withOpacity(0.95);
    for (final n in nodes) {
      if (n.radius < 3) continue;
      final lp = n.pos + lightOffset * (n.radius * 0.12);
      _drawClump(canvas, lp, n.radius * 0.74, random, midPaint, jitter: 0.30);
    }

    // ── Pass 3b: bright highlight only on the sun-lit crown (top-left) ──
    final litPaint = Paint()..color = _foliageHighlight.withOpacity(0.85);
    for (final n in nodes) {
      if (n.radius < 4) continue;
      final lp = n.pos + lightOffset * (n.radius * 0.30);
      _drawClump(canvas, lp, n.radius * 0.42, random, litPaint, jitter: 0.28);
    }

    // ── Pass 4: individual leaf texture + bright top highlights ──
    // Leaves are kept tightly around each clump centre (max 0.7 * radius) so
    // none of them float away from the canopy.
    for (final n in nodes) {
      if (n.radius < 4) continue;
      final leafCount = (n.radius * 0.55).round().clamp(4, 22);
      for (int i = 0; i < leafCount; i++) {
        // sqrt distribution keeps density toward the centre, not the rim
        final dist = n.radius * 0.7 * math.sqrt(random.nextDouble());
        final a = random.range(0, 2 * math.pi);
        final pos = n.pos + Offset(math.cos(a) * dist, math.sin(a) * dist * 0.92);

        // Leaves nearer the top-left catch the light -> brighter palette index.
        final litness = (-(math.sin(a)) - math.cos(a)) * 0.5 + 0.5; // 0..1
        final idx = litness > 0.62
            ? _leafColors.length - 1
            : (1 + random.range(0, (_leafColors.length - 1).toDouble())).floor()
                .clamp(0, _leafColors.length - 1);

        final leafSize = n.radius * random.range(0.16, 0.26);
        _drawOrganicLeaf(canvas, pos, leafSize, random.range(0, 2 * math.pi), _leafColors[idx]);
      }
    }
  }

  /// Draws one soft, irregular foliage clump as a small set of overlapping
  /// circles, giving a bumpy organic silhouette instead of a flat disc.
  void _drawClump(
    Canvas canvas,
    Offset center,
    double radius,
    SeededRandom random,
    Paint paint, {
    double jitter = 0.3,
  }) {
    if (radius < 2) return;
    // central blob
    canvas.drawCircle(center, radius * 0.72, paint);
    // surrounding bumps
    final bumps = 5 + (radius / 14).round().clamp(0, 4);
    for (int i = 0; i < bumps; i++) {
      final a = (i / bumps) * 2 * math.pi + random.range(-0.4, 0.4);
      final d = radius * random.range(0.45, 0.7);
      final bp = center + Offset(math.cos(a) * d, math.sin(a) * d * 0.9);
      canvas.drawCircle(bp, radius * random.range(0.34, 0.5), paint);
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
        ..color = Colors.black.withOpacity(0.10)
        ..strokeWidth = size * 0.08
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(OrganicTreePainter old) =>
      old.days != days || old.skinId != skinId || old.isRecovery != isRecovery;
}
