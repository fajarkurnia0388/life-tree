import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/providers/db_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local_db/database.dart';

class DashboardActionService {
  final AppDatabase db;
  DashboardActionService(this.db);

  Future<void> updateUserSkin(String userId, String skinId) async {
    await (db.update(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        selectedSkin: drift.Value(skinId),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// RESIDUAL NAME: not a store purchase.
  /// Locally unlocks a tree skin in SQLite. No money, no IAP, no receipt.
  /// Prefer [unlockUserSkinLocally] mentally; keep name for call-site compatibility.
  Future<void> purchaseUserSkin(
    String userId,
    String updatedUnlockedSkins,
    String skinId,
  ) async {
    await (db.update(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        unlockedSkins: drift.Value(updatedUnlockedSkins),
        selectedSkin: drift.Value(skinId),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateThemeMode(String userId, String themeMode) async {
    await (db.update(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        themeMode: drift.Value(themeMode),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> toggleCircadianTheme(String userId, bool enabled) async {
    await (db.update(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        circadianEnabled: drift.Value(enabled),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> toggleSupportMode(String userId, String mode) async {
    await (db.update(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        supportMode: drift.Value(mode),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> endRecoveryMode(String userId) async {
    await (db.update(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        supportMode: const drift.Value('Normal'),
        recoveryEndDate: const drift.Value(null),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteHabit(String habitId) async {
    await (db.update(db.habits)..where((tbl) => tbl.habitId.equals(habitId)))
        .write(HabitsCompanion(deletedAt: drift.Value(DateTime.now())));
  }

  Future<void> restoreHabit(String habitId) async {
    await (db.update(db.habits)..where((tbl) => tbl.habitId.equals(habitId)))
        .write(const HabitsCompanion(deletedAt: drift.Value(null)));
  }

  Future<void> toggleDeveloperMode(String userId, bool enabled) async {
    await (db.update(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        isDeveloperMode: drift.Value(enabled),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> archiveHabit(String habitId) async {
    await (db.update(db.habits)..where((tbl) => tbl.habitId.equals(habitId)))
        .write(HabitsCompanion(archivedAt: drift.Value(DateTime.now())));
  }

  Future<void> resetAllUserData() async {
    final habits = await db.select(db.habits).get();
    for (final habit in habits) {
      try {
        await NotificationService.cancelHabit(habit.habitId);
      } catch (error) {
        debugPrint('Failed to cancel reminder for ${habit.habitId}: $error');
      }
    }

    await db.transaction(() async {
      await db.delete(db.habitLogs).go();
      await db.delete(db.reminderPreferences).go();
      await db.delete(db.habits).go();
      await db.delete(db.journalEntries).go();
      await db.delete(db.thinkingCanvasSessions).go();
      await db.delete(db.weeklyPulses).go();
      await db.delete(db.decisionEntries).go();
      await db.delete(db.lifeAudits).go();
      await db.delete(db.consentLogs).go();
      await db.delete(db.wellnessPromptLogs).go();
      await db.delete(db.valueDilemmaResponses).go();
      await db.delete(db.marketplaceTemplates).go();
      await db.delete(db.userProfiles).go();
    });
  }

  Future<Map<String, dynamic>> exportAllUserData(String userId) async {
    final profile = await (db.select(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
    if (profile == null) return const {};

    final habits = await (db.select(
      db.habits,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final habitIds = habits.map((habit) => habit.habitId).toList();
    final habitLogs = habitIds.isEmpty
        ? <HabitLog>[]
        : await (db.select(
            db.habitLogs,
          )..where((tbl) => tbl.habitId.isIn(habitIds))).get();
    final reminders = habitIds.isEmpty
        ? <ReminderPreference>[]
        : await (db.select(
            db.reminderPreferences,
          )..where((tbl) => tbl.habitId.isIn(habitIds))).get();
    final journalEntries = await (db.select(
      db.journalEntries,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final weeklyPulses = await (db.select(
      db.weeklyPulses,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final lifeAudits = await (db.select(
      db.lifeAudits,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final canvasSessions = await (db.select(
      db.thinkingCanvasSessions,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final decisions = await (db.select(
      db.decisionEntries,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final consentLogs = await (db.select(
      db.consentLogs,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final wellnessLogs = await (db.select(
      db.wellnessPromptLogs,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final valueResponses = await (db.select(
      db.valueDilemmaResponses,
    )..where((tbl) => tbl.userId.equals(userId))).get();
    final marketplaceRecords = await db.select(db.marketplaceTemplates).get();

    return {
      'schema_version': 1,
      'database_schema_version': db.schemaVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'profile': profile.toJson(),
      'habits': habits.map((row) => row.toJson()).toList(),
      'habit_logs': habitLogs.map((row) => row.toJson()).toList(),
      'reminder_preferences': reminders.map((row) => row.toJson()).toList(),
      'journal_entries': journalEntries.map((row) => row.toJson()).toList(),
      'weekly_pulses': weeklyPulses.map((row) => row.toJson()).toList(),
      'life_audits': lifeAudits.map((row) => row.toJson()).toList(),
      'thinking_canvas_sessions': canvasSessions
          .map((row) => row.toJson())
          .toList(),
      'decision_entries': decisions.map((row) => row.toJson()).toList(),
      'consent_logs': consentLogs.map((row) => row.toJson()).toList(),
      'wellness_prompt_logs': wellnessLogs.map((row) => row.toJson()).toList(),
      'value_dilemma_responses': valueResponses
          .map((row) => row.toJson())
          .toList(),
      'local_marketplace_records': marketplaceRecords
          .map((row) => row.toJson())
          .toList(),
    };
  }
}

final dashboardActionServiceProvider = Provider<DashboardActionService>((ref) {
  return DashboardActionService(ref.watch(dbProvider));
});
