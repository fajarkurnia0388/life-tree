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

    // Seed a user profile
    await db.into(db.userProfiles).insert(
      UserProfilesCompanion.insert(
        userId: 'user-1',
        ageBand: '18-24',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        coreValues: const drift.Value(['Kesehatan', 'Kebebasan', 'Keluarga']),
        latestDomainScores: const drift.Value({'Tubuh': 9.0, 'Keuangan': 4.0}),
      ),
    );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  group('GrowthMapViewModel Tests', () {
    test('growthMapProvider parses core values and domain scores correctly', () async {
      final vm = await container.read(growthMapProvider.future);

      expect(vm.root.coreValues, containsAll(['Kesehatan', 'Kebebasan', 'Keluarga']));
      expect(vm.branches.length, 6);

      final tubuh = vm.branches.firstWhere((b) => b.id == 'Tubuh');
      expect(tubuh.score, 9.0);
      expect(tubuh.statusLabel, 'Stabil');

      final keuangan = vm.branches.firstWhere((b) => b.id == 'Keuangan');
      expect(keuangan.score, 4.0);
      expect(keuangan.statusLabel, 'Butuh perhatian');
    });
  });
}
