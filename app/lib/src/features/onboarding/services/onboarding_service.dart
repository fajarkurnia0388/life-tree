import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';

class OnboardingService {
  final AppDatabase db;
  OnboardingService(this.db);

  Future<bool> isOnboardingCompleted() async {
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return false;
    return profiles.first.wellnessDisclaimerAcknowledged;
  }

  Future<void> completeOnboarding({
    required String userId,
    required String ageBand,
    required Map<String, double> domainScores,
    required bool cultivationThemeEnabled,
  }) async {
    final now = DateTime.now();

    final profile = UserProfilesCompanion.insert(
      userId: userId,
      ageBand: ageBand,
      supportMode: const drift.Value('Normal'),
      engagementState: const drift.Value('Active'),
      timezone: const drift.Value('Asia/Jakarta'),
      weekStartDay: const drift.Value(1),
      latestDomainScores: drift.Value(domainScores),
      canopyLoadCapacity: const drift.Value(10),
      wellnessDisclaimerAcknowledged: const drift.Value(true),
      cultivationThemeEnabled: drift.Value(cultivationThemeEnabled),
      vocabularyLevel: drift.Value(
        cultivationThemeEnabled ? 'earth' : 'mortal',
      ),
      unlockedSkins: const drift.Value('Default'),
      isDeveloperMode: const drift.Value(false),
      createdAt: now,
      updatedAt: now,
    );

    final audit = LifeAuditsCompanion.insert(
      auditId: const Uuid().v4(),
      userId: userId,
      domainScores: domainScores,
      timestamp: now,
    );

    final consent = ConsentLogsCompanion.insert(
      consentId: const Uuid().v4(),
      userId: userId,
      consentType: 'Wellness_Disclaimer',
      grantedAt: now,
      version: 'Wellness_v1.0',
    );

    await db.transaction(() async {
      await db.into(db.userProfiles).insert(profile);
      await db.into(db.lifeAudits).insert(audit);
      await db.into(db.consentLogs).insert(consent);
    });
  }
}

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService(ref.watch(dbProvider));
});
