import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:daoji/src/core/providers/db_provider.dart';
import 'package:daoji/src/data/local_db/database.dart';
import 'package:daoji/src/features/thinking_canvas/thinking_canvas_draft_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ThinkingCanvasDraftService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        dbProvider.overrideWithValue(db),
      ],
    );
    service = container.read(thinkingCanvasDraftServiceProvider);
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  test('ThinkingCanvasDraftService load, save, delete drafts correctly', () async {
    // 1. Initially, there should be no draft
    final initialDraft = await service.loadDraftSession();
    expect(initialDraft, isNull);

    // 2. Save a draft
    final now = DateTime.now();
    final session1 = ThinkingCanvasSession(
      sessionId: 'session-1',
      userId: 'test-user',
      methodKey: 'MindDump',
      isDraft: true,
      paperSession: false,
      topic: 'Topic 1',
      createdAt: now,
    );

    await service.saveDraft(session1);

    // Verify it is loaded
    var loaded = await service.loadDraftSession();
    expect(loaded, isNotNull);
    expect(loaded!.sessionId, 'session-1');
    expect(loaded.topic, 'Topic 1');

    // 3. Save another draft later
    final later = now.add(const Duration(minutes: 5));
    final session2 = ThinkingCanvasSession(
      sessionId: 'session-2',
      userId: 'test-user',
      methodKey: 'PMI',
      isDraft: true,
      paperSession: false,
      topic: 'Topic 2',
      createdAt: later,
    );

    await service.saveDraft(session2);

    // Should return the latest draft (session-2)
    loaded = await service.loadDraftSession();
    expect(loaded!.sessionId, 'session-2');
    expect(loaded.topic, 'Topic 2');

    // 4. Delete the latest draft
    await service.deleteDraft();

    // Now the loaded draft should fall back to session-1
    loaded = await service.loadDraftSession();
    expect(loaded!.sessionId, 'session-1');
    expect(loaded.topic, 'Topic 1');

    // Delete session-1
    await service.deleteDraft();
    loaded = await service.loadDraftSession();
    expect(loaded, isNull);
  });
}
