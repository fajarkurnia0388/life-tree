import 'package:daoji/src/core/services/reminder_coordinator.dart';
import 'package:daoji/src/core/domain/app_constants.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('reconcileAll executes without errors for Normal mode', () async {
    const userId = 'user-test';

    // Insert user profile
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '18-24',
            supportMode: const drift.Value(SupportMode.normal),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    // Insert habit
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: 'habit-1',
            userId: userId,
            title: 'Exercise',
            createdAt: DateTime.now(),
          ),
        );

    // Insert reminder preference
    await db.into(db.reminderPreferences).insert(
          ReminderPreferencesCompanion.insert(
            habitId: 'habit-1',
            reminderEnabled: const drift.Value(true),
            reminderTime: const drift.Value('07:30'),
          ),
        );

    // Reconcile
    await expectLater(coordinator.reconcileAll(userId), completes);
  });

  test('reconcileAll executes without errors for Recovery mode', () async {
    const userId = 'user-test-recovery';

    // Insert user profile with Recovery mode
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '18-24',
            supportMode: const drift.Value(SupportMode.recovery),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

    // Insert habit
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: 'habit-2',
            userId: userId,
            title: 'Meditate',
            createdAt: DateTime.now(),
          ),
        );

    // Reconcile
    await expectLater(coordinator.reconcileAll(userId), completes);
  });
}
