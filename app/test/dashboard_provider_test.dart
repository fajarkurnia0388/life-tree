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

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  test('Dashboard provider calculates dynamic priority score correctly based on domain deficit', () async {
    final userId = 'user-1';
    final now = DateTime.now();

    // 1. Setup profile with domain scores
    // Tubuh score is high (8.0), meaning low deficit (2.0)
    // Keuangan score is low (3.0), meaning high deficit (7.0)
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '25-35',
            latestDomainScores: drift.Value('{"Tubuh":8,"Keuangan":3}'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    // 2. Add two active habits
    // Habit 1: Domain 'Tubuh' (deficit: 10 - 8 = 2)
    // Priority score = (2 * 4) / 4 = 2.0
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: 'habit-1',
            userId: userId,
            domainTag: const drift.Value('Tubuh'),
            title: 'Olahraga',
            initiationFriction: const drift.Value(2),
            energyCost: const drift.Value(2),
            impactScore: const drift.Value(4),
            createdAt: now,
          ),
        );

    // Habit 2: Domain 'Keuangan' (deficit: 10 - 3 = 7)
    // Priority score = (7 * 4) / 4 = 7.0
    await db.into(db.habits).insert(
          HabitsCompanion.insert(
            habitId: 'habit-2',
            userId: userId,
            domainTag: const drift.Value('Keuangan'),
            title: 'Catat Pengeluaran',
            initiationFriction: const drift.Value(2),
            energyCost: const drift.Value(2),
            impactScore: const drift.Value(4),
            createdAt: now,
          ),
        );

    // 3. Read dashboardDataProvider
    final data = await container.read(dashboardDataProvider.future);

    // 4. Verify Habit 2 is selected as Action of the Day
    expect(data.actionOfTheDay, isNotNull);
    expect(data.actionOfTheDay!.habitId, 'habit-2');
  });
}
