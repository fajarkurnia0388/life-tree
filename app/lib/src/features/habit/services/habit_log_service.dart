import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';
import '../../../core/domain/app_constants.dart';

class HabitLogService {
  final AppDatabase _db;
  HabitLogService(this._db);

  Future<void> markDone({
    required Habit habit,
    required DateTime date,
  }) async {
    final todayStart = DateTime(date.year, date.month, date.day);
    
    // Check if log exists
    final existing = await (_db.select(_db.habitLogs)
          ..where((tbl) => tbl.habitId.equals(habit.habitId) & tbl.date.equals(todayStart)))
        .get();

    if (existing.isNotEmpty) {
      final log = existing.first;
      if (log.status != HabitStatus.done) {
        // Update to Done
        await (_db.update(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId)))
            .write(HabitLogsCompanion(
              status: const drift.Value(HabitStatus.done),
              durationTargetMin: drift.Value(habit.mvaDurationMin),
              durationActualMin: drift.Value(habit.mvaDurationMin),
              frictionReasonSelected: const drift.Value(null),
              deletedAt: const drift.Value(null), // Clean deletedAt if it was soft-deleted earlier today
            ));

        // Increment done count
        final newCount = habit.lifetimeDoneCount + 1;
        await (_db.update(_db.habits)..where((tbl) => tbl.habitId.equals(habit.habitId)))
            .write(HabitsCompanion(lifetimeDoneCount: drift.Value(newCount)));
      }
    } else {
      // Insert new Done log
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

      // Increment done count
      final newCount = habit.lifetimeDoneCount + 1;
      await (_db.update(_db.habits)..where((tbl) => tbl.habitId.equals(habit.habitId)))
          .write(HabitsCompanion(lifetimeDoneCount: drift.Value(newCount)));
    }
  }

  Future<void> markUnchecked({
    required Habit habit,
    required HabitLog log,
  }) async {
    final now = DateTime.now();
    // Soft delete log instead of hard delete (FIX-15)
    await (_db.update(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId)))
        .write(HabitLogsCompanion(deletedAt: drift.Value(now)));
    
    // Decrement done count
    final newCount = (habit.lifetimeDoneCount - 1).clamp(0, 99999);
    await (_db.update(_db.habits)..where((tbl) => tbl.habitId.equals(habit.habitId)))
        .write(HabitsCompanion(lifetimeDoneCount: drift.Value(newCount)));
  }

  Future<void> markMissedWithReason({
    required Habit habit,
    required DateTime date,
    required String reason,
  }) async {
    final todayStart = DateTime(date.year, date.month, date.day);

    final existing = await (_db.select(_db.habitLogs)
          ..where((tbl) => tbl.habitId.equals(habit.habitId) & tbl.date.equals(todayStart)))
        .get();

    if (existing.isNotEmpty) {
      final log = existing.first;
      final wasDone = log.status == HabitStatus.done;
      
      await (_db.update(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId)))
          .write(HabitLogsCompanion(
            status: const drift.Value(HabitStatus.missed),
            frictionReasonSelected: drift.Value(reason),
            durationTargetMin: const drift.Value(null),
            durationActualMin: const drift.Value(null),
            deletedAt: const drift.Value(null),
          ));

      if (wasDone) {
        // If it was Done, decrement done count
        final newCount = (habit.lifetimeDoneCount - 1).clamp(0, 99999);
        await (_db.update(_db.habits)..where((tbl) => tbl.habitId.equals(habit.habitId)))
            .write(HabitsCompanion(lifetimeDoneCount: drift.Value(newCount)));
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
  }
}

final habitLogServiceProvider = Provider<HabitLogService>((ref) {
  return HabitLogService(ref.watch(dbProvider));
});
