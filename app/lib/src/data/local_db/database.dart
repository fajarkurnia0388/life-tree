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
  TextColumn get coreValues => text().nullable()();
  BoolColumn get isDeveloperMode =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get recoveryEndDate => dateTime().nullable()();
  TextColumn get revealedValueScores => text().nullable()();
  DateTimeColumn get revealedValueLastUpdatedAt => dateTime().nullable()();
  BoolColumn get cultivationThemeEnabled =>
      boolean().withDefault(const Constant(true))();

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
  TextColumn get habitId => text()();
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

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, date},
  ];
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
    {userId, date, entryType},
  ];
}

@DataClassName('ThinkingCanvasSession')
class ThinkingCanvasSessions extends Table {
  TextColumn get sessionId => text()();
  TextColumn get userId => text()();
  TextColumn get methodKey =>
      text()(); // 'MindDump', 'Brainstorming', 'Scoring', 'PMI', 'ReverseBrainstorming', 'Validation'
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
  TextColumn get habitId => text()();
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
      "SELECT COUNT(DISTINCT date(hl.date / 1000, 'unixepoch')) AS cnt "
      "FROM habit_logs hl "
      "INNER JOIN habits h ON hl.habit_id = h.habit_id "
      "WHERE hl.status = '${HabitStatus.done}' AND hl.deleted_at IS NULL AND h.user_id = ? AND h.deleted_at IS NULL",
      variables: [Variable<String>(userId)],
      readsFrom: {habitLogs, habits},
    ).getSingle();
    return result.read<int>('cnt');
  }

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (m) async {
      await m.createAll();
      // Create custom performance and application indexes
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_habit_log_perf ON habit_logs (habit_id, date, status);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_habit_log_desc ON habit_logs (habit_id, date DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_journal_entry_wellness ON journal_entries (user_id, date, mood_score);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_thinking_canvas_history ON thinking_canvas_sessions (user_id, created_at DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_thinking_canvas_patterns ON thinking_canvas_sessions (user_id, method_key, created_at DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_habit_active ON habits (user_id, status, domain_tag);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_weekly_pulse_ttl ON weekly_pulses (user_id, domain_tag, week_start_date DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_wellness_prompt_log_cap ON wellness_prompt_logs (user_id, prompted_at DESC);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_consent_log_check ON consent_logs (user_id, consent_type);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_decision_review ON decision_entries (user_id, review_date, is_reviewed);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_value_dilemma_user ON value_dilemma_responses (user_id, answered_at DESC);',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(userProfiles, userProfiles.selectedSkin);
        await m.addColumn(userProfiles, userProfiles.unlockedSkins);
      }
      if (from < 3) {
        await m.addColumn(userProfiles, userProfiles.themeMode);
      }
      if (from < 4) {
        await m.createTable(decisionEntries);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_decision_review ON decision_entries (user_id, review_date, is_reviewed);',
        );
      }
      if (from < 5) {
        await m.addColumn(userProfiles, userProfiles.coreValues);
        await m.addColumn(habits, habits.goalTag);
        await m.addColumn(decisionEntries, decisionEntries.reviewPeriodDays);
      }
      if (from < 6) {
        await m.addColumn(userProfiles, userProfiles.isDeveloperMode);
        await m.addColumn(userProfiles, userProfiles.recoveryEndDate);
        // Create performance indexes for upgraded users (FIX-14)
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_habit_log_perf ON habit_logs (habit_id, date, status);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_habit_log_desc ON habit_logs (habit_id, date DESC);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_journal_entry_wellness ON journal_entries (user_id, date, mood_score);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_habit_active ON habits (user_id, status, domain_tag);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_weekly_pulse_ttl ON weekly_pulses (user_id, domain_tag, week_start_date DESC);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_decision_review ON decision_entries (user_id, review_date, is_reviewed);',
        );
      }
      if (from < 7) {
        await m.createTable(marketplaceTemplates);
      }
      if (from < 8) {
        await m.createTable(valueDilemmaResponses);
        await m.addColumn(userProfiles, userProfiles.revealedValueScores);
        await m.addColumn(
          userProfiles,
          userProfiles.revealedValueLastUpdatedAt,
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_value_dilemma_user ON value_dilemma_responses (user_id, answered_at DESC);',
        );
      }
      if (from < 9) {
        await m.addColumn(userProfiles, userProfiles.cultivationThemeEnabled);
      }
      if (from < 10) {
        await m.addColumn(
          valueDilemmaResponses,
          valueDilemmaResponses.responseReason,
        );
      }
      if (from < 11) {
        // Migrate existing habit templates to new schema
        await customStatement(
          'ALTER TABLE marketplace_templates ADD COLUMN template_type TEXT NOT NULL DEFAULT "habit"',
        );
        await customStatement(
          'ALTER TABLE marketplace_templates ADD COLUMN metadata TEXT',
        );
        // Move habit-specific data to metadata JSON
        await customStatement('''
          UPDATE marketplace_templates
          SET metadata = json_object(
            'friction', friction,
            'energy', energy,
            'impact', impact,
            'mvaDuration', mva_duration
          )
          WHERE template_type = 'habit'
          ''');
        // Keep old columns for backward compatibility but mark as deprecated
      }
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
