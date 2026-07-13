import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/profile/services/activity_heatmap_service.dart';

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

  test('Updating theme updates DB correctly', () async {
    final userId = 'user-test-profile';
    final now = DateTime.now();

    // 1. Populate user profiles with default theme
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '18-24',
            themeMode: const drift.Value('System'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Verify initial state
    var profile = (await db.select(db.userProfiles).get()).first;
    expect(profile.themeMode, 'System');

    // 2. Perform updates
    await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(userId)))
        .write(const UserProfilesCompanion(themeMode: drift.Value('Dark')));

    // Verify updated state
    profile = (await db.select(db.userProfiles).get()).first;
    expect(profile.themeMode, 'Dark');
  });

  test('Updating core values saves to DB correctly', () async {
    final userId = 'user-test-profile-2';
    final now = DateTime.now();

    // 1. Populate user profiles with empty core values
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: userId,
            ageBand: '18-24',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Verify initial state
    var profile = (await db.select(db.userProfiles).get()).first;
    expect(profile.coreValues, isNull);

    // 2. Set core values
    final list = ['Kesehatan 🏃', 'Kebebasan 🗽', 'Keluarga 👨‍👩‍👧'];
    await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(userId)))
        .write(UserProfilesCompanion(coreValues: drift.Value(list)));

    // Verify saved state
    profile = (await db.select(db.userProfiles).get()).first;
    expect(profile.coreValues, isNotNull);
    final parsed = profile.coreValues!;
    expect(parsed.length, 3);
    expect(parsed[0], 'Kesehatan 🏃');
  });

  test('ActivityHeatmapService generateLast52Weeks behaves correctly on weekdays', () {
    final service = ActivityHeatmapService(db);

    // Monday case
    final monday = DateTime(2026, 7, 13); // Monday
    final weeksMonday = service.generateLast52Weeks(baseDate: monday);
    expect(weeksMonday.last, DateTime(2026, 7, 19)); // Should end on Sunday of that week
    expect(weeksMonday.contains(monday), isTrue);

    // Wednesday case
    final wednesday = DateTime(2026, 7, 15); // Wednesday
    final weeksWednesday = service.generateLast52Weeks(baseDate: wednesday);
    expect(weeksWednesday.last, DateTime(2026, 7, 19)); // Should still end on Sunday of that week
    expect(weeksWednesday.contains(wednesday), isTrue);

    // Sunday case
    final sunday = DateTime(2026, 7, 19); // Sunday
    final weeksSunday = service.generateLast52Weeks(baseDate: sunday);
    expect(weeksSunday.last, DateTime(2026, 7, 19)); // Should end on Sunday of that week
    expect(weeksSunday.contains(sunday), isTrue);

    // Range size should be exactly 364 days
    expect(weeksMonday.length, 364);
  });
}
