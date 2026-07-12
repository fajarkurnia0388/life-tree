import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/journal/services/journal_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late JournalService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = JournalService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('saveMoodScore then saveJournalEntry on the same day updates the same row without crash', () async {
    const userId = 'user-1';

    // 1. Save mood score
    await service.saveMoodScore(userId: userId, score: 3);

    // Verify it was saved
    var entries = await db.select(db.journalEntries).get();
    expect(entries.length, 1);
    expect(entries.first.moodScore, 3);
    expect(entries.first.entryType, 'Lite');

    // 2. Save journal entry on the same day
    await service.saveJournalEntry(
      userId: userId,
      moodScore: 4,
      keywordText: 'Reflective',
      textContent: 'Had a good day.',
      gratitudeText: 'Grateful for coding.',
      showDeepReflection: true,
    );

    // Verify same entry was updated, no new row was inserted
    entries = await db.select(db.journalEntries).get();
    expect(entries.length, 1);
    expect(entries.first.moodScore, 4);
    expect(entries.first.keyword, 'Reflective');
    expect(entries.first.textContent, 'Had a good day.');
    expect(entries.first.gratitudeText, 'Grateful for coding.');
    expect(entries.first.entryType, 'Deep');
  });

  test('multiple saveMoodScore calls on the same day updates the entry', () async {
    const userId = 'user-2';

    await service.saveMoodScore(userId: userId, score: 2);
    await service.saveMoodScore(userId: userId, score: 5);

    final entries = await db.select(db.journalEntries).get();
    expect(entries.length, 1);
    expect(entries.first.moodScore, 5);
  });
}
