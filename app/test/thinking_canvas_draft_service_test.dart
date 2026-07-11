import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/thinking_canvas/thinking_canvas_draft_service.dart';
import 'package:drift/drift.dart' as drift;

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ThinkingCanvasDraftService service;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );
    service = container.read(thinkingCanvasDraftServiceProvider);

    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            userId: 'test-user',
            ageBand: 'adult',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  test('loadDraft ignores non-draft and soft-deleted rows', () async {
    final now = DateTime.now();
    await db.into(db.thinkingCanvasSessions).insert(
          ThinkingCanvasSessionsCompanion.insert(
            sessionId: 'hist-1',
            userId: 'test-user',
            methodKey: 'MindDump',
            isDraft: const drift.Value(false),
            rawNotes: const drift.Value('history'),
            paperSession: const drift.Value(false),
            createdAt: now,
          ),
        );
    await db.into(db.thinkingCanvasSessions).insert(
          ThinkingCanvasSessionsCompanion.insert(
            sessionId: 'draft-del',
            userId: 'test-user',
            methodKey: 'SWOT',
            isDraft: const drift.Value(true),
            rawNotes: const drift.Value('gone'),
            paperSession: const drift.Value(false),
            createdAt: now,
            deletedAt: drift.Value(now),
          ),
        );

    expect(await service.loadDraftSession(), isNull);

    await service.upsertDraft(methodKey: 'MindDump', content: 'hello draft');
    final loaded = await service.loadDraftSession();
    expect(loaded, isNotNull);
    expect(loaded!.isDraft, isTrue);
    expect(loaded.rawNotes, 'hello draft');
    expect(loaded.methodKey, 'MindDump');
  });

  test('commitSession writes history and clears draft', () async {
    await service.upsertDraft(methodKey: 'Freewriting', content: 'stream of consciousness');
    expect(await service.loadDraftSession(), isNotNull);

    await service.commitSession(
      methodKey: 'Freewriting',
      content: 'stream of consciousness',
    );

    expect(await service.loadDraftSession(), isNull);

    final history = await service.watchHistory().first;
    expect(history, isNotEmpty);
    expect(history.first.isDraft, isFalse);
    expect(history.first.rawNotes, 'stream of consciousness');
  });

  test('softDeleteSession hides from history stream', () async {
    await service.commitSession(methodKey: 'SWOT', content: 's w o t');
    var history = await service.watchHistory().first;
    expect(history.length, 1);
    await service.softDeleteSession(history.first.sessionId);
    history = await service.watchHistory().first;
    expect(history, isEmpty);
  });
}
