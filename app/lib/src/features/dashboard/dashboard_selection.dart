import 'dart:convert';

import '../../core/domain/app_constants.dart';
import '../../core/domain/priority_helper.dart';
import '../../data/local_db/database.dart';
import 'dashboard_provider.dart';

/// Pure helpers for dashboard presentation (no Riverpod / no BuildContext).
/// Extracted so domain filter + Action-of-the-Day selection are unit-testable.

/// Filter today's habits by domain chip (`Semua` = no filter).
List<HabitWithLog> filterHabitsByDomain(
  List<HabitWithLog> habitsToday,
  String domainFilter,
) {
  if (domainFilter == 'Semua' || domainFilter.trim().isEmpty) {
    return List<HabitWithLog>.from(habitsToday);
  }
  return habitsToday
      .where((hwl) => hwl.habit.domainTag == domainFilter)
      .toList();
}

/// Parse domain scores JSON safely. Returns empty map on failure.
Map<String, dynamic> parseDomainScoresJson(String? raw) {
  if (raw == null || raw.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  } catch (_) {
    // Caller may log; keep pure path silent.
  }
  return {};
}

/// Average domain score / 10 as balance index in 0–1 range. Default 0.5.
double computeBalanceIndex(Map<String, dynamic> scores) {
  if (scores.isEmpty) return 0.5;
  var total = 0.0;
  var count = 0;
  for (final val in scores.values) {
    if (val is num) {
      total += val.toDouble();
      count++;
    }
  }
  if (count == 0) return 0.5;
  return (total / count) / 10.0;
}

/// Pick Action of the Day among [filteredHabits] using priority helper.
/// Only considers habits not marked done today.
Habit? selectActionOfTheDay({
  required List<HabitWithLog> filteredHabits,
  required Map<String, dynamic> domainScores,
}) {
  Habit? best;
  var highest = -1.0;
  final uncompleted = filteredHabits
      .where((hwl) => hwl.log?.status != HabitStatus.done)
      .toList();
  for (final hwl in uncompleted) {
    final score = computeHabitPriorityScore(
      habit: hwl.habit,
      domainScores: domainScores,
    );
    if (score > highest) {
      highest = score;
      best = hwl.habit;
    }
  }
  return best;
}

/// Resolve active AOTD for the current domain filter.
/// When filter is `Semua`, prefer [globalActionOfTheDay] (from provider).
Habit? resolveActiveActionOfTheDay({
  required String domainFilter,
  required Habit? globalActionOfTheDay,
  required List<HabitWithLog> filteredHabits,
  required Map<String, dynamic> domainScores,
}) {
  if (domainFilter == 'Semua' || domainFilter.trim().isEmpty) {
    return globalActionOfTheDay;
  }
  return selectActionOfTheDay(
    filteredHabits: filteredHabits,
    domainScores: domainScores,
  );
}
