import 'package:daoji/src/data/local_db/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void _createVersion3Schema(Database db) {
  db.execute('''
    CREATE TABLE user_profiles (
      user_id TEXT NOT NULL PRIMARY KEY,
      selected_skin TEXT NOT NULL DEFAULT 'Default',
      unlocked_skins TEXT NOT NULL DEFAULT 'Default',
      theme_mode TEXT NOT NULL DEFAULT 'System'
    )
  ''');
  db.execute('''
    CREATE TABLE habits (
      habit_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'Active',
      domain_tag TEXT NULL,
      deleted_at INTEGER NULL
    )
  ''');
  db.execute('''
    CREATE TABLE habit_logs (
      log_id TEXT NOT NULL PRIMARY KEY,
      habit_id TEXT NOT NULL,
      date INTEGER NOT NULL,
      status TEXT NOT NULL,
      deleted_at INTEGER NULL
    )
  ''');
  db.execute('''
    CREATE TABLE journal_entries (
      entry_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      date INTEGER NOT NULL,
      mood_score INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE thinking_canvas_sessions (
      session_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      method_key TEXT NOT NULL,
      created_at INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE weekly_pulses (
      pulse_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      domain_tag TEXT NOT NULL,
      week_start_date INTEGER NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE life_audits (
      audit_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE consent_logs (
      consent_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      consent_type TEXT NOT NULL
    )
  ''');
  db.execute('''
    CREATE TABLE reminder_preferences (
      habit_id TEXT NOT NULL PRIMARY KEY
    )
  ''');
  db.execute('''
    CREATE TABLE wellness_prompt_logs (
      prompt_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      prompted_at INTEGER NOT NULL
    )
  ''');
  db.execute('PRAGMA user_version = 3');
}

void _upgradeFixtureToVersion10(Database db) {
  _createVersion3Schema(db);
  db.execute('ALTER TABLE user_profiles ADD COLUMN core_values TEXT');
  db.execute(
    'ALTER TABLE user_profiles ADD COLUMN is_developer_mode INTEGER NOT NULL DEFAULT 0',
  );
  db.execute('ALTER TABLE user_profiles ADD COLUMN recovery_end_date INTEGER');
  db.execute('ALTER TABLE user_profiles ADD COLUMN revealed_value_scores TEXT');
  db.execute(
    'ALTER TABLE user_profiles ADD COLUMN revealed_value_last_updated_at INTEGER',
  );
  db.execute(
    'ALTER TABLE user_profiles ADD COLUMN cultivation_theme_enabled INTEGER NOT NULL DEFAULT 1',
  );
  db.execute('ALTER TABLE habits ADD COLUMN goal_tag TEXT');
  db.execute('''
    CREATE TABLE decision_entries (
      decision_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      review_date INTEGER NOT NULL,
      is_reviewed INTEGER NOT NULL DEFAULT 0,
      review_period_days INTEGER NOT NULL DEFAULT 90
    )
  ''');
  db.execute('''
    CREATE TABLE marketplace_templates (
      template_id TEXT NOT NULL PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      domain_tag TEXT,
      creator_pen_name TEXT NOT NULL,
      ratings_sum INTEGER NOT NULL,
      ratings_count INTEGER NOT NULL,
      downloads_count INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      friction INTEGER,
      energy INTEGER,
      impact INTEGER,
      mva_duration INTEGER
    )
  ''');
  db.execute('''
    INSERT INTO marketplace_templates (
      template_id, title, description, creator_pen_name,
      ratings_sum, ratings_count, downloads_count, created_at,
      friction, energy, impact, mva_duration
    ) VALUES ('legacy', 'Legacy', 'Legacy template', 'Local', 0, 0, 0, 0, 2, 3, 4, 5)
  ''');
  db.execute('''
    CREATE TABLE value_dilemma_responses (
      response_id TEXT NOT NULL PRIMARY KEY,
      user_id TEXT NOT NULL,
      answered_at INTEGER NOT NULL,
      response_reason TEXT
    )
  ''');
  db.execute('PRAGMA user_version = 10');
}

Future<Set<String>> _columns(AppDatabase db, String table) async {
  final rows = await db.customSelect('PRAGMA table_info("$table")').get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

void main() {
  test('legacy marketplace columns migrate to typed metadata', () async {
    final executor = NativeDatabase.memory(setup: _upgradeFixtureToVersion10);
    final db = AppDatabase.forTesting(executor);
    addTearDown(db.close);

    await db.customSelect('SELECT 1').get();

    final row = await db
        .customSelect(
          'SELECT template_type, metadata FROM marketplace_templates '
          "WHERE template_id = 'legacy'",
        )
        .getSingle();
    expect(row.read<String>('template_type'), 'habit');
    expect(row.read<String?>('metadata'), contains('"mvaDuration":5'));
  });

  test('schema v3 upgrades to v17 without duplicate-column failures', () async {
    final executor = NativeDatabase.memory(setup: _createVersion3Schema);
    final db = AppDatabase.forTesting(executor);
    addTearDown(db.close);

    await db.customSelect('SELECT 1').get();

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 17);
    expect(
      await _columns(db, 'decision_entries'),
      containsAll(['review_period_days', 'confidence_score']),
    );
    expect(
      await _columns(db, 'marketplace_templates'),
      containsAll(['template_type', 'metadata']),
    );
    expect(
      await _columns(db, 'value_dilemma_responses'),
      contains('response_reason'),
    );
    expect(
      await _columns(db, 'user_profiles'),
      containsAll(['vocabulary_level', 'circadian_enabled']),
    );
  });

  test('fresh install and migrated v17 have same indexes', () async {
    final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
    await freshDb.customSelect('SELECT 1').get();
    
    final migratedDb = AppDatabase.forTesting(NativeDatabase.memory(setup: _createVersion3Schema));
    await migratedDb.customSelect('SELECT 1').get();
    
    final freshIndexes = await freshDb.customSelect(
      "SELECT name, sql FROM sqlite_master WHERE type='index' AND name LIKE 'uq_%'"
    ).get();
    final migratedIndexes = await migratedDb.customSelect(
      "SELECT name, sql FROM sqlite_master WHERE type='index' AND name LIKE 'uq_%'"
    ).get();
    
    expect(freshIndexes.length, migratedIndexes.length);
    expect(freshIndexes.map((r) => r.read<String>('name')).toSet(),
           migratedIndexes.map((r) => r.read<String>('name')).toSet());
    
    await freshDb.close();
    await migratedDb.close();
  });

  test('cascade delete habit removes logs and reminders', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    
    // Insert habit
    await db.customStatement("INSERT INTO habits (habit_id, user_id, title, created_at) VALUES ('h1', 'u1', 'Test Habit', 123456)");
    // Insert log
    await db.customStatement("INSERT INTO habit_logs (log_id, habit_id, date, status) VALUES ('l1', 'h1', 123456, 'Done')");
    // Insert reminder
    await db.customStatement("INSERT INTO reminder_preferences (habit_id, reminder_enabled) VALUES ('h1', 1)");
    
    // Check they exist
    final logsBefore = await db.customSelect("SELECT * FROM habit_logs").get();
    final remindersBefore = await db.customSelect("SELECT * FROM reminder_preferences").get();
    expect(logsBefore.length, 1);
    expect(remindersBefore.length, 1);
    
    // Delete habit
    await db.customStatement("DELETE FROM habits WHERE habit_id = 'h1'");
    
    // Verify logs and reminders are deleted due to CASCADE
    final logsAfter = await db.customSelect("SELECT * FROM habit_logs").get();
    final remindersAfter = await db.customSelect("SELECT * FROM reminder_preferences").get();
    expect(logsAfter, isEmpty);
    expect(remindersAfter, isEmpty);
    
    await db.close();
  });
}
