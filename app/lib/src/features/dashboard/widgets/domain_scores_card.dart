import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/services/error_handler_service.dart';
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
    Map<String, double> scores = {
      'Tubuh': 5.0,
      'Keuangan': 3.0,
      'Hubungan': 3.0,
      'Emosi': 3.0,
      'Karir': 3.0,
      'Rekreasi': 3.0,
    };

    try {
      final jsonStr = data.profile.latestDomainScores;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> parsed = jsonDecode(jsonStr);
        parsed.forEach((key, value) {
          final numVal = value as num;
          if (scores.containsKey(key)) {
            scores[key] = numVal.toDouble();
          }
        });
      }
    } catch (e, stackTrace) {
      ErrorHandlerService().logError(
        e,
        stackTrace,
        context: 'DomainScoresCard.parseDomainScores',
      );
    }

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
      try {
        final jsonStr = data.profile.latestDomainScores;
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final Map<String, dynamic> parsed = jsonDecode(jsonStr);
          activeDomains.addAll(parsed.keys);
        }
      } catch (e, stackTrace) {
        ErrorHandlerService().logError(
          e,
          stackTrace,
          context: 'DomainScoresCard.parseActiveDomains',
        );
      }
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
