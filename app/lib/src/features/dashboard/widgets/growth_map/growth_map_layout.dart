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
    final closeUpRootYOffset = selectedDomain != null
        ? height * 0.42
        : height * 0.52;
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

    final domainOrder = [
      'Tubuh',
      'Keuangan',
      'Hubungan',
      'Emosi',
      'Karir',
      'Rekreasi',
    ];
    final Map<String, Offset> branchPositions = {};

    if (selectedDomain != null && branches.isNotEmpty) {
      // Single-domain close-up layout.
      // Use a stable vertical composition: selected domain in focus, quick-add
      // nodes around it, and the root partially visible at the bottom.
      final branch = branches.first;
      final focusedRootPos = Offset(
        width / 2,
        // Put the root center near the bottom edge so only its upper half is
        // visible in the clipped tree canvas.
        height * 0.96,
      );
      positionedNodes[0] = positionedRoot.copyWith(position: focusedRootPos);

      final branchPos = Offset(
        width / 2,
        // Selected domain focus position in the close-up view.
        height * 0.60,
      );
      branchPositions[branch.id] = branchPos;
      positionedNodes.add(branch.copyWith(position: branchPos));

      // Add fixed quick-add “+” nodes around the selected domain icon.
      const double addIconOffset = 62.0;
      final addIconPositions = [
        Offset(branchPos.dx, branchPos.dy - addIconOffset),
        Offset(branchPos.dx - addIconOffset * 1.2, branchPos.dy),
        Offset(branchPos.dx + addIconOffset * 1.2, branchPos.dy),
      ];
      for (var index = 0; index < addIconPositions.length; index++) {
        final position = addIconPositions[index];
        final positionLabel = index == 0
            ? 'atas'
            : index == 1
            ? 'kiri'
            : 'kanan';
        positionedNodes.add(
          LeafNode(
            id: 'selected-add-$positionLabel-$selectedDomain',
            label: 'Tambah Kebiasaan',
            position: position,
            semanticLabel:
                'Tambah kebiasaan baru untuk domain $selectedDomain di $positionLabel.',
            domainTag: selectedDomain,
            isDone: false,
            initial: '+',
            originalHabit: null,
          ),
        );
      }

      final subNodes = subNodesByDomain[branch.id] ?? [];
      final k = subNodes.length;
      const double horizontalGap = 38.0;
      const int maxNodesPerRow = 5;
      for (int j = 0; j < k; j++) {
        final node = subNodes[j];
        final row = j ~/ maxNodesPerRow;
        final indexInRow = j % maxNodesPerRow;
        final nodesInThisRow = math.min(
          maxNodesPerRow,
          k - row * maxNodesPerRow,
        );
        final xOffset = (indexInRow - (nodesInThisRow - 1) / 2) * horizontalGap;

        final nodeX = (branchPos.dx + xOffset).clamp(22.0, width - 22.0);
        final isPlaceholderLeaf =
            node is LeafNode && node.originalHabit == null;
        final rawNodeY = isPlaceholderLeaf
            ? branchPos.dy - 60.0 - row * 28.0
            : branchPos.dy + 42.0 + row * 28.0;
        final nodeY = rawNodeY.clamp(22.0, height - 22.0);

        positionedNodes.add(node.copyWith(position: Offset(nodeX, nodeY)));
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

      final x = (rootPos.dx + math.cos(angle) * radius).clamp(
        24.0,
        width - 24.0,
      );
      final y = (rootPos.dy - math.sin(angle) * radius).clamp(
        24.0,
        height - 24.0,
      );

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

        final subX = (branchPos.dx + math.cos(subAngle) * subRadius).clamp(
          20.0,
          width - 20.0,
        );
        final subY = (branchPos.dy - math.sin(subAngle) * subRadius).clamp(
          20.0,
          height - 20.0,
        );

        positionedNodes.add(node.copyWith(position: Offset(subX, subY)));
      }
    }

    return positionedNodes;
  }
}
