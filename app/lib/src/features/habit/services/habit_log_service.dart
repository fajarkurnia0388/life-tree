import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';
import '../../../core/domain/app_constants.dart';

class HabitLogService {
  final AppDatabase _db;
  HabitLogService(this._db);

  Future<HabitLog?> _getLogForDay(String habitId, DateTime dateStart) async {
    // 1. Try to find active log
    final active = await (_db.select(_db.habitLogs)
          ..where((tbl) =>
              tbl.habitId.equals(habitId) &
              tbl.date.equals(dateStart) &
              tbl.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (active != null) return active;

    // 2. Fallback to any soft-deleted log
    final softDeleted = await (_db.select(_db.habitLogs)
          ..where((tbl) =>
              tbl.habitId.equals(habitId) &
              tbl.date.equals(dateStart) &
              tbl.deletedAt.isNotNull())
          ..limit(1))
        .getSingleOrNull();
    return softDeleted;
  }

  Future<void> markDone({required Habit habit, required DateTime date}) async {
    await _db.transaction(() async {
      final todayStart = DateTime(date.year, date.month, date.day);
      final log = await _getLogForDay(habit.habitId, todayStart);

      if (log != null) {
        if (log.status == HabitStatus.done && log.deletedAt == null) {
          return; // Idempotent
        }

        await (_db.update(_db.habitLogs)
              ..where((tbl) => tbl.logId.equals(log.logId)))
            .write(
          HabitLogsCompanion(
            status: const drift.Value(HabitStatus.done),
            durationTargetMin: drift.Value(habit.mvaDurationMin),
            durationActualMin: drift.Value(habit.mvaDurationMin),
            frictionReasonSelected: const drift.Value(null),
            deletedAt: const drift.Value(null),
          ),
        );

        // FIX: Atomic increment via SQL
        await _db.customUpdate(
          'UPDATE habits SET lifetime_done_count = lifetime_done_count + 1 WHERE habit_id = ?',
          variables: [drift.Variable<String>(habit.habitId)],
          updates: {_db.habits},
        );

        await _updateCompletionRate(habit.habitId);
      } else {
        final logId = const Uuid().v4();
        await _db.into(_db.habitLogs).insert(
              HabitLogsCompanion.insert(
                logId: logId,
                habitId: habit.habitId,
                date: todayStart,
                status: HabitStatus.done,
                durationTargetMin: drift.Value(habit.mvaDurationMin),
                durationActualMin: drift.Value(habit.mvaDurationMin),
              ),
            );

        // FIX: Atomic increment via SQL
        await _db.customUpdate(
          'UPDATE habits SET lifetime_done_count = lifetime_done_count + 1 WHERE habit_id = ?',
          variables: [drift.Variable<String>(habit.habitId)],
          updates: {_db.habits},
        );

        await _updateCompletionRate(habit.habitId);
      }
    });
  }

  int _countScheduledDays({
    required DateTime end,
    required int daysSinceCreation,
    required String frequency,
    required String? scheduledDays,
  }) {
    if (frequency == 'Daily') {
      return daysSinceCreation;
    }

    int count = 0;
    final days = scheduledDays != null && scheduledDays.isNotEmpty
        ? scheduledDays
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toSet()
        : <int>{};

    var current = DateTime(end.year, end.month, end.day);
    for (int i = 0; i < daysSinceCreation; i++) {
      if (days.contains(current.weekday)) {
        count++;
      }
      current = current.subtract(const Duration(days: 1));
    }
    return count;
  }

  Future<void> _updateCompletionRate(String habitId) async {
    final habit = await (_db.select(
      _db.habits,
    )..where((tbl) => tbl.habitId.equals(habitId))).getSingle();

    final daysSinceCreation = DateTime.now()
        .difference(habit.createdAt)
        .inDays
        .clamp(1, 90);

    final scheduledCount = _countScheduledDays(
      end: DateTime.now(),
      daysSinceCreation: daysSinceCreation,
      frequency: habit.frequency,
      scheduledDays: habit.scheduledDays,
    ).clamp(1, 90);

    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final logs90d =
        await (_db.select(_db.habitLogs)..where(
              (tbl) =>
                  tbl.habitId.equals(habitId) &
                  tbl.date.isBiggerOrEqualValue(ninetyDaysAgo) &
                  tbl.deletedAt.isNull(),
            ))
            .get();
    final done90d = logs90d.where((l) => l.status == HabitStatus.done).length;
    final rate = done90d / scheduledCount.toDouble();
    await (_db.update(
      _db.habits,
    )..where((tbl) => tbl.habitId.equals(habitId))).write(
      HabitsCompanion(completionRate90d: drift.Value(rate.clamp(0.0, 1.0))),
    );
  }

  Future<void> markUnchecked({
    required Habit habit,
    required HabitLog log,
  }) async {
    if (log.status != HabitStatus.done) return;

    await _db.transaction(() async {
      final now = DateTime.now();
      await (_db.update(_db.habitLogs)
            ..where((tbl) => tbl.logId.equals(log.logId)))
          .write(HabitLogsCompanion(deletedAt: drift.Value(now)));

      // FIX: Atomic decrement via SQL with floor at 0
      await _db.customUpdate(
        'UPDATE habits SET lifetime_done_count = CASE '
        'WHEN lifetime_done_count > 0 THEN lifetime_done_count - 1 '
        'ELSE 0 END '
        'WHERE habit_id = ?',
        variables: [drift.Variable<String>(habit.habitId)],
        updates: {_db.habits},
      );

      await _updateCompletionRate(habit.habitId);
    });
  }

  Future<void> markMissedWithReason({
    required Habit habit,
    required DateTime date,
    required String reason,
  }) async {
    await _db.transaction(() async {
      final todayStart = DateTime(date.year, date.month, date.day);
      final log = await _getLogForDay(habit.habitId, todayStart);

      if (log != null) {
        final wasDone = log.status == HabitStatus.done && log.deletedAt == null;
        await (_db.update(_db.habitLogs)
              ..where((tbl) => tbl.logId.equals(log.logId)))
            .write(
          HabitLogsCompanion(
            status: const drift.Value(HabitStatus.missed),
            frictionReasonSelected: drift.Value(reason),
            durationTargetMin: const drift.Value(null),
            durationActualMin: const drift.Value(null),
            deletedAt: const drift.Value(null),
          ),
        );

        if (wasDone) {
          // FIX: Atomic decrement via SQL with floor at 0
          await _db.customUpdate(
            'UPDATE habits SET lifetime_done_count = CASE '
            'WHEN lifetime_done_count > 0 THEN lifetime_done_count - 1 '
            'ELSE 0 END '
            'WHERE habit_id = ?',
            variables: [drift.Variable<String>(habit.habitId)],
            updates: {_db.habits},
          );
        }
      } else {
        final logId = const Uuid().v4();
        await _db.into(_db.habitLogs).insert(
              HabitLogsCompanion.insert(
                logId: logId,
                habitId: habit.habitId,
                date: todayStart,
                status: HabitStatus.missed,
                frictionReasonSelected: drift.Value(reason),
              ),
            );
      }
      await _updateCompletionRate(habit.habitId);
    });
  }
}

final habitLogServiceProvider = Provider<HabitLogService>((ref) {
  return HabitLogService(ref.watch(dbProvider));
});
