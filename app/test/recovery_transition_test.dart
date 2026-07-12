import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/domain/app_constants.dart';
import 'package:daoji/src/core/services/reminder_coordinator.dart';
import 'package:daoji/src/data/local_db/database.dart';

/// Recovery transition coverage via ReminderCoordinator policy:
/// Recovery mode cancels reminders; leaving recovery re-enables scheduling path.
void main() {
  late AppDatabase db;
  late ReminderCoordinator coordinator;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    coordinator = ReminderCoordinator(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedUser({
    required String userId,
    required String supportMode,
  }) async {
    final now = DateTime.now();
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '25-35',
            supportMode: drift.Value(supportMode),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: 'habit-$userId',
            userId: userId,
            title: 'Stretch',
            createdAt: now,
          ),
        );

    await db.into(db.reminderPreferences).insert(
          ReminderPreferencesCompanion.insert(
            habitId: 'habit-$userId',
            reminderEnabled: const drift.Value(true),
            reminderTime: const drift.Value('08:00'),
          ),
        );
  }

  test('recovery mode reconcile completes without throwing', () async {
    const userId = 'user-recovery-on';
    await seedUser(userId: userId, supportMode: SupportMode.recovery);

    await expectLater(coordinator.reconcileAll(userId), completes);
    await expectLater(coordinator.cancelAll(userId), completes);
  });

  test('transition recovery → normal reconciles cleanly', () async {
    const userId = 'user-recovery-transition';
    await seedUser(userId: userId, supportMode: SupportMode.recovery);

    // While in recovery, reconcile should cancel path.
    await coordinator.reconcileAll(userId);

    // Leave recovery.
    await (db.update(db.userProfiles)..where((t) => t.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        supportMode: const drift.Value(SupportMode.normal),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    // Leaving recovery should re-enter schedule path without error.
    await expectLater(coordinator.reconcileAll(userId), completes);

    final profile = await (db.select(db.userProfiles)
          ..where((t) => t.userId.equals(userId)))
        .getSingle();
    expect(profile.supportMode, SupportMode.normal);
  });

  test('normal mode reconcile completes with enabled reminder prefs', () async {
    const userId = 'user-normal';
    await seedUser(userId: userId, supportMode: SupportMode.normal);

    await expectLater(coordinator.reconcileAll(userId), completes);
  });
}
