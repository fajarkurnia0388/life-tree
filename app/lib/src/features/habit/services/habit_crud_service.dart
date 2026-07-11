import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../core/domain/app_constants.dart';
import '../../../data/local_db/database.dart';

class HabitDetail {
  final Habit habit;
  final ReminderPreference? reminder;
  HabitDetail({required this.habit, this.reminder});
}

class HabitCrudService {
  final AppDatabase db;
  HabitCrudService(this.db);

  Future<List<Habit>> getActiveHabits(String userId) async {
    return await (db.select(db.habits)
          ..where((tbl) =>
              tbl.userId.equals(userId) &
              tbl.status.equals(HabitStatus.active) &
              tbl.deletedAt.isNull()))
        .get();
  }

  Future<HabitDetail?> getHabitDetail(String habitId) async {
    final habit = await (db.select(db.habits)
          ..where((tbl) => tbl.habitId.equals(habitId)))
        .getSingleOrNull();
    if (habit == null) return null;

    final reminder = await (db.select(db.reminderPreferences)
          ..where((tbl) => tbl.habitId.equals(habitId)))
        .getSingleOrNull();

    return HabitDetail(habit: habit, reminder: reminder);
  }

  Future<void> updateHabit({
    required String habitId,
    required String domainTag,
    required String title,
    required String frequency,
    required String? scheduledDays,
    required int initiationFriction,
    required int energyCost,
    required int impactScore,
    required int mvaDurationMin,
    required String? stackedToHabitId,
    required String? goalTag,
    required bool reminderEnabled,
    required String reminderTime,
    required String quietHoursStart,
    required String quietHoursEnd,
  }) async {
    await (db.update(db.habits)
          ..where((tbl) => tbl.habitId.equals(habitId)))
        .write(
      HabitsCompanion(
        domainTag: drift.Value(domainTag),
        title: drift.Value(title),
        frequency: drift.Value(frequency),
        scheduledDays: drift.Value(scheduledDays),
        initiationFriction: drift.Value(initiationFriction),
        energyCost: drift.Value(energyCost),
        impactScore: drift.Value(impactScore),
        mvaDurationMin: drift.Value(mvaDurationMin),
        stackedToHabitId: drift.Value(stackedToHabitId),
        goalTag: drift.Value(goalTag),
      ),
    );

    final reminder = ReminderPreferencesCompanion(
      habitId: drift.Value(habitId),
      reminderEnabled: drift.Value(reminderEnabled),
      reminderTime: drift.Value(reminderTime),
      quietHoursStart: drift.Value(quietHoursStart),
      quietHoursEnd: drift.Value(quietHoursEnd),
    );
    await db.into(db.reminderPreferences).insertOnConflictUpdate(reminder);
  }

  Future<void> createHabit({
    required HabitsCompanion newHabit,
    required ReminderPreferencesCompanion reminder,
  }) async {
    await db.into(db.habits).insert(newHabit);
    await db.into(db.reminderPreferences).insert(reminder);
  }

  Future<void> deleteHabit(String habitId) async {
    await (db.update(db.habits)
          ..where((tbl) => tbl.habitId.equals(habitId)))
        .write(
      HabitsCompanion(
        deletedAt: drift.Value(DateTime.now()),
      ),
    );
  }
}

final habitCrudServiceProvider = Provider<HabitCrudService>((ref) {
  return HabitCrudService(ref.watch(dbProvider));
});
