import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/domain/app_constants.dart';
import '../../core/services/error_logger_provider.dart';
import '../../core/utils/profile_json_helpers.dart';
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

  GrowthMapViewModel({
    required this.root,
    required this.branches,
    required this.leaves,
    required this.flowers,
    required this.fruits,
    required this.cumulativeDays,
    required this.season,
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
  final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

  // 1. Parse Core Values (Declared)
  final coreValues = dashboardData.profile.parsedCoreValues;

  // 2. Parse Domain Scores (latestDomainScores)
  final domainScores = dashboardData.profile.parsedDomainScores;

  final domains = [
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi',
  ];


  final activeDomains = <String>{'Tubuh'};
  if (dashboardData.profile.isDeveloperMode) {
    activeDomains.addAll(domains);
  } else {
    activeDomains.addAll(domainScores.keys.where(domains.contains));
    for (final hwl in dashboardData.habitsToday) {
      final domain = hwl.habit.domainTag;
      if (domain != null && domains.contains(domain)) {
        activeDomains.add(domain);
      }
    }
  }

  // Convert to BranchNode. Locked branches stay visible as progressive
  // disclosure, but cannot be focused unless Developer Mode is active or the
  // user has created/activated data in that stream.
  final List<BranchNode> branchNodes = [];
  for (final domain in domains) {
    final isLocked = !activeDomains.contains(domain);
    final score = domainScores[domain] ?? 5.0; // default to 5.0 (neutral)
    final String statusLabel;
    if (score >= 8.0) {
      statusLabel = 'Stabil';
    } else if (score >= 5.0) {
      statusLabel = 'Netral';
    } else {
      statusLabel = 'Butuh perhatian';
    }

    final displayDomain = DaojiText.domainLabel(domain, vocabularyLevel);
    branchNodes.add(
      BranchNode(
        id: domain,
        label: DaojiText.domainLabel(domain, vocabularyLevel, short: true),
        icon: _getDomainIcon(domain),
        score: score,
        statusLabel: isLocked ? 'Soon' : statusLabel,
        color: DomainColors.forDomain(domain),
        isLocked: isLocked,
        semanticLabel: isLocked
            ? '$displayDomain — segera dibuka bertahap. Tambahkan practice di stream ini atau aktifkan Developer Mode untuk testing.'
            : '$displayDomain — Skor: ${score.toStringAsFixed(1)}, Status: $statusLabel',
      ),
    );
  }

  // 3. Convert habitsToday to LeafNode
  final List<LeafNode> leafNodes = [];
  final List<FlowerNode> flowerNodes = [];

  for (final hl in dashboardData.habitsToday) {
    final isDone = hl.log?.status == HabitStatus.done;
    final initial = hl.habit.title
        .substring(0, math.min(2, hl.habit.title.length))
        .toUpperCase();

    leafNodes.add(
      LeafNode(
        id: hl.habit.habitId,
        label: hl.habit.title,
        domainTag: hl.habit.domainTag ?? 'Emosi',
        isDone: isDone,
        initial: initial,
        originalHabit: hl.habit,
        originalLog: hl.log,
        semanticLabel:
            'Kebiasaan: ${hl.habit.title}, Status: ${isDone ? 'Selesai' : 'Belum selesai'}',
      ),
    );
  }

  // 4. Convert Decisions (last 7 days, important) to FruitNode
  final db = ref.watch(dbProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
  List<FruitNode> fruitNodes = [];

  try {
    final decisions =
        await (db.select(db.decisionEntries)..where(
              (tbl) =>
                  tbl.userId.equals(dashboardData.profile.userId) &
                  tbl.decisionDate.isBiggerOrEqualValue(sevenDaysAgo) &
                  tbl.deletedAt.isNull(),
            ))
            .get();

    fruitNodes = decisions.map((d) {
      return FruitNode(
        id: d.decisionId,
        label: d.title,
        domainTag: 'Emosi', // Map to default domain for visual layout
        originalDecision: d,
        semanticLabel: 'Keputusan: ${d.title}',
      );
    }).toList();
  } catch (e, stackTrace) {
    ref
        .read(errorLoggerProvider)
        .logError(e, stackTrace, context: 'GrowthMapProvider.loadDecisions');
  }

  return GrowthMapViewModel(
    root: RootNode(
      id: 'root',
      label: 'Akar Diri',
      semanticLabel: 'Akar Diri — Nilai Inti: ${coreValues.join(', ')}',
      coreValues: coreValues,
    ),
    branches: branchNodes,
    leaves: leafNodes,
    flowers: flowerNodes,
    fruits: fruitNodes,
    cumulativeDays: dashboardData.cumulativeDays,
    season: dashboardData.season,
  );
});
