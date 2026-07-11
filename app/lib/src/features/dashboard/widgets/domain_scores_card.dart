import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/utils/profile_json_helpers.dart';
import '../dashboard_provider.dart';
import 'radar_chart_widget.dart';

/// Card widget untuk menampilkan domain scores dan radar chart
class DomainScoresCard extends ConsumerWidget {
  const DomainScoresCard({
    super.key,
    required this.data,
    required this.selectedDomain,
    required this.onDomainSelected,
  });

  final DashboardData data;
  final String? selectedDomain;
  final Function(String)? onDomainSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final scores = data.profile.parsedDomainScores;

    final List<String> domains = [
      'Tubuh',
      'Keuangan',
      'Hubungan',
      'Emosi',
      'Karir',
      'Rekreasi',
    ];
    for (final domain in domains) {
      final domainHabits = data.habitsToday.where(
        (h) => h.habit.domainTag == domain,
      );
      final completedHabits = domainHabits.where(
        (h) => h.log?.status == HabitStatus.done,
      );
      if (domainHabits.isNotEmpty) {
        final baselineScore = scores[domain] ?? 5.0;
        final dailyRatio = completedHabits.length / domainHabits.length;
        final dailyScore = dailyRatio * 10.0;
        scores[domain] = (baselineScore * 0.7 + dailyScore * 0.3).clamp(
          1.0,
          10.0,
        );
      }
    }

    final isDevMode = data.profile.isDeveloperMode;

    final activeDomains = <String>{'Tubuh'};
    if (isDevMode) {
      activeDomains.addAll([
        'Keuangan',
        'Hubungan',
        'Emosi',
        'Karir',
        'Rekreasi',
      ]);
    } else {
      activeDomains.addAll(data.profile.parsedDomainScores.keys);
      for (final hwl in data.habitsToday) {
        if (hwl.habit.domainTag != null) {
          activeDomains.add(hwl.habit.domainTag!);
        }
      }
    }

    return RadarChartWidget(
      scores: scores,
      activeDomains: activeDomains,
      selectedDomain: selectedDomain,
      onDomainSelected: onDomainSelected,
      vocabularyLevel: vocabularyLevel,
    );
  }
}
