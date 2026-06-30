import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'growth_map_node.dart';

class GrowthMapPainter extends CustomPainter {
  final List<GrowthMapNode> nodes;
  final String season;

  GrowthMapPainter({
    required this.nodes,
    required this.season,
  });

  Color get _connectorColor => const Color(0xFF81C784).withValues(alpha: 0.5);

  Color get _rootColor => const Color(0xFF8B6B4F);

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
      canvas.drawPath(path, branchPaint);

      // If the domain is healthy (score >= 8), draw an extra glowing aura path
      if (branch.score >= 8.0) {
        final glowPaint = Paint()
          ..color = branch.color.withValues(alpha: 0.35)
          ..strokeWidth = 5.0
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
      final branch = branchNodes.firstWhere((b) => b.id == leaf.domainTag, orElse: () => branchNodes.first);
      final branchPos = branch.position;
      final leafPos = leaf.position;

      // Line color is vibrant if habit is done, else dim
      subBranchPaint.color = leaf.isDone 
          ? branch.color.withValues(alpha: 0.8) 
          : Colors.grey.withValues(alpha: 0.3);
      subBranchPaint.strokeWidth = leaf.isDone ? 2.2 : 1.5;

      canvas.drawLine(branchPos, leafPos, subBranchPaint);

      if (leaf.isDone) {
        // Draw glow aura
        final glowPaint = Paint()
          ..color = branch.color.withValues(alpha: 0.3)
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(branchPos, leafPos, glowPaint);
      }
    }

    // Draw lines to Flowers (Stables)
    for (final flower in flowerNodes) {
      final branch = branchNodes.firstWhere((b) => b.id == flower.domainTag, orElse: () => branchNodes.first);
      final branchPos = branch.position;
      final flowerPos = flower.position;

      subBranchPaint.color = branch.color.withValues(alpha: 0.8);
      subBranchPaint.strokeWidth = 2.0;

      canvas.drawLine(branchPos, flowerPos, subBranchPaint);
    }

    // Draw lines to Fruits (Decisions)
    for (final fruit in fruitNodes) {
      final branch = branchNodes.firstWhere((b) => b.id == fruit.domainTag, orElse: () => branchNodes.first);
      final branchPos = branch.position;
      final fruitPos = fruit.position;

      subBranchPaint.color = branch.color.withValues(alpha: 0.8);
      subBranchPaint.strokeWidth = 2.0;

      canvas.drawLine(branchPos, fruitPos, subBranchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GrowthMapPainter oldDelegate) {
    return oldDelegate.nodes != nodes || oldDelegate.season != season;
  }
}
