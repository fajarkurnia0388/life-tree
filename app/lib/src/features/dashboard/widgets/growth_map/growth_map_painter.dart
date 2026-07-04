import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'growth_map_node.dart';

class GrowthMapPainter extends CustomPainter {
  final List<GrowthMapNode> nodes;
  final String season;

  GrowthMapPainter({required this.nodes, required this.season});

  /// Season-based visual modifiers for cultivation state visualization.
  _SeasonModifier get _seasonMod {
    return switch (season) {
      'recovery' => const _SeasonModifier(
        alphaMult: 0.7,
        saturationMult: 0.5,
        glowMult: 0.6,
      ),
      'dormant' => const _SeasonModifier(
        alphaMult: 0.5,
        saturationMult: 0.3,
        glowMult: 0.4,
      ),
      'tribulation' => const _SeasonModifier(
        alphaMult: 1.2,
        saturationMult: 1.3,
        glowMult: 1.4,
      ),
      'quietIntegration' => const _SeasonModifier(
        alphaMult: 0.85,
        saturationMult: 0.7,
        glowMult: 0.9,
      ),
      _ => const _SeasonModifier(), // growth = normal
    };
  }

  Color get _connectorColor =>
      _applySeasonMod(const Color(0xFF81C784).withValues(alpha: 0.5));

  Color get _rootColor => _applySeasonMod(const Color(0xFF8B6B4F));

  /// Apply season-based alpha and saturation modifiers to a color.
  Color _applySeasonMod(Color color) {
    final mod = _seasonMod;
    final hsv = HSVColor.fromColor(color);
    return hsv
        .withSaturation((hsv.saturation * mod.saturationMult).clamp(0.0, 1.0))
        .toColor()
        .withValues(alpha: (color.a * mod.alphaMult).clamp(0.0, 1.0));
  }

  /// Draws a soft palace aura around each domain branch.
  ///
  /// Accessibility: the aura is not color-only. Higher resonance uses larger
  /// radius, stronger outer ring, and additional inner ring.
  void _drawPalaceAura(Canvas canvas, BranchNode branch) {
    final normalizedScore = (branch.score / 10.0).clamp(0.0, 1.0);
    final radius = 14.0 + (normalizedScore * 16.0);
    final auraAlpha = (0.08 + (normalizedScore * 0.18)) * _seasonMod.glowMult;

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _applySeasonMod(branch.color.withValues(alpha: auraAlpha)),
          _applySeasonMod(branch.color.withValues(alpha: auraAlpha * 0.45)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: branch.position, radius: radius));

    canvas.drawCircle(branch.position, radius, auraPaint);

    if (branch.score >= 6.0) {
      final ringPaint = Paint()
        ..color = _applySeasonMod(
          branch.color.withValues(alpha: 0.18 * _seasonMod.glowMult),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = branch.score >= 8.0 ? 2.2 : 1.4;
      canvas.drawCircle(branch.position, radius * 0.72, ringPaint);
    }

    if (branch.score >= 8.0) {
      final innerRingPaint = Paint()
        ..color = _applySeasonMod(
          branch.color.withValues(alpha: 0.24 * _seasonMod.glowMult),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(branch.position, radius * 0.42, innerRingPaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Find Root Node
    final rootNodes = nodes.whereType<RootNode>();
    if (rootNodes.isEmpty) return;
    final root = rootNodes.first;
    final rootPos = root.position;

    final branchNodes = nodes.whereType<BranchNode>();
    final leafNodes = nodes.whereType<LeafNode>();
    final flowerNodes = nodes.whereType<FlowerNode>();
    final fruitNodes = nodes.whereType<FruitNode>();

    // ─── Draw Roots (Core Values) ───
    final rootPaint = Paint()
      ..color = _rootColor.withValues(alpha: 0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final declaredValuesCount = root.coreValues.length;
    // Draw 3 primary root lines branching downwards
    for (int i = 0; i < declaredValuesCount; i++) {
      final double angle = 1.0 + (i * 0.55); // spread downwards
      final double length = 24.0;
      final targetX = rootPos.dx + length * math.cos(angle);
      final targetY = rootPos.dy + length * math.sin(angle) * 0.7;

      canvas.drawLine(rootPos, Offset(targetX, targetY), rootPaint);
    }

    // Draw serabut root line if we have revealed values (dummy visual indicator)
    final serabutPaint = Paint()
      ..color = _connectorColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 4; i++) {
      final double angle = 1.3 + (i * 0.35);
      final double length = 18.0;
      final targetX = rootPos.dx + length * math.cos(angle);
      final targetY = rootPos.dy + length * math.sin(angle) * 0.7 + 6.0;

      canvas.drawLine(rootPos, Offset(targetX, targetY), serabutPaint);
    }

    // ─── Draw Palace Auras (Task 2.10) ───
    // Radial aura around branch nodes based on palace score
    // Uses multiple visual cues for accessibility: size, opacity, ring pattern
    for (final branch in branchNodes) {
      if (!branch.isLocked) {
        _drawPalaceAura(canvas, branch);
      }
    }

    // ─── Draw Branches (Root -> Domain) ───
    final branchPaint = Paint()
      ..color = _connectorColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final branch in branchNodes) {
      final branchPos = branch.position;

      // Draw fanning bezier curve from Root to Branch
      final path = Path();
      path.moveTo(rootPos.dx, rootPos.dy);

      // Control point fanning slightly outwards
      final ctrlX = rootPos.dx + (branchPos.dx - rootPos.dx) * 0.25;
      final ctrlY = (rootPos.dy + branchPos.dy) / 2;

      path.quadraticBezierTo(ctrlX, ctrlY, branchPos.dx, branchPos.dy);
      final effectiveBranchPaint = branch.isLocked
          ? (Paint()
              ..color = Colors.grey.withValues(alpha: 0.22)
              ..strokeWidth = 1.6
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round)
          : branchPaint;
      canvas.drawPath(path, effectiveBranchPaint);

      // If the stream is healthy (score >= 8), draw an extra glowing aura path.
      // Locked streams stay visually quiet until unlocked/progressively active.
      if (!branch.isLocked && branch.score >= 8.0) {
        final glowPaint = Paint()
          ..color = _applySeasonMod(
            branch.color.withValues(alpha: 0.35 * _seasonMod.glowMult),
          )
          ..strokeWidth = 5.0 * _seasonMod.glowMult
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, glowPaint);
      }
    }

    // ─── Draw Sub-branches (Domain -> Leaves/Flowers/Fruits) ───
    final subBranchPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw lines to Leaves
    for (final leaf in leafNodes) {
      final branch = branchNodes.firstWhere(
        (b) => b.id == leaf.domainTag,
        orElse: () => branchNodes.first,
      );
      final branchPos = branch.position;
      final leafPos = leaf.position;

      // Line color is vibrant if habit is done, else dim
      subBranchPaint.color = leaf.isDone
          ? _applySeasonMod(branch.color.withValues(alpha: 0.8))
          : _applySeasonMod(Colors.grey.withValues(alpha: 0.3));
      subBranchPaint.strokeWidth = leaf.isDone ? 2.2 : 1.5;

      canvas.drawLine(branchPos, leafPos, subBranchPaint);

      if (leaf.isDone) {
        // Draw glow aura
        final glowPaint = Paint()
          ..color = _applySeasonMod(
            branch.color.withValues(alpha: 0.3 * _seasonMod.glowMult),
          )
          ..strokeWidth = 5.0 * _seasonMod.glowMult
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(branchPos, leafPos, glowPaint);
      }
    }

    // Draw lines to Flowers (Stables)
    for (final flower in flowerNodes) {
      final branch = branchNodes.firstWhere(
        (b) => b.id == flower.domainTag,
        orElse: () => branchNodes.first,
      );
      final branchPos = branch.position;
      final flowerPos = flower.position;

      subBranchPaint.color = _applySeasonMod(
        branch.color.withValues(alpha: 0.8),
      );
      subBranchPaint.strokeWidth = 2.0;

      canvas.drawLine(branchPos, flowerPos, subBranchPaint);
    }

    // Draw lines to Fruits (Decisions)
    for (final fruit in fruitNodes) {
      final branch = branchNodes.firstWhere(
        (b) => b.id == fruit.domainTag,
        orElse: () => branchNodes.first,
      );
      final branchPos = branch.position;
      final fruitPos = fruit.position;

      subBranchPaint.color = _applySeasonMod(
        branch.color.withValues(alpha: 0.8),
      );
      subBranchPaint.strokeWidth = 2.0;

      canvas.drawLine(branchPos, fruitPos, subBranchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GrowthMapPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.season != season;
  }
}

/// Visual modifier values for different cultivation seasons.
class _SeasonModifier {
  final double alphaMult;
  final double saturationMult;
  final double glowMult;

  const _SeasonModifier({
    this.alphaMult = 1.0,
    this.saturationMult = 1.0,
    this.glowMult = 1.0,
  });
}
