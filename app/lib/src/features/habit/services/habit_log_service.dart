import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';

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
      if (log.status != 'Done') {
        // Update to Done
        await (_db.update(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId)))
            .write(HabitLogsCompanion(
              status: const drift.Value('Done'),
              durationTargetMin: drift.Value(habit.mvaDurationMin),
              durationActualMin: drift.Value(habit.mvaDurationMin),
              frictionReasonSelected: const drift.Value(null),
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
              status: 'Done',
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
    // Delete log
    await (_db.delete(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId))).go();
    
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
      final wasDone = log.status == 'Done';
      
      await (_db.update(_db.habitLogs)..where((tbl) => tbl.logId.equals(log.logId)))
          .write(HabitLogsCompanion(
            status: const drift.Value('Missed'),
            frictionReasonSelected: drift.Value(reason),
            durationTargetMin: const drift.Value(null),
            durationActualMin: const drift.Value(null),
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
              status: 'Missed',
              frictionReasonSelected: drift.Value(reason),
            ),
          );
    }
  }
}

final habitLogServiceProvider = Provider<HabitLogService>((ref) {
  return HabitLogService(ref.watch(dbProvider));
});
