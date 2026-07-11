import 'package:flutter/material.dart';

enum NodeType { root, branch, leaf, flower, fruit }

abstract class GrowthMapNode {
  final String id;
  final String label;
  final NodeType type;
  final IconData? icon;
  final Offset position;
  final String semanticLabel;

  const GrowthMapNode({
    required this.id,
    required this.label,
    required this.type,
    this.icon,
    this.position = Offset.zero,
    required this.semanticLabel,
  });

  GrowthMapNode copyWith({Offset? position});
}

class RootNode extends GrowthMapNode {
  final List<String> coreValues;

  const RootNode({
    required super.id,
    required super.label,
    super.icon = Icons.spa_outlined,
    super.position,
    required super.semanticLabel,
    required this.coreValues,
  }) : super(type: NodeType.root);

  @override
  RootNode copyWith({Offset? position}) {
    return RootNode(
      id: id,
      label: label,
      icon: icon,
      position: position ?? this.position,
      semanticLabel: semanticLabel,
      coreValues: coreValues,
    );
  }
}

class BranchNode extends GrowthMapNode {
  final double score; // 1 to 10
  final String statusLabel; // Needs Attention, Neutral, Healthy
  final Color color;
  final bool isLocked;

  const BranchNode({
    required super.id,
    required super.label,
    required super.icon,
    super.position,
    required super.semanticLabel,
    required this.score,
    required this.statusLabel,
    required this.color,
    this.isLocked = false,
  }) : super(type: NodeType.branch);

  @override
  BranchNode copyWith({Offset? position}) {
    return BranchNode(
      id: id,
      label: label,
      icon: icon,
      position: position ?? this.position,
      semanticLabel: semanticLabel,
      score: score,
      statusLabel: statusLabel,
      color: color,
      isLocked: isLocked,
    );
  }
}

class LeafNode extends GrowthMapNode {
  final String domainTag;
  final bool isDone;
  final String initial;
  final dynamic originalHabit; // reference to toggle status
  final dynamic originalLog;

  const LeafNode({
    required super.id,
    required super.label,
    super.position,
    required super.semanticLabel,
    required this.domainTag,
    required this.isDone,
    required this.initial,
    required this.originalHabit,
    this.originalLog,
  }) : super(type: NodeType.leaf);

  @override
  LeafNode copyWith({Offset? position}) {
    return LeafNode(
      id: id,
      label: label,
      position: position ?? this.position,
      semanticLabel: semanticLabel,
      domainTag: domainTag,
      isDone: isDone,
      initial: initial,
      originalHabit: originalHabit,
      originalLog: originalLog,
    );
  }
}

class FlowerNode extends GrowthMapNode {
  final String domainTag;
  final int streakDays;

  const FlowerNode({
    required super.id,
    required super.label,
    super.icon = Icons.emoji_emotions_outlined,
    super.position,
    required super.semanticLabel,
    required this.domainTag,
    required this.streakDays,
  }) : super(type: NodeType.flower);

  @override
  FlowerNode copyWith({Offset? position}) {
    return FlowerNode(
      id: id,
      label: label,
      icon: icon,
      position: position ?? this.position,
      semanticLabel: semanticLabel,
      domainTag: domainTag,
      streakDays: streakDays,
    );
  }
}

class FruitNode extends GrowthMapNode {
  final String domainTag;
  final dynamic originalDecision; // reference to open details

  const FruitNode({
    required super.id,
    required super.label,
    super.icon = Icons.workspace_premium_outlined, // Material icon name only; not app billing
    super.position,
    required super.semanticLabel,
    required this.domainTag,
    required this.originalDecision,
  }) : super(type: NodeType.fruit);

  @override
  FruitNode copyWith({Offset? position}) {
    return FruitNode(
      id: id,
      label: label,
      icon: icon,
      position: position ?? this.position,
      semanticLabel: semanticLabel,
      domainTag: domainTag,
      originalDecision: originalDecision,
    );
  }
}
