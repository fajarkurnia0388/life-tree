import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/dashboard/growth_map_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
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

  group('GrowthMap Domain State Tests (Anti-Guilt Verification)', () {
    test('Skor 1-4 menghasilkan state Butuh Perhatian (needsAttention)', () async {
      await db.into(db.userProfiles).insert(
        UserProfilesCompanion.insert(
          userId: 'user-1',
          ageBand: '18-24',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          latestDomainScores: drift.Value(jsonEncode({'Tubuh': 3.0})),
        ),
      );

      final vm = await container.read(growthMapProvider.future);
      final tubuh = vm.branches.firstWhere((b) => b.id == 'Tubuh');
      expect(tubuh.statusLabel, 'Butuh perhatian');
      expect(tubuh.statusLabel, isNot(contains('layu')));
      expect(tubuh.statusLabel, isNot(contains('mati')));
      expect(tubuh.statusLabel, isNot(contains('kering')));
    });

    test('Skor 5-7 menghasilkan state Netral', () async {
      await db.into(db.userProfiles).insert(
        UserProfilesCompanion.insert(
          userId: 'user-1',
          ageBand: '18-24',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          latestDomainScores: drift.Value(jsonEncode({'Tubuh': 6.0})),
        ),
      );

      final vm = await container.read(growthMapProvider.future);
      final tubuh = vm.branches.firstWhere((b) => b.id == 'Tubuh');
      expect(tubuh.statusLabel, 'Netral');
    });

    test('Skor 8-10 menghasilkan state Stabil (Healthy)', () async {
      await db.into(db.userProfiles).insert(
        UserProfilesCompanion.insert(
          userId: 'user-1',
          ageBand: '18-24',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          latestDomainScores: drift.Value(jsonEncode({'Tubuh': 9.0})),
        ),
      );

      final vm = await container.read(growthMapProvider.future);
      final tubuh = vm.branches.firstWhere((b) => b.id == 'Tubuh');
      expect(tubuh.statusLabel, 'Stabil');
    });
  });
}
