import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'growth_map_node.dart';

class GrowthMapLayout {
  static List<GrowthMapNode> calculate({
    required double width,
    required double height,
    required RootNode root,
    required List<BranchNode> branches,
    required List<LeafNode> leaves,
    required List<FlowerNode> flowers,
    required List<FruitNode> fruits,
    String? selectedDomain,
  }) {
    final List<GrowthMapNode> positionedNodes = [];

    // 1. Position Root Node
    final closeUpRootYOffset = selectedDomain != null ? height * 0.42 : height * 0.52;
    final rootPos = Offset(width / 2, closeUpRootYOffset);
    final positionedRoot = root.copyWith(position: rootPos);
    positionedNodes.add(positionedRoot);

    // Group sub-nodes by domain tag
    final Map<String, List<GrowthMapNode>> subNodesByDomain = {};
    for (final leaf in leaves) {
      subNodesByDomain.putIfAbsent(leaf.domainTag, () => []).add(leaf);
    }
    for (final flower in flowers) {
      subNodesByDomain.putIfAbsent(flower.domainTag, () => []).add(flower);
    }
    for (final fruit in fruits) {
      subNodesByDomain.putIfAbsent(fruit.domainTag, () => []).add(fruit);
    }

    final domainOrder = ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
    final Map<String, Offset> branchPositions = {};

    if (selectedDomain != null && branches.isNotEmpty) {
      // Single-domain close-up layout
      final branch = branches.first;
      final branchAngles = {
        'Tubuh': math.pi * 270 / 180,
        'Keuangan': math.pi * 330 / 180,
        'Hubungan': math.pi * 30 / 180,
        'Emosi': math.pi * 90 / 180,
        'Karir': math.pi * 150 / 180,
        'Rekreasi': math.pi * 210 / 180,
      };
      final angle = branchAngles[selectedDomain] ?? math.pi * 270 / 180;
      final branchGap = math.min(width * 0.22, height * 0.26);
      final branchPos = Offset(
        (rootPos.dx + math.cos(angle) * branchGap).clamp(24.0, width - 24.0),
        (rootPos.dy - math.sin(angle) * branchGap).clamp(24.0, height - 24.0),
      );
      branchPositions[branch.id] = branchPos;
      positionedNodes.add(branch.copyWith(position: branchPos));

      final subNodes = subNodesByDomain[branch.id] ?? [];
      final k = subNodes.length;
      for (int j = 0; j < k; j++) {
        final node = subNodes[j];
        final double sectorCenter = angle;
        final double arcWidth = math.pi * 90 / 180;
        final double arcStart = sectorCenter - (arcWidth / 2);
        final double subAngle = k == 1
            ? sectorCenter
            : arcStart + (arcWidth / (k - 1)) * j;
        final subRadiusBase = math.min(width * 0.18, height * 0.20);
        final subRadius = subRadiusBase + (j * 16.0);

        final subX = (branchPos.dx + math.cos(subAngle) * subRadius).clamp(20.0, width - 20.0);
        final subY = (branchPos.dy - math.sin(subAngle) * subRadius).clamp(20.0, height - 20.0);

        positionedNodes.add(node.copyWith(position: Offset(subX, subY)));
      }

      return positionedNodes;
    }

    // 2. Position Branches (6 Domains)
    final branchAngles = [
      math.pi * 270 / 180,
      math.pi * 330 / 180,
      math.pi * 30 / 180,
      math.pi * 90 / 180,
      math.pi * 150 / 180,
      math.pi * 210 / 180,
    ];

    final branchRadius = math.min(width * 0.30, height * 0.32);

    for (int i = 0; i < domainOrder.length; i++) {
      final domain = domainOrder[i];
      final bIndex = branches.indexWhere((b) => b.id == domain);
      if (bIndex == -1) continue;

      final branch = branches[bIndex];
      final angle = branchAngles[i % branchAngles.length];
      final radius = branchRadius;

      final x = (rootPos.dx + math.cos(angle) * radius).clamp(24.0, width - 24.0);
      final y = (rootPos.dy - math.sin(angle) * radius).clamp(24.0, height - 24.0);

      final branchPos = Offset(x, y);
      branchPositions[domain] = branchPos;

      positionedNodes.add(branch.copyWith(position: branchPos));

      final subNodes = subNodesByDomain[domain] ?? [];
      final k = subNodes.length;

      for (int j = 0; j < k; j++) {
        final node = subNodes[j];
        final spread = k <= 1 ? 0.0 : (j - (k - 1) / 2) * 0.22;
        final subAngle = angle + spread;
        final subRadius = 34.0 + (k > 1 ? 10.0 : 0.0) + (j * 6.0);

        final subX = (branchPos.dx + math.cos(subAngle) * subRadius).clamp(20.0, width - 20.0);
        final subY = (branchPos.dy - math.sin(subAngle) * subRadius).clamp(20.0, height - 20.0);

        positionedNodes.add(node.copyWith(position: Offset(subX, subY)));
      }
    }

    return positionedNodes;
  }
}
