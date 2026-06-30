import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:life_tree/src/core/providers/db_provider.dart';
import 'package:life_tree/src/data/local_db/database.dart';

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
        .write(UserProfilesCompanion(coreValues: drift.Value(jsonEncode(list))));

    // Verify saved state
    profile = (await db.select(db.userProfiles).get()).first;
    expect(profile.coreValues, isNotNull);
    final parsed = List<String>.from(jsonDecode(profile.coreValues!));
    expect(parsed.length, 3);
    expect(parsed[0], 'Kesehatan 🏃');
  });
}
