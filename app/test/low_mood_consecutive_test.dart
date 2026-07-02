import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:daoji/src/data/local_db/database.dart';

// Pure logic function extracted from journal_lite_view.dart for testability.
// Returns true if user has had moodScore <= 2 for 3 strict consecutive calendar days.
Future<bool> hasConsecutiveLowMood(AppDatabase db, String userId) async {
  final now = DateTime.now();
  final dayH0 = DateTime(now.year, now.month, now.day);
  final dayH1 = dayH0.subtract(const Duration(days: 1));
  final dayH2 = dayH0.subtract(const Duration(days: 2));

  final consecutiveEntries = await (db.select(db.journalEntries)
        ..where((tbl) =>
            tbl.userId.equals(userId) &
            tbl.date.isIn([dayH0, dayH1, dayH2])))
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

void main() {
  late AppDatabase db;
  final userId = 'test-user';

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper untuk insert jurnal pada tanggal tertentu
  Future<void> insertJournal(DateTime date, int moodScore) async {
    await db.into(db.journalEntries).insert(
          JournalEntriesCompanion.insert(
            entryId: '${date.toIso8601String()}-$moodScore',
            userId: userId,
            date: DateTime(date.year, date.month, date.day),
            moodScore: moodScore,
            createdAt: DateTime.now(),
          ),
        );
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final twoDaysAgo = today.subtract(const Duration(days: 2));
  final threeDaysAgo = today.subtract(const Duration(days: 3));

  group('Consecutive Low Mood Detection', () {
    test('Harus trigger: mood rendah selama 3 hari berturut-turut (H-2, H-1, H0 semua <= 2)', () async {
      await insertJournal(twoDaysAgo, 1);
      await insertJournal(yesterday, 2);
      await insertJournal(today, 1);

      final result = await hasConsecutiveLowMood(db, userId);
      expect(result, isTrue);
    });

    test('Tidak trigger: 3 entri mood rendah tapi tidak berurutan (ada gap)', () async {
      // 3 days ago and today are low, but yesterday is missing = not consecutive
      await insertJournal(threeDaysAgo, 1);
      await insertJournal(twoDaysAgo, 1);
      await insertJournal(today, 1); // yesterday is missing
      // NOTE: yesterday (H-1) has no entry

      final result = await hasConsecutiveLowMood(db, userId);
      expect(result, isFalse);
    });

    test('Tidak trigger: 3 hari berturut-turut tapi salah satu mood normal (> 2)', () async {
      await insertJournal(twoDaysAgo, 1);
      await insertJournal(yesterday, 3); // mood normal
      await insertJournal(today, 1);

      final result = await hasConsecutiveLowMood(db, userId);
      expect(result, isFalse);
    });

    test('Tidak trigger: hanya 2 hari berurutan mood rendah (kurang 1 hari)', () async {
      await insertJournal(yesterday, 2);
      await insertJournal(today, 1);

      final result = await hasConsecutiveLowMood(db, userId);
      expect(result, isFalse);
    });

    test('Tidak trigger: tidak ada entri jurnal sama sekali', () async {
      final result = await hasConsecutiveLowMood(db, userId);
      expect(result, isFalse);
    });

    test('Edge case: mood score tepat 2 (batas bawah) harus ter-detect', () async {
      await insertJournal(twoDaysAgo, 2);
      await insertJournal(yesterday, 2);
      await insertJournal(today, 2);

      final result = await hasConsecutiveLowMood(db, userId);
      expect(result, isTrue);
    });

    test('Edge case: mood score 3 (di atas batas) tidak boleh ter-detect', () async {
      await insertJournal(twoDaysAgo, 1);
      await insertJournal(yesterday, 1);
      await insertJournal(today, 3); // exactly at boundary

      final result = await hasConsecutiveLowMood(db, userId);
      expect(result, isFalse);
    });
  });
}
