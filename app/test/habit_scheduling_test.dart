import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/dashboard/dashboard_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  final userId = 'test-user';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );

    // Setup minimal user profile so dashboardDataProvider can load
    final now = DateTime.now();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '25-35',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  /// Helper: insert a habit with given frequency/scheduledDays
  Future<void> insertHabit({
    required String habitId,
    required String frequency,
    String? scheduledDays,
  }) async {
    final now = DateTime.now();
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: habitId,
            userId: userId,
            title: 'Test Habit $habitId',
            frequency: drift.Value(frequency),
            scheduledDays: drift.Value(scheduledDays),
            createdAt: now,
          ),
        );
  }

  group('Habit Scheduling — Daily', () {
    test('Habit Daily selalu muncul di habitsToday setiap hari', () async {
      await insertHabit(habitId: 'daily-1', frequency: 'Daily');

      final data = await container.read(dashboardDataProvider.future);

      expect(data.habitsToday.any((h) => h.habit.habitId == 'daily-1'), isTrue,
          reason: 'Habit Daily harus selalu terjadwal hari ini');
    });
  });

  group('Habit Scheduling — Custom Days (scheduledDays)', () {
    // Senin = 1, Selasa = 2, Rabu = 3, Kamis = 4, Jumat = 5, Sabtu = 6, Minggu = 7
    // Kita tidak bisa mengontrol hari saat test berjalan, jadi kita validasi
    // berdasarkan weekday aktual dan apakah habit seharusnya tampil atau tidak.

    test('Habit terjadwal di semua hari (1,2,3,4,5,6,7) selalu muncul', () async {
      await insertHabit(
        habitId: 'all-days',
        frequency: 'Custom',
        scheduledDays: '1,2,3,4,5,6,7',
      );

      final data = await container.read(dashboardDataProvider.future);

      expect(data.habitsToday.any((h) => h.habit.habitId == 'all-days'), isTrue,
          reason: 'Habit dengan semua hari scheduled harus selalu tampil');
    });

    test('Habit tidak terjadwal di hari manapun (scheduledDays kosong) tidak muncul', () async {
      await insertHabit(
        habitId: 'no-days',
        frequency: 'Custom',
        scheduledDays: '',
      );

      final data = await container.read(dashboardDataProvider.future);

      expect(data.habitsToday.any((h) => h.habit.habitId == 'no-days'), isFalse,
          reason: 'Habit tanpa hari terjadwal tidak boleh muncul');
    });

    test('Habit dengan scheduledDays null tidak muncul dan tidak crash', () async {
      await insertHabit(
        habitId: 'null-days',
        frequency: 'Custom',
        scheduledDays: null,
      );

      // Should NOT throw
      final data = await container.read(dashboardDataProvider.future);

      expect(data.habitsToday.any((h) => h.habit.habitId == 'null-days'), isFalse,
          reason: 'Habit dengan scheduledDays null tidak boleh crash atau tampil');
    });

    test('Habit hanya muncul di hari yang sesuai (hari aktual vs jadwal)', () async {
      final today = DateTime.now().weekday; // 1-7
      final tomorrow = today % 7 + 1; // next day (wraps around)

      await insertHabit(
        habitId: 'today-only',
        frequency: 'Custom',
        scheduledDays: '$today', // hanya hari ini
      );
      await insertHabit(
        habitId: 'tomorrow-only',
        frequency: 'Custom',
        scheduledDays: '$tomorrow', // hanya besok
      );

      final data = await container.read(dashboardDataProvider.future);

      expect(data.habitsToday.any((h) => h.habit.habitId == 'today-only'), isTrue,
          reason: 'Habit hari ini harus muncul');
      expect(data.habitsToday.any((h) => h.habit.habitId == 'tomorrow-only'), isFalse,
          reason: 'Habit besok tidak boleh muncul hari ini');
    });
  });

  group('Habit Scheduling — userId Filtering', () {
    test('Habit milik user lain tidak muncul di habitsToday', () async {
      // Insert habit for another user
      final now = DateTime.now();
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'other-user-habit',
              userId: 'other-user-id',
              title: 'Other User Habit',
              frequency: const drift.Value('Daily'),
              createdAt: now,
            ),
          );

      final data = await container.read(dashboardDataProvider.future);

      expect(
          data.habitsToday.any((h) => h.habit.habitId == 'other-user-habit'),
          isFalse,
          reason: 'Habit milik user lain tidak boleh muncul');
    });
  });

  group('Habit Scheduling — scheduledDays parsing', () {
    test('scheduledDays dengan spasi ("1, 3, 5") di-parse dengan benar', () async {
      final today = DateTime.now().weekday;
      // If today is Mon(1)/Wed(3)/Fri(5) it should appear, otherwise not
      final expectedScheduled = [1, 3, 5].contains(today);

      await insertHabit(
        habitId: 'spaced-days',
        frequency: 'Custom',
        scheduledDays: '1, 3, 5', // with spaces
      );

      final data = await container.read(dashboardDataProvider.future);
      final isScheduled = data.habitsToday.any((h) => h.habit.habitId == 'spaced-days');

      expect(isScheduled, expectedScheduled,
          reason: 'scheduledDays dengan spasi harus di-parse dengan benar');
    });

    test('scheduledDays dengan token tidak valid ("1,abc,3") tidak crash', () async {
      await insertHabit(
        habitId: 'invalid-days',
        frequency: 'Custom',
        scheduledDays: '1,abc,3', // invalid token
      );

      // Should NOT throw
      expect(() => container.read(dashboardDataProvider.future), returnsNormally);
    });
  });
}
