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
  }) {
    final List<GrowthMapNode> positionedNodes = [];

    // 1. Position Root Node
    final rootPos = Offset(width / 2, height - 35);
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

    // 2. Position Branches (6 Domains)
    // Order: Tubuh, Keuangan, Hubungan, Emosi, Karir, Rekreasi
    final domainOrder = ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
    final Map<String, Offset> branchPositions = {};

    for (int i = 0; i < domainOrder.length; i++) {
      final domain = domainOrder[i];
      final bIndex = branches.indexWhere((b) => b.id == domain);
      if (bIndex == -1) continue;

      final branch = branches[bIndex];

      // Proportional spacing fanned horizontally
      final x = width * (0.09 + i * 0.164);
      
      // Beautiful fanned arch
      final archFactor = math.sin(math.pi * (i + 0.5) / 6);
      final y = height * 0.52 - (24 * archFactor);

      final branchPos = Offset(x, y);
      branchPositions[domain] = branchPos;
      
      final positionedBranch = branch.copyWith(position: branchPos);
      positionedNodes.add(positionedBranch);

      // 3. Position Leaves, Flowers, Fruits (Sub-nodes branching from this domain)
      final subNodes = subNodesByDomain[domain] ?? [];
      final k = subNodes.length;

      for (int j = 0; j < k; j++) {
        final node = subNodes[j];
        double subX = x;
        double subY = height * 0.20; // fallback y

        if (k == 1) {
          subX = x;
          subY = height * 0.18;
        } else if (k == 2) {
          subX = x + (j == 0 ? -14.0 : 14.0);
          subY = height * 0.18;
        } else {
          // 3 or more (spread in fan canopy)
          if (j == 0) {
            subX = x - 18.0;
            subY = height * 0.20;
          } else if (j == 1) {
            subX = x;
            subY = height * 0.10;
          } else {
            subX = x + 18.0;
            subY = height * 0.20;
          }
        }

        final positionedSub = node.copyWith(position: Offset(subX, subY));
        positionedNodes.add(positionedSub);
      }
    }

    return positionedNodes;
  }
}
