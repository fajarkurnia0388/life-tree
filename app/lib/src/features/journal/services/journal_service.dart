import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../core/providers/db_provider.dart';
import '../../../core/domain/app_constants.dart';
import '../../../data/local_db/database.dart';

class JournalService {
  final AppDatabase db;
  JournalService(this.db);

  Stream<List<JournalEntry>> watchJournalEntries(String userId) {
    return (db.select(db.journalEntries)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => drift.OrderingTerm(
              expression: tbl.date,
              mode: drift.OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<List<JournalEntry>> getRecentJournalEntries(
    String userId,
    DateTime since,
  ) async {
    return await (db.select(db.journalEntries)..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.deletedAt.isNull() &
              tbl.date.isBiggerOrEqualValue(since),
        ))
        .get();
  }

  Future<JournalEntry?> getTodayJournalEntry(String userId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return await (db.select(db.journalEntries)..where(
          (tbl) =>
              tbl.userId.equals(userId) &
              tbl.date.equals(todayStart) &
              tbl.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  Future<void> saveMoodScore({
    required String userId,
    required int score,
  }) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final existing =
        await (db.select(db.journalEntries)..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.date.equals(todayStart) &
                  tbl.deletedAt.isNull(),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.journalEntries)
            ..where((tbl) => tbl.entryId.equals(existing.entryId)))
          .write(JournalEntriesCompanion(moodScore: drift.Value(score)));
    } else {
      await db
          .into(db.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              entryId: const Uuid().v4(),
              userId: userId,
              date: todayStart,
              moodScore: score,
              createdAt: now,
            ),
          );
    }
  }

  Future<void> saveJournalEntry({
    required String userId,
    required int moodScore,
    required String keywordText,
    required String textContent,
    required String gratitudeText,
    required bool showDeepReflection,
  }) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final entryType = showDeepReflection ? 'Deep' : 'Lite';

    final existing =
        await (db.select(db.journalEntries)..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.date.equals(todayStart) &
                  tbl.deletedAt.isNull(),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (db.update(
        db.journalEntries,
      )..where((tbl) => tbl.entryId.equals(existing.entryId))).write(
        JournalEntriesCompanion(
          moodScore: drift.Value(moodScore),
          keyword: drift.Value(keywordText.isEmpty ? null : keywordText),
          textContent: drift.Value(textContent),
          gratitudeText: drift.Value(gratitudeText),
          entryType: drift.Value(entryType),
        ),
      );
    } else {
      await db
          .into(db.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              entryId: const Uuid().v4(),
              userId: userId,
              date: todayStart,
              moodScore: moodScore,
              keyword: drift.Value(keywordText.isEmpty ? null : keywordText),
              textContent: drift.Value(textContent),
              gratitudeText: drift.Value(gratitudeText),
              entryType: drift.Value(entryType),
              createdAt: now,
            ),
          );
    }
  }

  Future<bool> checkConsecutiveLowMood(String userId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final dayH0 = todayStart;
    final dayH1 = todayStart.subtract(const Duration(days: 1));
    final dayH2 = todayStart.subtract(const Duration(days: 2));

    final consecutiveEntries =
        await (db.select(db.journalEntries)..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.date.isIn([dayH0, dayH1, dayH2]) &
                  tbl.deletedAt.isNull(),
            ))
            .get();

    final moodByDate = {
      for (final e in consecutiveEntries) e.date: e.moodScore,
    };

    return moodByDate.containsKey(dayH0) &&
        moodByDate.containsKey(dayH1) &&
        moodByDate.containsKey(dayH2) &&
        moodByDate[dayH0]! <= 2 &&
        moodByDate[dayH1]! <= 2 &&
        moodByDate[dayH2]! <= 2;
  }

  Future<bool> logWellnessPrompt(String userId) async {
    final profile = await (db.select(
      db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
    if (profile == null) return false;

    final now = DateTime.now();
    final lastPrompt = profile.lastWellnessPromptAt;
    if (lastPrompt != null && now.difference(lastPrompt).inHours < 24) {
      return false;
    }

    await db.transaction(() async {
      await db
          .into(db.wellnessPromptLogs)
          .insert(
            WellnessPromptLogsCompanion.insert(
              promptId: const Uuid().v4(),
              userId: userId,
              triggerType: WellnessPromptTrigger.lowMood,
              promptedAt: now,
            ),
          );
      await (db.update(
        db.userProfiles,
      )..where((tbl) => tbl.userId.equals(userId))).write(
        UserProfilesCompanion(
          lastWellnessPromptAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );
    });
    return true;
  }
}

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(ref.watch(dbProvider));
});
