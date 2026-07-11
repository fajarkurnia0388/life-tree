import 'dart:convert';

import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/dashboard/services/dashboard_action_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test(
    'countUniqueDoneDates counts distinct Drift Unix-second dates',
    () async {
      await db
          .into(db.habits)
          .insert(
            HabitsCompanion.insert(
              habitId: 'habit-1',
              userId: 'user-1',
              title: 'Test habit',
              createdAt: DateTime(2026, 7),
            ),
          );
      for (final entry in [
        ('log-1', DateTime(2026, 7, 10)),
        ('log-2', DateTime(2026, 7, 11)),
      ]) {
        await db
            .into(db.habitLogs)
            .insert(
              HabitLogsCompanion.insert(
                logId: entry.$1,
                habitId: 'habit-1',
                date: entry.$2,
                status: 'Done',
              ),
            );
      }

      expect(await db.countUniqueDoneDates('user-1'), 2);
    },
  );

  test('resetAllUserData removes every persisted table', () async {
    await db
        .into(db.valueDilemmaResponses)
        .insert(
          ValueDilemmaResponsesCompanion.insert(
            responseId: 'response-1',
            userId: 'user-1',
            dilemmaKey: 'private-value',
            answeredAt: DateTime(2026, 7, 11),
          ),
        );
    await db
        .into(db.marketplaceTemplates)
        .insert(
          MarketplaceTemplatesCompanion.insert(
            templateId: 'template-1',
            templateType: 'habit',
            title: 'Private title',
            description: 'Private description',
            creatorPenName: 'Private pen name',
            ratingsSum: 0,
            ratingsCount: 0,
            downloadsCount: 0,
            createdAt: DateTime(2026, 7, 11),
          ),
        );

    await DashboardActionService(db).resetAllUserData();

    expect(await db.select(db.valueDilemmaResponses).get(), isEmpty);
    expect(await db.select(db.marketplaceTemplates).get(), isEmpty);
  });

  test('export contains all user-owned data categories', () async {
    final now = DateTime(2026, 7, 11);
    await db
        .into(db.userProfiles)
        .insert(
          UserProfilesCompanion.insert(
            userId: 'user-1',
            ageBand: '25-34',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.valueDilemmaResponses)
        .insert(
          ValueDilemmaResponsesCompanion.insert(
            responseId: 'response-1',
            userId: 'user-1',
            dilemmaKey: 'value',
            answeredAt: now,
          ),
        );
    await db
        .into(db.thinkingCanvasSessions)
        .insert(
          ThinkingCanvasSessionsCompanion.insert(
            sessionId: 'session-1',
            userId: 'user-1',
            methodKey: 'Freewriting',
            createdAt: now,
          ),
        );

    final export = await DashboardActionService(db).exportAllUserData('user-1');

    expect(export['schema_version'], 1);
    expect(export['profile'], isA<Map<String, dynamic>>());
    expect(export['value_dilemma_responses'], hasLength(1));
    expect(export['thinking_canvas_sessions'], hasLength(1));
    expect(() => jsonEncode(export), returnsNormally);
    expect(
      export.keys,
      containsAll(<String>[
        'habits',
        'habit_logs',
        'reminder_preferences',
        'journal_entries',
        'weekly_pulses',
        'life_audits',
        'decision_entries',
        'consent_logs',
        'wellness_prompt_logs',
        'local_marketplace_records',
      ]),
    );
  });
}
