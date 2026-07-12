import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/domain/app_constants.dart';

part 'database.g.dart';

@DataClassName('UserProfile')
class UserProfiles extends Table {
  TextColumn get userId => text()();
  TextColumn get ageBand => text()();
  TextColumn get supportMode =>
      text().withDefault(const Constant(SupportMode.normal))();
  TextColumn get engagementState =>
      text().withDefault(const Constant(HabitStatus.active))();
  TextColumn get timezone =>
      text().withDefault(const Constant('Asia/Jakarta'))();
  IntColumn get weekStartDay => integer().withDefault(const Constant(1))();
  TextColumn get latestDomainScores => text().nullable()(); // JSON string
  IntColumn get canopyLoadCapacity =>
      integer().withDefault(const Constant(10))();
  BoolColumn get wellnessDisclaimerAcknowledged =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastWellnessPushAt => dateTime().nullable()();
  DateTimeColumn get lastWellnessPromptAt => dateTime().nullable()();
  TextColumn get selectedSkin =>
      text().withDefault(const Constant('Default'))();
  TextColumn get unlockedSkins =>
      text().withDefault(const Constant('Default'))();
  TextColumn get securityLevel => text().withDefault(const Constant('Local'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get themeMode => text().withDefault(const Constant('System'))();
  BoolColumn get circadianEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get coreValues => text().nullable()();
  BoolColumn get isDeveloperMode =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get recoveryEndDate => dateTime().nullable()();
  TextColumn get revealedValueScores => text().nullable()();
  DateTimeColumn get revealedValueLastUpdatedAt => dateTime().nullable()();
  BoolColumn get cultivationThemeEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get vocabularyLevel =>
      text().withDefault(const Constant('daoStream'))();

  @override
  Set<Column> get primaryKey => {userId};
}

@DataClassName('LifeAudit')
class LifeAudits extends Table {
  TextColumn get auditId => text()();
  TextColumn get userId => text()();
  TextColumn get domainScores => text()(); // JSON string
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {auditId};
}

@DataClassName('WeeklyPulse')
class WeeklyPulses extends Table {
  TextColumn get pulseId => text()();
  TextColumn get userId => text()();
  TextColumn get domainTag => text()();
  IntColumn get score => integer()();
  TextColumn get reflectionText => text().nullable()();
  DateTimeColumn get weekStartDate => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {pulseId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, domainTag, weekStartDate},
  ];
}

@DataClassName('Habit')
class Habits extends Table {
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  TextColumn get domainTag => text().nullable()();
  TextColumn get title => text().withLength(max: 100)();
  TextColumn get status =>
      text().withDefault(const Constant(HabitStatus.active))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  TextColumn get frequency => text().withDefault(const Constant('Daily'))();
  TextColumn get scheduledDays =>
      text().nullable()(); // CSV: e.g. "1,3,5" (1=Monday ... 7=Sunday)
  IntColumn get initiationFriction =>
      integer().withDefault(const Constant(3))();
  IntColumn get originalFriction => integer().withDefault(const Constant(3))();
  IntColumn get energyCost => integer().withDefault(const Constant(3))();
  IntColumn get impactScore => integer().withDefault(const Constant(3))();
  IntColumn get lifetimeDoneCount => integer().withDefault(const Constant(0))();
  RealColumn get weightedDoneScore => real().withDefault(const Constant(0.0))();
  RealColumn get completionRate90d => real().nullable()();
  DateTimeColumn get lastDecayEvaluatedAt => dateTime().nullable()();
  IntColumn get mvaDurationMin => integer().withDefault(const Constant(2))();
  TextColumn get stackedToHabitId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get goalTag => text().nullable()();

  @override
  Set<Column> get primaryKey => {habitId};
}

@DataClassName('HabitLog')
class HabitLogs extends Table {
  TextColumn get logId => text()();
  TextColumn get habitId => text().references(Habits, #habitId, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status =>
      text()(); // 'Done', 'Missed', 'Skipped_Intentionally', 'Paused'
  TextColumn get frictionReasonSelected =>
      text().nullable()(); // 'Kurang_Waktu', 'Kelelahan', 'Lupa'
  IntColumn get durationTargetMin => integer().nullable()();
  IntColumn get durationActualMin => integer().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {logId};
}

@DataClassName('JournalEntry')
class JournalEntries extends Table {
  TextColumn get entryId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get moodScore => integer()();
  TextColumn get keyword => text().nullable()();
  TextColumn get textContent => text().nullable()();
  TextColumn get gratitudeText => text().nullable()();
  TextColumn get entryType =>
      text().withDefault(const Constant('Lite'))(); // 'Lite', 'Deep'
  TextColumn get conflictCopy => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entryId};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, date},
  ];
}

@DataClassName('ThinkingCanvasSession')
class ThinkingCanvasSessions extends Table {
  TextColumn get sessionId => text()();
  TextColumn get userId => text()();
  TextColumn get methodKey =>
      text()(); // 'MindDump', 'Brainstorming', 'Scoring', 'PMI', 'ReverseBrainstorming', 'Validation'
  BoolColumn get isDraft => boolean().withDefault(const Constant(true))();
  TextColumn get topic => text().nullable()();
  TextColumn get rawNotes => text().nullable()();
  TextColumn get summaryText => text().nullable()();
  BoolColumn get paperSession => boolean().withDefault(const Constant(true))();
  TextColumn get paperArtifactRef => text().nullable()();
  TextColumn get structuredOutput => text().nullable()(); // JSON string
  TextColumn get nextAction => text().nullable()();
  TextColumn get linkedHabitId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {sessionId};
}

@DataClassName('ConsentLog')
class ConsentLogs extends Table {
  TextColumn get consentId => text()();
  TextColumn get userId => text()();
  TextColumn get consentType =>
      text()(); // 'ToS', 'Privacy_Policy', 'Data_Processing', 'Wellness_Disclaimer'
  DateTimeColumn get grantedAt => dateTime()();
  TextColumn get version => text()();
  DateTimeColumn get revokedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {consentId};
}

@DataClassName('ReminderPreference')
class ReminderPreferences extends Table {
  TextColumn get habitId => text().references(Habits, #habitId, onDelete: KeyAction.cascade)();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get reminderTime => text().withDefault(const Constant('08:00'))();
  TextColumn get quietHoursStart =>
      text().withDefault(const Constant('22:00'))();
  TextColumn get quietHoursEnd => text().withDefault(const Constant('07:00'))();

  @override
  Set<Column> get primaryKey => {habitId};
}

@DataClassName('WellnessPromptLog')
class WellnessPromptLogs extends Table {
  TextColumn get promptId => text()();
  TextColumn get userId => text()();
  TextColumn get triggerType =>
      text()(); // Valid values: WellnessPromptTrigger.lowMood, .safetyCard, .weeklyPulse
  DateTimeColumn get promptedAt => dateTime()();
  TextColumn get userAction => text()
      .nullable()(); // 'Dismissed', 'Opened_Safety_Card', 'Recovery_Mode', 'Tapped_Hotline_CTA'

  @override
  Set<Column> get primaryKey => {promptId};
}

@DataClassName('DecisionEntry')
class DecisionEntries extends Table {
  TextColumn get decisionId => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get options => text()(); // JSON string
  TextColumn get assumptions => text()(); // JSON string
  TextColumn get expectations => text()(); // Text
  DateTimeColumn get decisionDate => dateTime()();
  DateTimeColumn get reviewDate => dateTime()();
  BoolColumn get isReviewed => boolean().withDefault(const Constant(false))();
  TextColumn get reviewReflection => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get reviewPeriodDays => integer().withDefault(const Constant(90))();
  IntColumn get confidenceScore => integer().nullable()();

  @override
  Set<Column> get primaryKey => {decisionId};
}

@DataClassName('MarketplaceTemplate')
class MarketplaceTemplates extends Table {
  TextColumn get templateId => text()();
  TextColumn get templateType => text()(); // 'habit' or 'core_value'
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get domainTag => text().nullable()();
  TextColumn get metadata =>
      text().nullable()(); // JSON: habit-specific or value-specific data
  TextColumn get creatorPenName => text()();
  IntColumn get ratingsSum => integer()();
  IntColumn get ratingsCount => integer()();
  IntColumn get downloadsCount => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {templateId};
}

@DataClassName('ValueDilemmaResponse')
class ValueDilemmaResponses extends Table {
  TextColumn get responseId => text()();
  TextColumn get userId => text()();
  TextColumn get dilemmaKey => text()();
  TextColumn get chosenValueTag => text().nullable()();
  TextColumn get chosenOptionLabel => text().nullable()();
  TextColumn get openTextResponse => text().nullable()();
  TextColumn get responseReason =>
      text().nullable()(); // Optional reason for choosing A/B/Both
  DateTimeColumn get answeredAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {responseId};
}

@DriftDatabase(
  tables: [
    UserProfiles,
    LifeAudits,
    WeeklyPulses,
    Habits,
    HabitLogs,
    JournalEntries,
    ThinkingCanvasSessions,
    ConsentLogs,
    ReminderPreferences,
    WellnessPromptLogs,
    DecisionEntries,
    MarketplaceTemplates,
    ValueDilemmaResponses,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  Future<int> countUniqueDoneDates(String userId) async {
    final result = await customSelect(
      "SELECT COUNT(DISTINCT date(hl.date, 'unixepoch')) AS cnt "
      "FROM habit_logs hl "
      "INNER JOIN habits h ON hl.habit_id = h.habit_id "
      "WHERE hl.status = ? AND hl.deleted_at IS NULL "
      "AND h.user_id = ? AND h.deleted_at IS NULL",
      variables: [
        const Variable<String>(HabitStatus.done),
        Variable<String>(userId),
      ],
      readsFrom: {habitLogs, habits},
    ).getSingle();
    return result.read<int>('cnt');
  }

  @override
  int get schemaVersion => 17;

  String _quoteIdentifier(String identifier) =>
      '"${identifier.replaceAll('"', '""')}"';

  Future<bool> _tableExists(String tableName) async {
    final row = await customSelect(
      "SELECT 1 AS present FROM sqlite_master "
      "WHERE type = 'table' AND name = ? LIMIT 1",
      variables: [Variable<String>(tableName)],
    ).getSingleOrNull();
    return row != null;
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    if (!await _tableExists(tableName)) return false;
    final rows = await customSelect(
      'PRAGMA table_info(${_quoteIdentifier(tableName)})',
    ).get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }

  Future<void> _createTableIfMissing(Migrator migrator, TableInfo table) async {
    if (!await _tableExists(table.actualTableName)) {
      await migrator.createTable(table);
    }
  }

  Future<void> _addColumnIfMissing(
    Migrator migrator,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    if (!await _columnExists(table.actualTableName, column.$name)) {
      await migrator.addColumn(table, column);
    }
  }

  Future<void> _ensureIndexes() async {
    final statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_habit_log_perf ON habit_logs (habit_id, date, status)',
      'CREATE INDEX IF NOT EXISTS idx_habit_log_desc ON habit_logs (habit_id, date DESC)',
      'CREATE INDEX IF NOT EXISTS idx_journal_entry_wellness ON journal_entries (user_id, date, mood_score)',
      'CREATE INDEX IF NOT EXISTS idx_thinking_canvas_history ON thinking_canvas_sessions (user_id, created_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_thinking_canvas_patterns ON thinking_canvas_sessions (user_id, method_key, created_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_habit_active ON habits (user_id, status, domain_tag)',
      'CREATE INDEX IF NOT EXISTS idx_weekly_pulse_ttl ON weekly_pulses (user_id, domain_tag, week_start_date DESC)',
      'CREATE INDEX IF NOT EXISTS idx_wellness_prompt_log_cap ON wellness_prompt_logs (user_id, prompted_at DESC)',
      'CREATE INDEX IF NOT EXISTS idx_consent_log_check ON consent_logs (user_id, consent_type)',
      'CREATE INDEX IF NOT EXISTS idx_decision_review ON decision_entries (user_id, review_date, is_reviewed)',
      'CREATE INDEX IF NOT EXISTS idx_value_dilemma_user ON value_dilemma_responses (user_id, answered_at DESC)',
      'CREATE UNIQUE INDEX IF NOT EXISTS uq_active_habit_log ON habit_logs(habit_id, date) WHERE deleted_at IS NULL',
    ];
    for (final statement in statements) {
      await customStatement(statement);
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // FIX: Only run migration logic when the database was actually upgraded
      if (details.hadUpgrade) {
        if (await _columnExists('user_profiles', 'circadian_enabled') &&
            await _columnExists('user_profiles', 'theme_mode')) {
          await customStatement(
            "UPDATE user_profiles SET circadian_enabled = 1, "
            "theme_mode = 'System' WHERE theme_mode = 'Circadian'",
          );
        }
      }
    },
    onCreate: (migrator) async {
      await migrator.createAll();
      await _ensureIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.selectedSkin,
        );
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.unlockedSkins,
        );
      }
      if (from < 3) {
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.themeMode,
        );
      }
      if (from < 4) {
        await _createTableIfMissing(migrator, decisionEntries);
      }
      if (from < 5) {
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.coreValues,
        );
        await _addColumnIfMissing(migrator, habits, habits.goalTag);
        await _addColumnIfMissing(
          migrator,
          decisionEntries,
          decisionEntries.reviewPeriodDays,
        );
      }
      if (from < 6) {
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.isDeveloperMode,
        );
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.recoveryEndDate,
        );
      }
      if (from < 7) {
        await _createTableIfMissing(migrator, marketplaceTemplates);
      }
      if (from < 8) {
        await _createTableIfMissing(migrator, valueDilemmaResponses);
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.revealedValueScores,
        );
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.revealedValueLastUpdatedAt,
        );
      }
      if (from < 9) {
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.cultivationThemeEnabled,
        );
      }
      if (from < 10) {
        await _addColumnIfMissing(
          migrator,
          valueDilemmaResponses,
          valueDilemmaResponses.responseReason,
        );
      }
      if (from < 11) {
        final tableName = marketplaceTemplates.actualTableName;
        final hasLegacyColumns =
            await _columnExists(tableName, 'friction') &&
            await _columnExists(tableName, 'energy') &&
            await _columnExists(tableName, 'impact') &&
            await _columnExists(tableName, 'mva_duration');

        if (!await _columnExists(tableName, 'template_type')) {
          await customStatement(
            'ALTER TABLE ${_quoteIdentifier(tableName)} '
            "ADD COLUMN template_type TEXT NOT NULL DEFAULT 'habit'",
          );
        }
        await _addColumnIfMissing(
          migrator,
          marketplaceTemplates,
          marketplaceTemplates.metadata,
        );

        if (hasLegacyColumns) {
          await customStatement('''
            UPDATE marketplace_templates
            SET metadata = json_object(
              'friction', friction,
              'energy', energy,
              'impact', impact,
              'mvaDuration', mva_duration
            )
            WHERE template_type = 'habit' AND metadata IS NULL
            ''');
        }
      }
      if (from < 12) {
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.vocabularyLevel,
        );
        await customStatement('''
          UPDATE user_profiles
          SET vocabulary_level = CASE
            WHEN cultivation_theme_enabled = 0 THEN 'mortal'
            ELSE 'earth'
          END
          ''');
      }
      if (from < 13) {
        // Schema version 13 was reserved for a migration that was later
        // consolidated into v14. No-op to preserve version continuity.
      }
      if (from < 14) {
        await _addColumnIfMissing(migrator, habits, habits.stackedToHabitId);
        await _addColumnIfMissing(
          migrator,
          userProfiles,
          userProfiles.circadianEnabled,
        );
        await customStatement(
          "UPDATE user_profiles SET circadian_enabled = 1, "
          "theme_mode = 'System' WHERE theme_mode = 'Circadian'",
        );
      }
      if (from < 15) {
        await _addColumnIfMissing(
          migrator,
          decisionEntries,
          decisionEntries.confidenceScore,
        );
      }
      if (from < 16) {
        // FIX: Add foreign key constraints via table rebuild
        await customStatement('PRAGMA foreign_keys = OFF');
        try {
          await transaction(() async {
            // Rebuild habit_logs with FK to habits
            await customStatement('''
              CREATE TABLE habit_logs_new (
                log_id TEXT NOT NULL PRIMARY KEY,
                habit_id TEXT NOT NULL REFERENCES habits(habit_id) ON DELETE CASCADE,
                date INTEGER NOT NULL,
                status TEXT NOT NULL,
                friction_reason_selected TEXT,
                duration_target_min INTEGER,
                duration_actual_min INTEGER,
                deleted_at INTEGER
              )
            ''');
            
            final habitLogCols = <String>[];
            if (await _columnExists('habit_logs', 'log_id')) habitLogCols.add('log_id');
            if (await _columnExists('habit_logs', 'habit_id')) habitLogCols.add('habit_id');
            if (await _columnExists('habit_logs', 'date')) habitLogCols.add('date');
            if (await _columnExists('habit_logs', 'status')) habitLogCols.add('status');
            if (await _columnExists('habit_logs', 'friction_reason_selected')) habitLogCols.add('friction_reason_selected');
            if (await _columnExists('habit_logs', 'duration_target_min')) habitLogCols.add('duration_target_min');
            if (await _columnExists('habit_logs', 'duration_actual_min')) habitLogCols.add('duration_actual_min');
            if (await _columnExists('habit_logs', 'deleted_at')) habitLogCols.add('deleted_at');

            final hlCols = habitLogCols.join(', ');
            await customStatement('INSERT INTO habit_logs_new ($hlCols) SELECT $hlCols FROM habit_logs');
            await customStatement('DROP TABLE habit_logs');
            await customStatement('ALTER TABLE habit_logs_new RENAME TO habit_logs');

            // Rebuild reminder_preferences with FK to habits
            await customStatement('''
              CREATE TABLE reminder_preferences_new (
                habit_id TEXT NOT NULL PRIMARY KEY REFERENCES habits(habit_id) ON DELETE CASCADE,
                reminder_enabled INTEGER NOT NULL DEFAULT 1,
                reminder_time TEXT NOT NULL DEFAULT '08:00',
                quiet_hours_start TEXT NOT NULL DEFAULT '22:00',
                quiet_hours_end TEXT NOT NULL DEFAULT '07:00'
              )
            ''');
            
            final reminderCols = <String>[];
            if (await _columnExists('reminder_preferences', 'habit_id')) reminderCols.add('habit_id');
            if (await _columnExists('reminder_preferences', 'reminder_enabled')) reminderCols.add('reminder_enabled');
            if (await _columnExists('reminder_preferences', 'reminder_time')) reminderCols.add('reminder_time');
            if (await _columnExists('reminder_preferences', 'quiet_hours_start')) reminderCols.add('quiet_hours_start');
            if (await _columnExists('reminder_preferences', 'quiet_hours_end')) reminderCols.add('quiet_hours_end');

            final rpCols = reminderCols.join(', ');
            await customStatement('INSERT INTO reminder_preferences_new ($rpCols) SELECT $rpCols FROM reminder_preferences');
            await customStatement('DROP TABLE reminder_preferences');
            await customStatement('ALTER TABLE reminder_preferences_new RENAME TO reminder_preferences');
          });
        } finally {
          await customStatement('PRAGMA foreign_keys = ON');
        }
      }
      if (from < 17) {
        // 1. Deduplicate journal_entries (keep the latest one per user+date)
        await customStatement('''
          DELETE FROM journal_entries 
          WHERE rowid NOT IN (
            SELECT MAX(rowid) FROM journal_entries 
            GROUP BY user_id, date
          )
        ''');

        // 2. Rebuild journal_entries with the new UNIQUE(user_id, date) constraint
        await customStatement('PRAGMA foreign_keys = OFF');
        try {
          await transaction(() async {
            await customStatement('''
              CREATE TABLE journal_entries_new (
                entry_id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NOT NULL,
                date INTEGER NOT NULL,
                mood_score INTEGER NOT NULL,
                keyword TEXT,
                text_content TEXT,
                gratitude_text TEXT,
                entry_type TEXT NOT NULL DEFAULT 'Lite',
                conflict_copy TEXT,
                deleted_at INTEGER,
                created_at INTEGER NOT NULL,
                UNIQUE(user_id, date)
              )
            ''');

            final journalCols = <String>[];
            if (await _columnExists('journal_entries', 'entry_id')) journalCols.add('entry_id');
            if (await _columnExists('journal_entries', 'user_id')) journalCols.add('user_id');
            if (await _columnExists('journal_entries', 'date')) journalCols.add('date');
            if (await _columnExists('journal_entries', 'mood_score')) journalCols.add('mood_score');
            if (await _columnExists('journal_entries', 'keyword')) journalCols.add('keyword');
            if (await _columnExists('journal_entries', 'text_content')) journalCols.add('text_content');
            if (await _columnExists('journal_entries', 'gratitude_text')) journalCols.add('gratitude_text');
            if (await _columnExists('journal_entries', 'entry_type')) journalCols.add('entry_type');
            if (await _columnExists('journal_entries', 'conflict_copy')) journalCols.add('conflict_copy');
            if (await _columnExists('journal_entries', 'deleted_at')) journalCols.add('deleted_at');
            if (await _columnExists('journal_entries', 'created_at')) journalCols.add('created_at');

            final jCols = journalCols.join(', ');
            await customStatement('INSERT INTO journal_entries_new ($jCols) SELECT $jCols FROM journal_entries');
            await customStatement('DROP TABLE journal_entries');
            await customStatement('ALTER TABLE journal_entries_new RENAME TO journal_entries');

            // 3. Rebuild habit_logs to ensure NO table-level UNIQUE constraint
            // (fixes fresh installs on v16 which had UNIQUE(habit_id, date) constraint)
            await customStatement('''
              CREATE TABLE habit_logs_new (
                log_id TEXT NOT NULL PRIMARY KEY,
                habit_id TEXT NOT NULL REFERENCES habits(habit_id) ON DELETE CASCADE,
                date INTEGER NOT NULL,
                status TEXT NOT NULL,
                friction_reason_selected TEXT,
                duration_target_min INTEGER,
                duration_actual_min INTEGER,
                deleted_at INTEGER
              )
            ''');

            final habitLogCols = <String>[];
            if (await _columnExists('habit_logs', 'log_id')) habitLogCols.add('log_id');
            if (await _columnExists('habit_logs', 'habit_id')) habitLogCols.add('habit_id');
            if (await _columnExists('habit_logs', 'date')) habitLogCols.add('date');
            if (await _columnExists('habit_logs', 'status')) habitLogCols.add('status');
            if (await _columnExists('habit_logs', 'friction_reason_selected')) habitLogCols.add('friction_reason_selected');
            if (await _columnExists('habit_logs', 'duration_target_min')) habitLogCols.add('duration_target_min');
            if (await _columnExists('habit_logs', 'duration_actual_min')) habitLogCols.add('duration_actual_min');
            if (await _columnExists('habit_logs', 'deleted_at')) habitLogCols.add('deleted_at');

            final hlCols = habitLogCols.join(', ');
            await customStatement('INSERT INTO habit_logs_new ($hlCols) SELECT $hlCols FROM habit_logs');
            await customStatement('DROP TABLE habit_logs');
            await customStatement('ALTER TABLE habit_logs_new RENAME TO habit_logs');
          });
        } finally {
          await customStatement('PRAGMA foreign_keys = ON');
        }
      }

      await _ensureIndexes();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'daoji.db'));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return NativeDatabase(file);
  });
}
