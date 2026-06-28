import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../../core/domain/app_constants.dart';
import '../../core/domain/priority_helper.dart';

class DashboardData {
  final UserProfile profile;
  final int cumulativeDays;
  final String season;
  final Habit? actionOfTheDay;
  final List<HabitWithLog> habitsToday;
  final bool allDone;
  final bool hasOverdueDecisions;

  DashboardData({
    required this.profile,
    required this.cumulativeDays,
    required this.season,
    this.actionOfTheDay,
    required this.habitsToday,
    required this.allDone,
    required this.hasOverdueDecisions,
  });
}

class HabitWithLog {
  final Habit habit;
  final HabitLog? log;
  HabitWithLog({required this.habit, this.log});
}

enum CelestialTime { auto, morning, noon, sunset, night }

final devTimeOfDayOverrideProvider = StateProvider<CelestialTime>((ref) => CelestialTime.auto);

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
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      final current = _ref.read(devCumulativeDaysOverrideProvider) ?? 0;
      if (current >= 100) {
        _ref.read(devCumulativeDaysOverrideProvider.notifier).state = 0;
      } else {
        _ref.read(devCumulativeDaysOverrideProvider.notifier).state = current + 1;
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

final devAgePlayProvider = StateNotifierProvider<DevAgePlayNotifier, bool>((ref) {
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
        CelestialTime.noon    => CelestialTime.sunset,
        CelestialTime.sunset  => CelestialTime.night,
        _                     => CelestialTime.morning,
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

final devTimePlayProvider = StateNotifierProvider<DevTimePlayNotifier, bool>((ref) {
  final notifier = DevTimePlayNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final db = ref.watch(dbProvider);
  
  // 1. Get User Profile
  final profiles = await db.select(db.userProfiles).get();
  if (profiles.isEmpty) {
    throw Exception('User profile not initialized');
  }
  final profile = profiles.first;

  // 2. Get Cumulative success days (with Developer Override support)
  final overrideDays = ref.watch(devCumulativeDaysOverrideProvider);
  int cumulativeDays = 0;

  if (overrideDays != null) {
    cumulativeDays = overrideDays;
  } else {
    cumulativeDays = await db.countUniqueDoneDates();
  }

  // 3. Determine Current Season
  // Dormant: > 14 days of no habit logging or app updates (fallback to profile updatedAt)
  String season = Season.growth;
  if (profile.supportMode == SupportMode.recovery) {
    season = Season.recovery;
  } else {
    final now = DateTime.now();
    DateTime lastActivity = profile.updatedAt;
    final latestLog = await (db.select(db.habitLogs)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
    if (latestLog != null) {
      lastActivity = latestLog.date;
    }
    if (now.difference(lastActivity).inDays > 14) {
      season = Season.dormant;
    }
  }

  // 4. Get active habits scheduled for today
  final now = DateTime.now();
  final weekday = now.weekday; // 1 = Monday, 7 = Sunday
  
  // Filter habits by userId for data integrity
  final allActiveHabits = await (db.select(db.habits)
        ..where((tbl) =>
            tbl.userId.equals(profile.userId) &
            tbl.status.equals(HabitStatus.active) &
            tbl.deletedAt.isNull()))
      .get();
  
  final todayStart = DateTime(now.year, now.month, now.day);
  final userHabitIds = allActiveHabits.map((h) => h.habitId).toList();
  
  // Only fetch logs for this user's habits
  final todayLogs = userHabitIds.isEmpty
      ? <HabitLog>[]
      : await (db.select(db.habitLogs)
            ..where((tbl) =>
                tbl.date.equals(todayStart) &
                tbl.habitId.isIn(userHabitIds) &
                tbl.deletedAt.isNull()))
          .get();

  final List<HabitWithLog> habitsToday = [];
  
  for (final habit in allActiveHabits) {
    bool isScheduled = false;
    if (habit.frequency == HabitFrequency.daily) {
      isScheduled = true;
    } else if (habit.scheduledDays != null && habit.scheduledDays!.isNotEmpty) {
      // Safely parse scheduledDays, ignoring non-numeric tokens
      final days = habit.scheduledDays!
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>();
      if (days.contains(weekday)) {
        isScheduled = true;
      }
    }

    if (isScheduled) {
      final log = todayLogs.where((l) => l.habitId == habit.habitId).firstOrNull;
      habitsToday.add(HabitWithLog(habit: habit, log: log));
    }
  }

  // 5. Calculate Action of the Day (Priority Score)
  Map<String, dynamic> domainScores = {};
  if (profile.latestDomainScores != null) {
    try {
      domainScores = jsonDecode(profile.latestDomainScores!);
    } catch (_) {}
  }
  
  Habit? actionOfTheDay;
  double highestPriority = -1.0;

  // We filter to scheduled habits for today that are not completed yet
  final uncompletedToday = habitsToday.where((hwl) => hwl.log?.status != HabitStatus.done).toList();

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

  // 6. Check if there are overdue decisions
  final overdueDecisions = await (db.select(db.decisionEntries)
        ..where((tbl) => tbl.isReviewed.equals(false) & tbl.reviewDate.isSmallerThanValue(DateTime.now())))
      .get();
  final hasOverdueDecisions = overdueDecisions.isNotEmpty;

  // 7. Check if all scheduled habits today are done
  final totalScheduledToday = habitsToday.length;
  final totalDoneToday = habitsToday.where((hwl) => hwl.log?.status == HabitStatus.done).length;
  final allDone = totalScheduledToday > 0 && totalDoneToday == totalScheduledToday;

  return DashboardData(
    profile: profile,
    cumulativeDays: cumulativeDays,
    season: season,
    actionOfTheDay: actionOfTheDay,
    habitsToday: habitsToday,
    allDone: allDone,
    hasOverdueDecisions: hasOverdueDecisions,
  );
});
