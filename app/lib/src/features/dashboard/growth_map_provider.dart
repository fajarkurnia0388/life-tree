import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/providers/db_provider.dart';
import '../../core/domain/app_constants.dart';
import 'dashboard_provider.dart';
import 'widgets/growth_map/growth_map_node.dart';

class GrowthMapViewModel {
  final RootNode root;
  final List<BranchNode> branches;
  final List<LeafNode> leaves;
  final List<FlowerNode> flowers;
  final List<FruitNode> fruits;
  final int cumulativeDays;
  final String season;
  final String skinId;

  GrowthMapViewModel({
    required this.root,
    required this.branches,
    required this.leaves,
    required this.flowers,
    required this.fruits,
    required this.cumulativeDays,
    required this.season,
    required this.skinId,
  });
}

IconData _getDomainIcon(String domain) {
  return switch (domain) {
    'Tubuh' => Icons.directions_run_rounded,
    'Keuangan' => Icons.account_balance_wallet_rounded,
    'Hubungan' => Icons.people_rounded,
    'Emosi' => Icons.self_improvement_rounded,
    'Karir' => Icons.work_rounded,
    'Rekreasi' => Icons.local_play_rounded,
    _ => Icons.spa_outlined,
  };
}

final growthMapProvider = FutureProvider<GrowthMapViewModel>((ref) async {
  final dashboardData = await ref.watch(dashboardDataProvider.future);

  // 1. Parse Core Values (Declared)
  List<String> coreValues = [];
  if (dashboardData.profile.coreValues != null) {
    try {
      final List<dynamic> raw = jsonDecode(dashboardData.profile.coreValues!);
      coreValues = raw.map((v) => v.toString()).toList();
    } catch (_) {}
  }

  // 2. Parse Domain Scores (latestDomainScores)
  Map<String, double> domainScores = {};
  if (dashboardData.profile.latestDomainScores != null) {
    try {
      final Map<String, dynamic> raw = jsonDecode(dashboardData.profile.latestDomainScores!);
      raw.forEach((k, v) => domainScores[k] = (v as num).toDouble());
    } catch (_) {}
  }

  final domains = ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
  final domainColors = {
    'Tubuh': Colors.green,
    'Keuangan': Colors.orange,
    'Hubungan': Colors.blue,
    'Emosi': Colors.teal,
    'Karir': Colors.indigo,
    'Rekreasi': Colors.purple,
  };

  // Convert to BranchNode
  final List<BranchNode> branchNodes = [];
  for (final domain in domains) {
    final score = domainScores[domain] ?? 5.0; // default to 5.0 (neutral)
    final String statusLabel;
    if (score >= 8.0) {
      statusLabel = 'Stabil';
    } else if (score >= 5.0) {
      statusLabel = 'Netral';
    } else {
      statusLabel = 'Butuh perhatian';
    }

    branchNodes.add(
      BranchNode(
        id: domain,
        label: domain,
        icon: _getDomainIcon(domain),
        score: score,
        statusLabel: statusLabel,
        color: domainColors[domain] ?? Colors.green,
        semanticLabel: '', // Set in widget
      ),
    );
  }

  // 3. Convert habitsToday to LeafNode
  final List<LeafNode> leafNodes = [];
  final List<FlowerNode> flowerNodes = [];

  for (final hl in dashboardData.habitsToday) {
    final isDone = hl.log?.status == HabitStatus.done;
    final initial = hl.habit.title.substring(0, math.min(2, hl.habit.title.length)).toUpperCase();

    leafNodes.add(
      LeafNode(
        id: hl.habit.habitId,
        label: hl.habit.title,
        domainTag: hl.habit.domainTag ?? 'Emosi',
        isDone: isDone,
        initial: initial,
        originalHabit: hl.habit,
        originalLog: hl.log,
        semanticLabel: '',
      ),
    );
  }

  // 4. Convert Decisions (last 7 days, important) to FruitNode
  final db = ref.watch(dbProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  List<FruitNode> fruitNodes = [];

  try {
    final decisions = await (db.select(db.decisionEntries)
          ..where((tbl) =>
              tbl.userId.equals(dashboardData.profile.userId) &
              tbl.decisionDate.isBiggerOrEqualValue(sevenDaysAgo) &
              tbl.deletedAt.isNull()))
        .get();

    fruitNodes = decisions.map((d) {
      return FruitNode(
        id: d.decisionId,
        label: d.title,
        domainTag: 'Emosi', // Map to default domain for visual layout
        originalDecision: d,
        semanticLabel: '',
      );
    }).toList();
  } catch (_) {}

  return GrowthMapViewModel(
    root: RootNode(
      id: 'root',
      label: 'Akar Diri',
      semanticLabel: '',
      coreValues: coreValues,
    ),
    branches: branchNodes,
    leaves: leafNodes,
    flowers: flowerNodes,
    fruits: fruitNodes,
    cumulativeDays: dashboardData.cumulativeDays,
    season: dashboardData.season,
    skinId: dashboardData.profile.selectedSkin,
  );
});
