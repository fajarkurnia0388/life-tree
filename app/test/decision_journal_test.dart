import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/core/providers/user_profile_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/decision_journal/decision_journal_view.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    
    final userProfile = UserProfile(
      userId: 'user-1',
      ageBand: '25-34',
      supportMode: 'Normal',
      engagementState: 'Active',
      timezone: 'Asia/Jakarta',
      weekStartDay: 1,
      latestDomainScores: '{}',
      canopyLoadCapacity: 10,
      wellnessDisclaimerAcknowledged: true,
      selectedSkin: 'Default',
      unlockedSkins: 'Default',
      securityLevel: 'Local',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      themeMode: 'System',
      circadianEnabled: false,
      isDeveloperMode: false,
      cultivationThemeEnabled: true,
      vocabularyLevel: 'mortal',
    );

    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
        userProfileProvider.overrideWith((ref) => Stream.value(userProfile)),
      ],
    );
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: 'user-1',
            ageBand: '25-34',
            supportMode: const drift.Value('Normal'),
            engagementState: const drift.Value('Active'),
            timezone: const drift.Value('Asia/Jakarta'),
            weekStartDay: const drift.Value(1),
            latestDomainScores: const drift.Value('{}'),
            canopyLoadCapacity: const drift.Value(10),
            wellnessDisclaimerAcknowledged: const drift.Value(true),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  Future<List<DecisionEntry>> _waitForEntries(ProviderContainer container) async {
    List<DecisionEntry>? result;
    final sub = container.listen(
      decisionListProvider,
      (prev, next) {
        next.whenOrNull(data: (list) {
          if (list.isNotEmpty) {
            result = list;
          }
        });
      },
      fireImmediately: true,
    );

    for (int i = 0; i < 100 && result == null; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    sub.close();
    return result ?? [];
  }

  test('Decision journal stream provider watches entries correctly', () async {
    final now = DateTime.now();

    // 1. Add decision entry
    await db.into(db.decisionEntries).insert(
          DecisionEntriesCompanion.insert(
            decisionId: 'decision-1',
            userId: 'user-1',
            title: 'Beli laptop baru',
            description: 'Apakah harus beli Macbook Pro?',
            options: '["Macbook Pro", "Asus ROG"]',
            assumptions: '["Macbook awet", "ROG kuat game"]',
            expectations: 'Macbook awet 5 tahun',
            reviewPeriodDays: const drift.Value(90),
            decisionDate: now,
            reviewDate: now.add(const Duration(days: 90)),
            isReviewed: const drift.Value(false),
          ),
        );

    // 2. Read stream using listener helper
    final list = await _waitForEntries(container);
    expect(list.length, 1);
    expect(list.first.title, 'Beli laptop baru');
  });

  test('Decision entry confidenceScore stores and retrieves correctly', () async {
    final now = DateTime.now();

    await db.into(db.decisionEntries).insert(
          DecisionEntriesCompanion.insert(
            decisionId: 'decision-2',
            userId: 'user-1',
            title: 'Keputusan Karir',
            description: 'Apakah pindah divisi?',
            options: '["Pindah", "Tetap"]',
            assumptions: '["Divisi baru seru"]',
            expectations: 'Karir berkembang',
            reviewPeriodDays: const drift.Value(90),
            decisionDate: now,
            reviewDate: now.add(const Duration(days: 90)),
            isReviewed: const drift.Value(false),
            confidenceScore: const drift.Value(75),
          ),
        );

    final list = await _waitForEntries(container);
    final careerDecision = list.firstWhere((d) => d.decisionId == 'decision-2');
    expect(careerDecision.confidenceScore, 75);
  });
}
