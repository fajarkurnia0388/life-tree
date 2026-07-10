import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/habit/services/habit_log_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late HabitLogService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );
    service = container.read(habitLogServiceProvider);
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  /// Helper untuk membuat Habit dummy di database
  Future<Habit> createHabit(String habitId) async {
    final now = DateTime.now();
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: habitId,
            userId: 'user-1',
            title: 'Test Habit',
            createdAt: now,
          ),
        );
    return (await (db.select(db.habits)
              ..where((tbl) => tbl.habitId.equals(habitId)))
            .get())
        .first;
  }

  group('HabitLogService - markDone', () {
    test('Insert log Done baru jika belum ada log hari ini', () async {
      final habit = await createHabit('habit-mark-done-new');
      final today = DateTime.now();

      await service.markDone(habit: habit, date: today);

      final todayStart = DateTime(today.year, today.month, today.day);
      final logs = await (db.select(db.habitLogs)
            ..where((tbl) =>
                tbl.habitId.equals('habit-mark-done-new') &
                tbl.date.equals(todayStart)))
          .get();

      expect(logs.length, 1);
      expect(logs.first.status, 'Done');

      final updatedHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-mark-done-new')))
              .get())
          .first;
      expect(updatedHabit.lifetimeDoneCount, 1);
    });

    test('Update log Missed menjadi Done jika log hari ini sudah ada (upsert)', () async {
      final habit = await createHabit('habit-upsert-done');
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // Pre-insert a Missed log
      await db.into(db.habitLogs).insert(
            HabitLogsCompanion.insert(
              logId: 'log-upsert-1',
              habitId: 'habit-upsert-done',
              date: todayStart,
              status: 'Missed',
            ),
          );

      // Call markDone — should update the existing Missed log, not insert a new one
      await service.markDone(habit: habit, date: now);

      final logs = await (db.select(db.habitLogs)
            ..where((tbl) =>
                tbl.habitId.equals('habit-upsert-done') &
                tbl.date.equals(todayStart)))
          .get();

      // Should still be only ONE log (updated)
      expect(logs.length, 1);
      expect(logs.first.status, 'Done');
    });

    test('Tidak menambah count jika log sudah berstatus Done', () async {
      final habit = await createHabit('habit-double-done');
      final now = DateTime.now();

      // First markDone — count = 1
      await service.markDone(habit: habit, date: now);

      final updatedHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-double-done')))
              .get())
          .first;

      // Second markDone — should be a no-op since status already Done
      await service.markDone(habit: updatedHabit, date: now);

      final finalHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-double-done')))
              .get())
          .first;
      // Count should still be 1, not 2
      expect(finalHabit.lifetimeDoneCount, 1);
    });
  });

  group('HabitLogService - markMissedWithReason', () {
    test('Insert Missed log baru jika belum ada log hari ini', () async {
      final habit = await createHabit('habit-mark-missed-new');
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      await service.markMissedWithReason(
        habit: habit,
        date: now,
        reason: 'Kelelahan',
      );

      final logs = await (db.select(db.habitLogs)
            ..where((tbl) =>
                tbl.habitId.equals('habit-mark-missed-new') &
                tbl.date.equals(todayStart)))
          .get();

      expect(logs.length, 1);
      expect(logs.first.status, 'Missed');
      expect(logs.first.frictionReasonSelected, 'Kelelahan');
    });

    test('Update log Done menjadi Missed tanpa duplikasi (upsert)', () async {
      final habit = await createHabit('habit-done-to-missed');
      final now = DateTime.now();

      // First, mark as Done
      await service.markDone(habit: habit, date: now);

      final doneHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-done-to-missed')))
              .get())
          .first;
      expect(doneHabit.lifetimeDoneCount, 1);

      // Then mark as Missed — should decrement count and update log
      await service.markMissedWithReason(
        habit: doneHabit,
        date: now,
        reason: 'Kurang_Waktu',
      );

      final todayStart = DateTime(now.year, now.month, now.day);
      final logs = await (db.select(db.habitLogs)
            ..where((tbl) =>
                tbl.habitId.equals('habit-done-to-missed') &
                tbl.date.equals(todayStart)))
          .get();

      // Only ONE log should exist
      expect(logs.length, 1);
      expect(logs.first.status, 'Missed');
      expect(logs.first.frictionReasonSelected, 'Kurang_Waktu');

      // Count should have been decremented back to 0
      final finalHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-done-to-missed')))
              .get())
          .first;
      expect(finalHabit.lifetimeDoneCount, 0);
    });
  });

  group('HabitLogService - completionRate90d dynamic denominator', () {
    test('Habit baru dibuat kemarin (1 hari lalu) memiliki denominator = 1', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Buat habit dengan createdAt kemarin
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'habit-dynamic-denom-1',
              userId: 'user-1',
              title: 'Dynamic Denom Test',
              createdAt: yesterday,
            ),
          );
      final habit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-dynamic-denom-1')))
              .get())
          .first;

      // Mark done today (1 done / 1 hari = 1.0)
      await service.markDone(habit: habit, date: now);

      final updatedHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-dynamic-denom-1')))
              .get())
          .first;
      
      expect(updatedHabit.completionRate90d, 1.0);
    });

    test('Habit baru dibuat 5 hari lalu dengan 2 done memiliki rate 0.4', () async {
      final now = DateTime.now();
      final fiveDaysAgo = now.subtract(const Duration(days: 5));
      
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'habit-dynamic-denom-5',
              userId: 'user-1',
              title: 'Dynamic Denom Test 5',
              createdAt: fiveDaysAgo,
            ),
          );
      final habit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-dynamic-denom-5')))
              .get())
          .first;

      // Mark done today and yesterday
      await service.markDone(habit: habit, date: now);
      await service.markDone(habit: habit, date: now.subtract(const Duration(days: 1)));

      final updatedHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-dynamic-denom-5')))
              .get())
          .first;
      
      // 2 done / 5 hari = 0.4
      expect(updatedHabit.completionRate90d, closeTo(0.4, 0.01));
    });

    test('Habit weekly (dijadwalkan 3x seminggu) sejak 7 hari lalu dengan 2 done memiliki rate 2/3 = 0.67', () async {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      // Determine what weekdays occurred in the last 7 days.
      // We will schedule it on three weekdays that we know occurred.
      final day1 = now.subtract(const Duration(days: 1)).weekday;
      final day2 = now.subtract(const Duration(days: 3)).weekday;
      final day3 = now.subtract(const Duration(days: 5)).weekday;
      final scheduledDaysStr = '$day1,$day2,$day3';

      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'habit-weekly-denom',
              userId: 'user-1',
              title: 'Weekly Denom Test',
              frequency: const drift.Value('Weekly'),
              scheduledDays: drift.Value(scheduledDaysStr),
              createdAt: sevenDaysAgo,
            ),
          );
      final habit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-weekly-denom')))
              .get())
          .first;

      // Mark done on 2 of the scheduled days (yesterday and 3 days ago)
      await service.markDone(habit: habit, date: now.subtract(const Duration(days: 1)));
      await service.markDone(habit: habit, date: now.subtract(const Duration(days: 3)));

      final updatedHabit = (await (db.select(db.habits)
                ..where((tbl) => tbl.habitId.equals('habit-weekly-denom')))
              .get())
          .first;
      
      // 2 done / 3 scheduled days = 0.666...
      expect(updatedHabit.completionRate90d, closeTo(0.67, 0.01));
    });
  });
}
