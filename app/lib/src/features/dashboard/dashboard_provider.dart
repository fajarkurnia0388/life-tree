import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../../core/domain/app_constants.dart';
import '../../core/domain/priority_helper.dart';
import '../../core/services/error_logger_provider.dart';
import '../../core/utils/profile_json_helpers.dart';
import '../../core/providers/user_profile_provider.dart';
import 'services/canopy_load_service.dart';

class DashboardData {
  final UserProfile profile;
  final int cumulativeDays;
  final String season;
  final Habit? actionOfTheDay;
  final List<HabitWithLog> habitsToday;
  final bool allDone;
  final bool hasOverdueDecisions;

  /// True when the user's latest WHO-5 score is below the 50% well-being threshold.
  /// Triggers Recovery Mode protections across the UI (habit blocking, season lock).
  final bool isLowWellBeing;

  /// Dynamically adjusted canopy load capacity based on WHO-5 score.
  /// Uses CanopyLoadService.calculateDynamicCapacity formula.
  final int dynamicCanopyCapacity;

  DashboardData({
    required this.profile,
    required this.cumulativeDays,
    required this.season,
    this.actionOfTheDay,
    required this.habitsToday,
    required this.allDone,
    required this.hasOverdueDecisions,
    this.isLowWellBeing = false,
    required this.dynamicCanopyCapacity,
  });
}

class HabitWithLog {
  final Habit habit;
  final HabitLog? log;
  HabitWithLog({required this.habit, this.log});
}

enum CelestialTime { auto, morning, noon, sunset, night }

final devTimeOfDayOverrideProvider = StateProvider<CelestialTime>(
  (ref) => CelestialTime.auto,
);

final devCumulativeDaysOverrideProvider = StateProvider<int?>((ref) => null);

class DevAgePlayNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _timer;

  DevAgePlayNotifier(this._ref) : super(false);

  void toggle() {
    if (state) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    state = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      final current = _ref.read(devCumulativeDaysOverrideProvider) ?? 0;
      if (current >= 100) {
        _ref.read(devCumulativeDaysOverrideProvider.notifier).state = 0;
      } else {
        _ref.read(devCumulativeDaysOverrideProvider.notifier).state =
            current + 1;
      }
    });
  }

  void stop() {
    state = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final devAgePlayProvider = StateNotifierProvider<DevAgePlayNotifier, bool>((
  ref,
) {
  final notifier = DevAgePlayNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class DevTimePlayNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _timer;

  DevTimePlayNotifier(this._ref) : super(false);

  void toggle() {
    if (state) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    state = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      final current = _ref.read(devTimeOfDayOverrideProvider);
      final next = switch (current) {
        CelestialTime.morning => CelestialTime.noon,
        CelestialTime.noon => CelestialTime.sunset,
        CelestialTime.sunset => CelestialTime.night,
        _ => CelestialTime.morning,
      };
      _ref.read(devTimeOfDayOverrideProvider.notifier).state = next;
    });
  }

  void stop() {
    state = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final devTimePlayProvider = StateNotifierProvider<DevTimePlayNotifier, bool>((
  ref,
) {
  final notifier = DevTimePlayNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class WellBeingStatus {
  final bool isLowWellBeing;
  final int dynamicCanopyCapacity;
  WellBeingStatus({
    required this.isLowWellBeing,
    required this.dynamicCanopyCapacity,
  });
}

final cumulativeDaysProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(dbProvider);
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) return 0;

  final overrideDays = ref.watch(devCumulativeDaysOverrideProvider);
  if (overrideDays != null) {
    return overrideDays;
  }
  return await db.countUniqueDoneDates(profile.userId);
});

final currentSeasonProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(dbProvider);
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) return Season.growth;

  if (profile.supportMode == SupportMode.recovery) {
    return Season.recovery;
  }

  final now = DateTime.now();
  DateTime lastActivity = profile.updatedAt;
  final userHabits =
      await (db.select(db.habits)..where(
            (tbl) => tbl.userId.equals(profile.userId) & tbl.deletedAt.isNull(),
          ))
          .get();
  final habitIds = userHabits.map((habit) => habit.habitId).toList();
  final latestLog = habitIds.isEmpty
      ? null
      : await (db.select(db.habitLogs)
              ..where(
                (tbl) => tbl.habitId.isIn(habitIds) & tbl.deletedAt.isNull(),
              )
              ..orderBy([
                (tbl) =>
                    OrderingTerm(expression: tbl.date, mode: OrderingMode.desc),
              ])
              ..limit(1))
            .getSingleOrNull();
  if (latestLog != null) {
    lastActivity = latestLog.date;
  }
  if (now.difference(lastActivity).inDays > 14) {
    return Season.dormant;
  }
  return Season.growth;
});

final habitsTodayProvider = FutureProvider<List<HabitWithLog>>((ref) async {
  final db = ref.watch(dbProvider);
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) return const [];

  final now = DateTime.now();
  final weekday = now.weekday;

  final allActiveHabits =
      await (db.select(db.habits)..where(
            (tbl) =>
                tbl.userId.equals(profile.userId) &
                tbl.status.equals(HabitStatus.active) &
                tbl.deletedAt.isNull(),
          ))
          .get();

  final todayStart = DateTime(now.year, now.month, now.day);
  final userHabitIds = allActiveHabits.map((h) => h.habitId).toList();

  final todayLogs = userHabitIds.isEmpty
      ? <HabitLog>[]
      : await (db.select(db.habitLogs)..where(
              (tbl) =>
                  tbl.date.equals(todayStart) &
                  tbl.habitId.isIn(userHabitIds) &
                  tbl.deletedAt.isNull(),
            ))
            .get();

  final List<HabitWithLog> habitsToday = [];
  for (final habit in allActiveHabits) {
    bool isScheduled = false;
    if (habit.frequency == HabitFrequency.daily) {
      isScheduled = true;
    } else if (habit.scheduledDays != null && habit.scheduledDays!.isNotEmpty) {
      final days = habit.scheduledDays!
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>();
      if (days.contains(weekday)) {
        isScheduled = true;
      }
    }

    if (isScheduled) {
      final log = todayLogs
          .where((l) => l.habitId == habit.habitId)
          .firstOrNull;
      habitsToday.add(HabitWithLog(habit: habit, log: log));
    }
  }
  return habitsToday;
});

final actionOfTheDayProvider = FutureProvider<Habit?>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) return null;

  final habitsToday = await ref.watch(habitsTodayProvider.future);
  final domainScores = profile.parsedDomainScores;

  Habit? actionOfTheDay;
  double highestPriority = -1.0;

  final uncompletedToday = habitsToday
      .where((hwl) => hwl.log?.status != HabitStatus.done)
      .toList();

  for (final hwl in uncompletedToday) {
    final score = computeHabitPriorityScore(
      habit: hwl.habit,
      domainScores: domainScores,
    );
    if (score > highestPriority) {
      highestPriority = score;
      actionOfTheDay = hwl.habit;
    }
  }
  return actionOfTheDay;
});

final overdueDecisionsProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(dbProvider);
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) return false;

  final overdueDecisions =
      await (db.select(db.decisionEntries)..where(
            (tbl) =>
                tbl.userId.equals(profile.userId) &
                tbl.deletedAt.isNull() &
                tbl.isReviewed.equals(false) &
                tbl.reviewDate.isSmallerThanValue(DateTime.now()),
          ))
          .get();
  return overdueDecisions.isNotEmpty;
});

final wellBeingStatusProvider = FutureProvider<WellBeingStatus>((ref) async {
  final db = ref.watch(dbProvider);
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) {
    return WellBeingStatus(isLowWellBeing: false, dynamicCanopyCapacity: 10);
  }

  int latestWho5Percentage = 100;
  final latestPulses =
      await (db.select(db.weeklyPulses)
            ..where(
              (tbl) =>
                  tbl.userId.equals(profile.userId) &
                  tbl.domainTag.equals('WHO-5') &
                  tbl.deletedAt.isNull(),
            )
            ..orderBy([
              (tbl) => OrderingTerm(
                expression: tbl.weekStartDate,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(1))
          .get();

  if (latestPulses.isNotEmpty) {
    try {
      final meta =
          jsonDecode(latestPulses.first.reflectionText ?? '{}')
              as Map<String, dynamic>;
      latestWho5Percentage = (meta['percentage'] as num?)?.toInt() ?? 100;
    } catch (e, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            e,
            stackTrace,
            context: 'DashboardProvider.parseWho5Metadata',
          );
    }
  }

  final isLowWellBeing = CanopyLoadService.isLowWellBeing(latestWho5Percentage);
  final dynamicCanopyCapacity = CanopyLoadService.calculateDynamicCapacity(
    who5Percentage: latestWho5Percentage,
    baseCapacity: profile.canopyLoadCapacity,
  );

  return WellBeingStatus(
    isLowWellBeing: isLowWellBeing,
    dynamicCanopyCapacity: dynamicCanopyCapacity,
  );
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile == null) {
    throw Exception('User profile not initialized');
  }

  // FIX: Parallelize independent provider reads
  final results = await Future.wait([
    ref.watch(cumulativeDaysProvider.future),
    ref.watch(currentSeasonProvider.future),
    ref.watch(habitsTodayProvider.future),
    ref.watch(actionOfTheDayProvider.future),
    ref.watch(overdueDecisionsProvider.future),
    ref.watch(wellBeingStatusProvider.future),
  ]);

  final cumulativeDays = results[0] as int;
  final season = results[1] as String;
  final habitsToday = results[2] as List<HabitWithLog>;
  final actionOfTheDay = results[3] as Habit?;
  final hasOverdueDecisions = results[4] as bool;
  final wellBeing = results[5] as WellBeingStatus;

  final totalScheduledToday = habitsToday.length;
  final totalDoneToday = habitsToday
      .where((hwl) => hwl.log?.status == HabitStatus.done)
      .length;
  final allDone =
      totalScheduledToday > 0 && totalDoneToday == totalScheduledToday;

  return DashboardData(
    profile: profile,
    cumulativeDays: cumulativeDays,
    season: season,
    actionOfTheDay: actionOfTheDay,
    habitsToday: habitsToday,
    allDone: allDone,
    hasOverdueDecisions: hasOverdueDecisions,
    isLowWellBeing: wellBeing.isLowWellBeing,
    dynamicCanopyCapacity: wellBeing.dynamicCanopyCapacity,
  );
});
