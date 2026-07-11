import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import '../../core/providers/db_provider.dart';

/// Draft + committed session persistence for Thinking Canvas.
///
/// Draft rows: `isDraft == true` and `deletedAt == null`.
/// History rows: `isDraft == false` and `deletedAt == null`.
class ThinkingCanvasDraftService {
  final AppDatabase db;
  ThinkingCanvasDraftService(this.db);

  static const String draftSessionIdPrefix = 'draft_';

  Future<String?> _currentUserId() async {
    final profiles = await db.select(db.userProfiles).get();
    if (profiles.isEmpty) return null;
    return profiles.first.userId;
  }

  /// Latest non-deleted draft for the current user (any method).
  Future<ThinkingCanvasSession?> loadDraftSession({String? userId}) async {
    final uid = userId ?? await _currentUserId();
    if (uid == null) return null;

    // Exclude internal prefs singleton row (see ThinkingCanvasController).
    const prefsSessionId = 'canvas_prefs_singleton';
    const prefsMethodKey = '__canvas_prefs__';

    return await (db.select(db.thinkingCanvasSessions)
          ..where(
            (tbl) =>
                tbl.userId.equals(uid) &
                tbl.isDraft.equals(true) &
                tbl.deletedAt.isNull() &
                tbl.sessionId.equals(prefsSessionId).not() &
                tbl.methodKey.equals(prefsMethodKey).not(),
          )
          ..orderBy([
            (tbl) => drift.OrderingTerm(
              expression: tbl.createdAt,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Upsert a single active draft per user (replaces previous draft content
  /// on the same draft id when possible).
  Future<void> upsertDraft({
    required String methodKey,
    required String content,
    String? topic,
    String? structuredOutput,
  }) async {
    final uid = await _currentUserId();
    if (uid == null) return;
    if (content.trim().isEmpty) return;

    final existing = await loadDraftSession(userId: uid);
    final now = DateTime.now();
    final sessionId =
        existing?.sessionId ??
        '$draftSessionIdPrefix${now.millisecondsSinceEpoch}';

    await db
        .into(db.thinkingCanvasSessions)
        .insertOnConflictUpdate(
          ThinkingCanvasSessionsCompanion.insert(
            sessionId: sessionId,
            userId: uid,
            methodKey: methodKey,
            isDraft: const drift.Value(true),
            topic: drift.Value(topic),
            rawNotes: drift.Value(content),
            structuredOutput: drift.Value(structuredOutput),
            paperSession: const drift.Value(false),
            createdAt: existing?.createdAt ?? now,
            deletedAt: const drift.Value(null),
          ),
        );
  }

  Future<void> saveDraft(ThinkingCanvasSession session) async {
    await db.into(db.thinkingCanvasSessions).insertOnConflictUpdate(session);
  }

  /// Soft-deletes the current draft (does not hard-delete history).
  Future<void> deleteDraft({String? userId}) async {
    final draft = await loadDraftSession(userId: userId);
    if (draft == null) return;
    await (db.update(db.thinkingCanvasSessions)
          ..where((tbl) => tbl.sessionId.equals(draft.sessionId)))
        .write(ThinkingCanvasSessionsCompanion(
      deletedAt: drift.Value(DateTime.now()),
      isDraft: const drift.Value(false),
    ));
  }

  /// Commit current content as a permanent history session and clear draft.
  Future<void> commitSession({
    required String methodKey,
    required String content,
    String? topic,
    String? structuredOutput,
  }) async {
    final uid = await _currentUserId();
    if (uid == null) return;
    if (content.trim().isEmpty) return;

    final now = DateTime.now();
    await db
        .into(db.thinkingCanvasSessions)
        .insert(
          ThinkingCanvasSessionsCompanion.insert(
            sessionId: now.millisecondsSinceEpoch.toString(),
            userId: uid,
            methodKey: methodKey,
            isDraft: const drift.Value(false),
            topic: drift.Value(topic),
            rawNotes: drift.Value(content),
            structuredOutput: drift.Value(structuredOutput),
            paperSession: const drift.Value(false),
            createdAt: now,
          ),
        );

    // Soft-delete any active draft so it does not shadow history restore.
    await deleteDraft(userId: uid);
  }

  Stream<List<ThinkingCanvasSession>> watchHistory({int limit = 20}) async* {
    final uid = await _currentUserId();
    if (uid == null) {
      yield const [];
      return;
    }

    yield* (db.select(db.thinkingCanvasSessions)
          ..where(
            (tbl) =>
                tbl.userId.equals(uid) &
                tbl.isDraft.equals(false) &
                tbl.deletedAt.isNull(),
          )
          ..orderBy([
            (tbl) => drift.OrderingTerm(
              expression: tbl.createdAt,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .watch();
  }

  Future<void> softDeleteSession(String sessionId) async {
    await (db.update(db.thinkingCanvasSessions)
          ..where((tbl) => tbl.sessionId.equals(sessionId)))
        .write(
          ThinkingCanvasSessionsCompanion(
            deletedAt: drift.Value(DateTime.now()),
          ),
        );
  }

  Future<void> softDeleteAllHistory() async {
    final uid = await _currentUserId();
    if (uid == null) return;
    await (db.update(db.thinkingCanvasSessions)
          ..where(
            (tbl) =>
                tbl.userId.equals(uid) &
                tbl.isDraft.equals(false) &
                tbl.deletedAt.isNull(),
          ))
        .write(
          ThinkingCanvasSessionsCompanion(
            deletedAt: drift.Value(DateTime.now()),
          ),
        );
  }
}

final thinkingCanvasDraftServiceProvider = Provider<ThinkingCanvasDraftService>(
  (ref) {
    return ThinkingCanvasDraftService(ref.watch(dbProvider));
  },
);

final thinkingCanvasHistoryProvider =
    StreamProvider.autoDispose<List<ThinkingCanvasSession>>((ref) {
      final service = ref.watch(thinkingCanvasDraftServiceProvider);
      return service.watchHistory();
    });
