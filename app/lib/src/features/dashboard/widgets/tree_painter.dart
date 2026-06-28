import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Generative organic tree painter — draws a living tree illustration
/// based on growth [stage] and [skinId] using layered painting techniques.
/// Uses handcrafted canopy blob positions for natural, non-algorithmic shapes.
class OrganicTreePainter extends CustomPainter {
  final String stage;
  final String skinId;
  final bool isRecovery;

  const OrganicTreePainter({
    required this.stage,
    required this.skinId,
    this.isRecovery = false,
  });

  // ─── Colour palette ─────────────────────────────────────────────────────────

  Color get _trunkBase {
    if (isRecovery) return const Color(0xFF9E8B7D);
    return const Color(0xFF8B6B4F);
  }

  Color get _trunkDark {
    if (isRecovery) return const Color(0xFF7A6458);
    return const Color(0xFF5D4037);
  }

  Color get _trunkHighlight {
    if (isRecovery) return const Color(0xFFB0A090);
    return const Color(0xFFBFA07A);
  }

  Color get _foliageDark {
    if (isRecovery) return const Color(0xFF4A7F95);
    return switch (skinId) {
      'Sakura' => const Color(0xFFAD1457),
      'Maple'  => const Color(0xFFBF360C),
      'Bonsai' => const Color(0xFF1B5E20),
      _        => const Color(0xFF1B5E20),
    };
  }

  Color get _foliageMid {
    if (isRecovery) return const Color(0xFF5A9FB0);
    return switch (skinId) {
      'Sakura' => const Color(0xFFE91E63),
      'Maple'  => const Color(0xFFE65100),
      'Bonsai' => const Color(0xFF2E7D32),
      _        => const Color(0xFF2E7D32),
    };
  }

  Color get _foliageLight {
    if (isRecovery) return const Color(0xFF81C9D4);
    return switch (skinId) {
      'Sakura' => const Color(0xFFF48FB1),
      'Maple'  => const Color(0xFFFF9800),
      'Bonsai' => const Color(0xFF66BB6A),
      _        => const Color(0xFF66BB6A),
    };
  }

  Color get _foliageBright {
    if (isRecovery) return const Color(0xFFA0DBE5);
    return switch (skinId) {
      'Sakura' => const Color(0xFFF8BBD0),
      'Maple'  => const Color(0xFFFFCC80),
      'Bonsai' => const Color(0xFFA5D6A7),
      _        => const Color(0xFFA5D6A7),
    };
  }

  // ─── Paint dispatch ─────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    switch (stage) {
      case 'seed':
        _paintSeed(canvas, size);
      case 'sprout':
        _paintSprout(canvas, size);
      case 'sapling':
        _paintSapling(canvas, size);
      case 'blooming':
        _paintBlooming(canvas, size);
      default: // mature + recovery
        _paintMature(canvas, size);
    }
  }

  // ─── SEED ───────────────────────────────────────────────────────────────────

  void _paintSeed(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;
    final r = size.width * 0.055;

    // Soil mound (rounded bump)
    final moundPath = Path()
      ..moveTo(cx - r * 4, gy + r * 0.5)
      ..quadraticBezierTo(cx, gy - r * 1.8, cx + r * 4, gy + r * 0.5)
      ..close();
    canvas.drawPath(moundPath, Paint()..color = const Color(0xFF6D4C41));
    // Mound highlight
    final hlMound = Path()
      ..moveTo(cx - r * 3, gy + r * 0.3)
      ..quadraticBezierTo(cx, gy - r * 1.3, cx + r * 3, gy + r * 0.3)
      ..close();
    canvas.drawPath(hlMound, Paint()..color = const Color(0xFF8D6E63));

    // Seed body (acorn shape)
    final seedBody = Paint()..color = const Color(0xFF795548);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, gy - r * 1.0),
        width: r * 2.4,
        height: r * 3.0,
      ),
      seedBody,
    );

    // Seed cap (top half)
    final capPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, gy - r * 1.8),
        width: r * 2.8,
        height: r * 1.8,
      ),
      math.pi, math.pi, true, capPaint,
    );

    // Cap texture lines
    final capLine = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(
        Offset(cx + i * r * 0.4, gy - r * 2.4),
        Offset(cx + i * r * 0.35, gy - r * 1.6),
        capLine,
      );
    }

    // Seed highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.4, gy - r * 1.2),
        width: r * 0.7,
        height: r * 1.0,
      ),
      Paint()..color = Colors.white.withOpacity(0.12),
    );

    // Tiny sprout emerging from top
    final sproutPaint = Paint()
      ..color = const Color(0xFF7CB342)
      ..strokeWidth = r * 0.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final sproutPath = Path()
      ..moveTo(cx, gy - r * 2.5)
      ..quadraticBezierTo(cx + r * 0.3, gy - r * 3.2, cx - r * 0.1, gy - r * 3.5);
    canvas.drawPath(sproutPath, sproutPaint);
  }

  // ─── SPROUT ─────────────────────────────────────────────────────────────────

  void _paintSprout(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;
    final stemH = size.height * 0.22;
    final stemW = size.width * 0.012;

    // Tiny soil bump at base
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, gy + 2), width: stemW * 10, height: stemW * 3),
      Paint()..color = const Color(0xFF8D6E63),
    );

    // Stem (slightly curved green line)
    final stemPaint = Paint()
      ..color = const Color(0xFF689F38)
      ..strokeWidth = stemW * 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stemPath = Path()
      ..moveTo(cx, gy)
      ..cubicTo(cx - stemW * 2, gy - stemH * 0.4,
                cx + stemW * 2, gy - stemH * 0.7,
                cx, gy - stemH);
    canvas.drawPath(stemPath, stemPaint);

    // Leaf right
    _drawLeaf(canvas, cx + stemW, gy - stemH * 0.65,
        size.width * 0.10, size.width * 0.045, 0.4);
    // Leaf left
    _drawLeaf(canvas, cx - stemW, gy - stemH * 0.45,
        size.width * 0.08, size.width * 0.035, math.pi - 0.5);

    // Top leaves (small cluster)
    _drawLeaf(canvas, cx, gy - stemH,
        size.width * 0.09, size.width * 0.04, -0.2);
    _drawLeaf(canvas, cx, gy - stemH,
        size.width * 0.085, size.width * 0.038, math.pi + 0.3);

    // Tiny bud at very top
    canvas.drawCircle(
      Offset(cx, gy - stemH - size.width * 0.02),
      size.width * 0.015,
      Paint()..color = _foliageBright,
    );
  }

  void _drawLeaf(Canvas canvas, double x, double y,
      double length, double width, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-angle);

    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.4, -width, length, 0)
      ..quadraticBezierTo(length * 0.4, width, 0, 0);

    canvas.drawPath(leafPath, Paint()..color = _foliageMid);
    // Light half
    final lightPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * 0.4, -width * 0.9, length, 0)
      ..lineTo(0, 0);
    canvas.drawPath(lightPath, Paint()..color = _foliageLight.withOpacity(0.5));
    // Vein
    canvas.drawLine(
      const Offset(2, 0), Offset(length * 0.85, 0),
      Paint()
        ..color = _foliageDark.withOpacity(0.35)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  // ─── SAPLING ────────────────────────────────────────────────────────────────

  void _paintSapling(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;
    final trunkH = size.height * 0.32;
    final trunkW = size.width * 0.05;
    final canopyR = size.width * 0.20;
    final canopyCY = gy - trunkH + canopyR * 0.15;

    // Trunk
    _drawTrunk(canvas, cx, gy, trunkH, trunkW);

    // Small branches
    _drawBranch(canvas, cx, gy - trunkH * 0.50, trunkH * 0.16,
        math.pi / 4, trunkW * 0.50);
    _drawBranch(canvas, cx, gy - trunkH * 0.50, trunkH * 0.14,
        math.pi - math.pi / 4, trunkW * 0.50);

    // Modest canopy
    _drawCanopy(canvas, cx, canopyCY, canopyR, complexity: 1);
  }

  // ─── BLOOMING ───────────────────────────────────────────────────────────────

  void _paintBlooming(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;
    final trunkH = size.height * 0.38;
    final trunkW = size.width * 0.065;
    final canopyR = size.width * 0.30;
    final canopyCY = gy - trunkH + canopyR * 0.18;

    _drawTrunk(canvas, cx, gy, trunkH, trunkW);

    // Branches
    _drawBranch(canvas, cx, gy - trunkH * 0.45, trunkH * 0.22,
        math.pi / 4, trunkW * 0.55);
    _drawBranch(canvas, cx, gy - trunkH * 0.45, trunkH * 0.20,
        math.pi - math.pi / 4, trunkW * 0.55);
    _drawBranch(canvas, cx, gy - trunkH * 0.65, trunkH * 0.16,
        math.pi / 3.5, trunkW * 0.40);
    _drawBranch(canvas, cx, gy - trunkH * 0.65, trunkH * 0.14,
        math.pi - math.pi / 3.5, trunkW * 0.40);

    // Fuller canopy
    _drawCanopy(canvas, cx, canopyCY, canopyR, complexity: 2);
  }

  // ─── MATURE ─────────────────────────────────────────────────────────────────

  void _paintMature(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final gy = size.height * 0.90;
    final trunkH = size.height * 0.44;
    final trunkW = size.width * 0.09;
    final canopyR = size.width * 0.40;
    final canopyCY = gy - trunkH + canopyR * 0.22;

    // Root flare (drawn first, behind trunk)
    _drawRootFlare(canvas, cx, gy, trunkW);

    // Trunk
    _drawTrunk(canvas, cx, gy, trunkH, trunkW);

    // Major branches (drawn before canopy so canopy covers upper parts)
    _drawBranch(canvas, cx, gy - trunkH * 0.38, trunkH * 0.28,
        math.pi / 3.8, trunkW * 0.55);
    _drawBranch(canvas, cx, gy - trunkH * 0.38, trunkH * 0.26,
        math.pi - math.pi / 3.8, trunkW * 0.55);
    _drawBranch(canvas, cx, gy - trunkH * 0.58, trunkH * 0.20,
        math.pi / 3.2, trunkW * 0.40);
    _drawBranch(canvas, cx, gy - trunkH * 0.58, trunkH * 0.18,
        math.pi - math.pi / 3.2, trunkW * 0.40);
    _drawBranch(canvas, cx, gy - trunkH * 0.75, trunkH * 0.14,
        math.pi / 3, trunkW * 0.30);

    // Grand canopy
    _drawCanopy(canvas, cx, canopyCY, canopyR, complexity: 3);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Drawing helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Draws a tapered trunk with bark-like gradient and texture lines.
  void _drawTrunk(Canvas canvas, double cx, double gy, double h, double w) {
    final topW = w * 0.50; // trunk narrows at top

    final path = Path()
      ..moveTo(cx - w / 2, gy) // base left
      ..cubicTo(
        cx - w * 0.46, gy - h * 0.35,
        cx - topW * 0.6, gy - h * 0.70,
        cx - topW / 2,  gy - h,
      )
      ..lineTo(cx + topW / 2, gy - h) // top right
      ..cubicTo(
        cx + topW * 0.6, gy - h * 0.70,
        cx + w * 0.46,   gy - h * 0.35,
        cx + w / 2,      gy,
      )
      ..close();

    // 3-stop gradient for rounded trunk shading
    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_trunkDark, _trunkHighlight, _trunkBase, _trunkDark],
        stops: const [0.0, 0.30, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(cx - w / 2, gy - h, w, h));

    canvas.drawPath(path, trunkPaint);

    // Bark texture — alternating horizontal lines
    final barkPaint = Paint()
      ..color = _trunkDark.withOpacity(0.22)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 7; i++) {
      final y = gy - h * (i / 8.5);
      final xShift = (i.isEven ? -1 : 1) * w * 0.04;
      // Interpolate width from base (wider) to top (narrower)
      final t = i / 8.5;
      final halfW = w / 2 * (1.0 - t) + topW / 2 * t;
      canvas.drawLine(
        Offset(cx - halfW * 0.6 + xShift, y),
        Offset(cx + halfW * 0.4 + xShift, y - h * 0.015),
        barkPaint,
      );
    }

    // Subtle knot (hole) on larger trunks
    if (w > 10) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + w * 0.08, gy - h * 0.30),
          width: w * 0.18,
          height: w * 0.12,
        ),
        Paint()..color = _trunkDark.withOpacity(0.30),
      );
    }
  }

  /// Draws visible surface root flare at the trunk base.
  void _drawRootFlare(Canvas canvas, double cx, double gy, double trunkW) {
    final paint = Paint()..color = _trunkDark.withOpacity(0.55);

    // Left root
    final left = Path()
      ..moveTo(cx - trunkW * 0.45, gy)
      ..quadraticBezierTo(
        cx - trunkW * 1.6, gy - trunkW * 0.25,
        cx - trunkW * 2.2, gy + trunkW * 0.12,
      )
      ..quadraticBezierTo(
        cx - trunkW * 1.4, gy + trunkW * 0.20,
        cx - trunkW * 0.35, gy + trunkW * 0.05,
      )
      ..close();
    canvas.drawPath(left, paint);

    // Right root
    final right = Path()
      ..moveTo(cx + trunkW * 0.45, gy)
      ..quadraticBezierTo(
        cx + trunkW * 1.4, gy - trunkW * 0.18,
        cx + trunkW * 1.9, gy + trunkW * 0.15,
      )
      ..quadraticBezierTo(
        cx + trunkW * 1.1, gy + trunkW * 0.20,
        cx + trunkW * 0.35, gy + trunkW * 0.05,
      )
      ..close();
    canvas.drawPath(right, paint);

    // Small center root
    final center = Path()
      ..moveTo(cx + trunkW * 0.15, gy)
      ..quadraticBezierTo(
        cx + trunkW * 0.7, gy - trunkW * 0.08,
        cx + trunkW * 1.0, gy + trunkW * 0.18,
      )
      ..quadraticBezierTo(
        cx + trunkW * 0.5, gy + trunkW * 0.15,
        cx + trunkW * 0.10, gy + trunkW * 0.03,
      )
      ..close();
    canvas.drawPath(center, paint);
  }

  /// Draws a curved branch extending from the trunk.
  void _drawBranch(Canvas canvas, double cx, double baseY, double length,
      double angle, double width) {
    final endX = cx + math.cos(angle) * length;
    final endY = baseY - math.sin(angle) * length;
    final paint = Paint()
      ..color = _trunkBase
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(cx, baseY)
      ..quadraticBezierTo(
        cx + math.cos(angle) * length * 0.55,
        baseY - math.sin(angle) * length * 0.55 - length * 0.05,
        endX,
        endY,
      );
    canvas.drawPath(path, paint);
  }

  /// Draws the tree canopy using multiple layers of overlapping blobs.
  /// [complexity] controls density: 1=sparse (sapling), 2=medium, 3=full.
  void _drawCanopy(Canvas canvas, double cx, double cy, double r,
      {required int complexity}) {
    // ── Drop shadow ──
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 3, cy + r * 0.55),
        width: r * 2.0,
        height: r * 0.5,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // ── Layer 1: Dark back blobs (shadows / depth) ──
    final darkP = Paint()..color = _foliageDark;
    // Handcrafted positions: (dx, dy, blobRadius) — normalized to canopyR
    const darkBlobs = [
      (-0.35, 0.15, 0.50),
      ( 0.38, 0.10, 0.48),
      ( 0.00,-0.05, 0.52),
      (-0.45,-0.12, 0.38),
      ( 0.42,-0.18, 0.36),
    ];
    for (final b in darkBlobs) {
      canvas.drawCircle(Offset(cx + b.$1 * r, cy + b.$2 * r), b.$3 * r, darkP);
    }

    // ── Layer 2: Mid-tone blobs ──
    final midP = Paint()..color = _foliageMid;
    const midBlobs = [
      (-0.18, 0.08, 0.48),
      ( 0.22, 0.02, 0.46),
      ( 0.00,-0.15, 0.44),
      (-0.35,-0.08, 0.38),
      ( 0.35,-0.12, 0.36),
      (-0.10, 0.20, 0.34),
      ( 0.15, 0.18, 0.32),
    ];
    for (final b in midBlobs) {
      canvas.drawCircle(Offset(cx + b.$1 * r, cy + b.$2 * r), b.$3 * r, midP);
    }

    // ── Layer 3: Light highlight blobs (upper portion) ──
    final lightP = Paint()..color = _foliageLight;
    const lightBlobs = [
      (-0.12,-0.18, 0.42),
      ( 0.15,-0.25, 0.36),
      (-0.30,-0.15, 0.32),
      ( 0.05,-0.08, 0.38),
    ];
    for (final b in lightBlobs) {
      canvas.drawCircle(Offset(cx + b.$1 * r, cy + b.$2 * r), b.$3 * r, lightP);
    }

    // ── Layer 4: Bright accent highlights (for complexity ≥ 2) ──
    if (complexity >= 2) {
      final brightP = Paint()..color = _foliageBright;
      canvas.drawCircle(Offset(cx - r * 0.08, cy - r * 0.30), r * 0.28, brightP);
      canvas.drawCircle(Offset(cx + r * 0.18, cy - r * 0.34), r * 0.22, brightP);
      canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.22), r * 0.20, brightP);
    }

    // ── Extra density for complexity 3 (mature) ──
    if (complexity >= 3) {
      // Additional mid blobs for fullness
      canvas.drawCircle(
        Offset(cx - r * 0.48, cy + r * 0.02), r * 0.30,
        Paint()..color = _foliageMid,
      );
      canvas.drawCircle(
        Offset(cx + r * 0.50, cy - r * 0.02), r * 0.28,
        Paint()..color = _foliageMid,
      );
      // Top highlight crown
      canvas.drawCircle(
        Offset(cx, cy - r * 0.38), r * 0.24,
        Paint()..color = _foliageBright.withOpacity(0.7),
      );
      // Bottom edge detail
      canvas.drawCircle(
        Offset(cx - r * 0.22, cy + r * 0.28), r * 0.26,
        Paint()..color = _foliageDark.withOpacity(0.5),
      );
      canvas.drawCircle(
        Offset(cx + r * 0.20, cy + r * 0.26), r * 0.24,
        Paint()..color = _foliageDark.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(OrganicTreePainter old) =>
      old.stage != stage || old.skinId != skinId || old.isRecovery != isRecovery;
}
