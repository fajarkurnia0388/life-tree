import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/dashboard/dashboard_provider.dart';
import 'package:daoji/src/features/cultivation/cultivation_layer.dart';
import 'package:daoji/src/features/cultivation/cultivation_constants.dart';
import 'package:daoji/src/features/cultivation/cultivation_provider.dart';

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

  group('CultivationLayer', () {
    test('builds from dashboard data without database migration', () async {
      final userId = 'user-cultivation-1';
      final now = DateTime.now();

      // Setup minimal profile
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              latestDomainScores: drift.Value(
                '{"Tubuh":8.0,"Keuangan":6.0,"Hubungan":7.0,"Emosi":5.0,"Karir":6.5,"Rekreasi":7.5}',
              ),
              coreValues: const drift.Value('Kejujuran, Kesehatan, Kreativitas'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Add a habit to generate dashboard data
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'habit-1',
              userId: userId,
              domainTag: const drift.Value('Tubuh'),
              title: 'Morning Exercise',
              completionRate90d: const drift.Value(0.75),
              createdAt: now,
            ),
          );

      // Read dashboard data
      final dashboardData = await container.read(dashboardDataProvider.future);

      // Build cultivation layer from dashboard data
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      // Verify cultivation layer was built successfully
      expect(cultivation, isNotNull);
      expect(cultivation.realm, inInclusiveRange(1, 8));
      expect(cultivation.realmName, isNotEmpty);
      expect(cultivation.season, isA<CultivationSeason>());
      expect(cultivation.palaceScores, hasLength(6));
      expect(cultivation.qiLevel, inInclusiveRange(0.0, 1.0));
      expect(cultivation.cumulativeDays, greaterThanOrEqualTo(0));
      expect(cultivation.daoHeart, isNotNull);
    });

    test('maps domain scores to palace scores correctly', () async {
      final userId = 'user-palace-1';
      final now = DateTime.now();

      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              latestDomainScores: drift.Value(
                '{"Tubuh":8.0,"Keuangan":3.0,"Hubungan":9.0,"Emosi":4.0,"Karir":7.0,"Rekreasi":6.0}',
              ),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final dashboardData = await container.read(dashboardDataProvider.future);
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      // Verify palace mapping
      expect(cultivation.palaceScores[CultivationPalace.body], equals(8.0));
      expect(
        cultivation.palaceScores[CultivationPalace.resource],
        equals(3.0),
      );
      expect(cultivation.palaceScores[CultivationPalace.bond], equals(9.0));
      expect(
        cultivation.palaceScores[CultivationPalace.heartSea],
        equals(4.0),
      );
      expect(cultivation.palaceScores[CultivationPalace.craft], equals(7.0));
      expect(cultivation.palaceScores[CultivationPalace.joy], equals(6.0));
    });

    test('detects lowest palace correctly', () async {
      final userId = 'user-lowest-1';
      final now = DateTime.now();

      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              latestDomainScores: drift.Value(
                '{"Tubuh":8.0,"Keuangan":2.0,"Hubungan":7.0,"Emosi":6.0,"Karir":5.0,"Rekreasi":4.0}',
              ),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final dashboardData = await container.read(dashboardDataProvider.future);
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      expect(
        cultivation.getLowestPalace(),
        equals(CultivationPalace.resource),
      );
    });

    test('determines season from support mode', () async {
      final userId = 'user-season-1';
      final now = DateTime.now();

      // User in recovery mode
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              supportMode: const drift.Value('Recovery'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final dashboardData = await container.read(dashboardDataProvider.future);
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      expect(cultivation.season, equals(CultivationSeason.recovery));
    });

    test('calculates qi level from canopy load', () async {
      final userId = 'user-qi-1';
      final now = DateTime.now();

      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              canopyLoadCapacity: const drift.Value(10),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Add habits with known friction and energy
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'habit-qi-1',
              userId: userId,
              title: 'Light Practice',
              initiationFriction: const drift.Value(2),
              energyCost: const drift.Value(2),
              createdAt: now,
            ),
          );

      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'habit-qi-2',
              userId: userId,
              title: 'Heavy Practice',
              initiationFriction: const drift.Value(3),
              energyCost: const drift.Value(3),
              createdAt: now,
            ),
          );

      final dashboardData = await container.read(dashboardDataProvider.future);
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      // Total load = (2+2) + (3+3) = 10
      // Capacity = 10
      // Qi level should reflect this load
      expect(cultivation.qiLevel, inInclusiveRange(0.0, 1.0));
    });

    test('realm increases with cumulative days and signals', () async {
      final userId = 'user-realm-1';
      final now = DateTime.now();

      // Early stage profile (no values, low days)
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              createdAt: now,
              updatedAt: now,
            ),
          );

      var dashboardData = await container.read(dashboardDataProvider.future);
      var cultivation = CultivationLayer.fromDashboard(dashboardData);

      final earlyRealm = cultivation.realm;
      expect(earlyRealm, inInclusiveRange(1, 3)); // Should be early realm

      // Simulate progression: add core values and recovery history
      await db.update(db.userProfiles).replace(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              coreValues: const drift.Value('Integrity, Growth, Balance'),
              recoveryEndDate: drift.Value(now.subtract(const Duration(days: 30))),
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Add consistent habits
      await db.into(db.habits).insert(
            HabitsCompanion.insert(
              habitId: 'habit-realm-1',
              userId: userId,
              title: 'Consistent Practice',
              completionRate90d: const drift.Value(0.85),
              createdAt: now,
            ),
          );

      // Override cumulative days to simulate progression
      container = ProviderContainer(
        overrides: [
          dbProvider.overrideWithValue(db),
          devCumulativeDaysOverrideProvider.overrideWith((ref) => 200),
        ],
      );

      dashboardData = await container.read(dashboardDataProvider.future);
      cultivation = CultivationLayer.fromDashboard(dashboardData);

      final advancedRealm = cultivation.realm;

      // With more signals and days, realm should be higher
      expect(advancedRealm, greaterThanOrEqualTo(earlyRealm));
    });

    test('detects quiet integration after recovery', () async {
      final userId = 'user-integration-1';
      final now = DateTime.now();

      // User just finished recovery 3 days ago
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              recoveryEndDate: drift.Value(now.subtract(const Duration(days: 3))),
              supportMode: const drift.Value('Normal'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final dashboardData = await container.read(dashboardDataProvider.future);
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      expect(cultivation.season, equals(CultivationSeason.quietIntegration));
    });

    test('detects overload state when qi level is low', () async {
      final userId = 'user-overload-1';
      final now = DateTime.now();

      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              canopyLoadCapacity: const drift.Value(5), // Low capacity
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Add many high-friction habits
      for (var i = 0; i < 5; i++) {
        await db.into(db.habits).insert(
              HabitsCompanion.insert(
                habitId: 'habit-overload-$i',
                userId: userId,
                title: 'Heavy Practice $i',
                initiationFriction: const drift.Value(4),
                energyCost: const drift.Value(4),
                createdAt: now,
              ),
            );
      }

      final dashboardData = await container.read(dashboardDataProvider.future);
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      expect(cultivation.isOverloaded, isTrue);
    });

    test('checks balance across palaces', () async {
      final userId = 'user-balance-1';
      final now = DateTime.now();

      // Balanced profile
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              latestDomainScores: drift.Value(
                '{"Tubuh":6.0,"Keuangan":6.5,"Hubungan":6.2,"Emosi":6.8,"Karir":6.3,"Rekreasi":6.5}',
              ),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final dashboardData = await container.read(dashboardDataProvider.future);
      final cultivation = CultivationLayer.fromDashboard(dashboardData);

      expect(cultivation.isBalanced, isTrue);
    });
  });

  group('CultivationProvider', () {
    test('provides cultivation layer from dashboard data', () async {
      final userId = 'user-provider-1';
      final now = DateTime.now();

      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              userId: userId,
              ageBand: '25-35',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Wait for dashboard to load first
      await container.read(dashboardDataProvider.future);

      // Now cultivation provider should have data
      final cultivationAsync = container.read(cultivationProvider);

      expect(
        cultivationAsync,
        isA<AsyncValue<CultivationLayer>>(),
      );

      cultivationAsync.when(
        data: (cultivation) {
          expect(cultivation, isA<CultivationLayer>());
        },
        loading: () => fail('Should have data'),
        error: (e, s) => fail('Should not error: $e'),
      );
    });

    test('language level defaults to hybrid', () {
      final languageLevel = container.read(cultivationLanguageLevelProvider);
      expect(languageLevel, equals(CultivationLanguageLevel.hybrid));
    });

    test('language level can be changed', () {
      final notifier = container.read(cultivationLanguageLevelProvider.notifier);
      
      notifier.state = CultivationLanguageLevel.full;
      
      final languageLevel = container.read(cultivationLanguageLevelProvider);
      expect(languageLevel, equals(CultivationLanguageLevel.full));
    });
  });
}
