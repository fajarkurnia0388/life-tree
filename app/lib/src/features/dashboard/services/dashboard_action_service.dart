import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../core/domain/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local_db/database.dart';

class DashboardActionService {
  final AppDatabase db;
  DashboardActionService(this.db);

  Future<void> updateUserSkin(String userId, String skinId) async {
    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        selectedSkin: drift.Value(skinId),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> purchaseUserSkin(String userId, String updatedUnlockedSkins, String skinId) async {
    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        unlockedSkins: drift.Value(updatedUnlockedSkins),
        selectedSkin: drift.Value(skinId),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateThemeMode(String userId, String themeMode) async {
    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        themeMode: drift.Value(themeMode),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> toggleCircadianTheme(String userId, bool enabled) async {
    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        circadianEnabled: drift.Value(enabled),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> toggleSupportMode(String userId, String mode) async {
    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        supportMode: drift.Value(mode),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> endRecoveryMode(String userId) async {
    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        supportMode: const drift.Value('Normal'),
        recoveryEndDate: const drift.Value(null),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteHabit(String habitId) async {
    await (db.update(db.habits)
          ..where((tbl) => tbl.habitId.equals(habitId)))
        .write(
      HabitsCompanion(
        deletedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> restoreHabit(String habitId) async {
    await (db.update(db.habits)
          ..where((tbl) => tbl.habitId.equals(habitId)))
        .write(
      HabitsCompanion(
        deletedAt: const drift.Value(null),
      ),
    );
  }

  Future<void> toggleDeveloperMode(String userId, bool enabled) async {
    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .write(
      UserProfilesCompanion(
        isDeveloperMode: drift.Value(enabled),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> archiveHabit(String habitId) async {
    await (db.update(db.habits)
          ..where((tbl) => tbl.habitId.equals(habitId)))
        .write(
      HabitsCompanion(
        archivedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> resetAllUserData() async {
    try {
      final habits = await db.select(db.habits).get();
      for (final habit in habits) {
        await NotificationService.cancel(habit.habitId.hashCode.abs() % 100000);
      }
    } catch (_) {}
    await db.delete(db.habitLogs).go();
    await db.delete(db.habits).go();
    await db.delete(db.journalEntries).go();
    await db.delete(db.thinkingCanvasSessions).go();
    await db.delete(db.weeklyPulses).go();
    await db.delete(db.decisionEntries).go();
    await db.delete(db.lifeAudits).go();
    await db.delete(db.consentLogs).go();
    await db.delete(db.reminderPreferences).go();
    await db.delete(db.userProfiles).go();
    await db.delete(db.wellnessPromptLogs).go();
  }

  Future<Map<String, dynamic>> exportAllUserData(String userId) async {
    final profile = await (db.select(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
    if (profile == null) return const {};

    final habits = await (db.select(db.habits)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull()))
        .get();
    final habitIds = habits.map((h) => h.habitId).toList();
    final habitLogs = habitIds.isEmpty
        ? <HabitLog>[]
        : await (db.select(db.habitLogs)
              ..where((tbl) => tbl.habitId.isIn(habitIds) & tbl.deletedAt.isNull()))
            .get();
    final journalEntries = await (db.select(db.journalEntries)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull()))
        .get();
    final weeklyPulses = await (db.select(db.weeklyPulses)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull()))
        .get();

    return {
      'export_date': DateTime.now().toIso8601String(),
      'profile': {
        'userId': profile.userId,
        'ageBand': profile.ageBand,
        'supportMode': profile.supportMode,
        'timezone': profile.timezone,
      },
      'habits': habits.map((h) => h.toJson()).toList(),
      'habitLogs': habitLogs.map((l) => l.toJson()).toList(),
      'journalEntries': journalEntries.map((e) => e.toJson()).toList(),
      'weeklyPulses': weeklyPulses.map((p) => p.toJson()).toList(),
    };
  }
}

final dashboardActionServiceProvider = Provider<DashboardActionService>((ref) {
  return DashboardActionService(ref.watch(dbProvider));
});
