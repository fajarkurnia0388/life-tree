import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import '../../core/providers/db_provider.dart';

class ThinkingCanvasDraftService {
  final AppDatabase db;
  ThinkingCanvasDraftService(this.db);

  Future<ThinkingCanvasSession?> loadDraftSession() async {
    return await (db.select(db.thinkingCanvasSessions)
          ..orderBy([
            (tbl) => drift.OrderingTerm(
              expression: tbl.createdAt,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> saveDraft(ThinkingCanvasSession session) async {
    await db.into(db.thinkingCanvasSessions).insertOnConflictUpdate(session);
  }

  Future<void> deleteDraft() async {
    final latest = await loadDraftSession();
    if (latest != null) {
      await (db.delete(
        db.thinkingCanvasSessions,
      )..where((tbl) => tbl.sessionId.equals(latest.sessionId))).go();
    }
  }
}

final thinkingCanvasDraftServiceProvider = Provider<ThinkingCanvasDraftService>(
  (ref) {
    return ThinkingCanvasDraftService(ref.watch(dbProvider));
  },
);
