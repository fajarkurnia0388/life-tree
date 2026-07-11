import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';

class DecisionJournalService {
  final AppDatabase db;
  DecisionJournalService(this.db);

  Stream<List<DecisionEntry>> watchDecisionEntries(String userId) {
    return (db.select(db.decisionEntries)
          ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull())
          ..orderBy([
            (tbl) => drift.OrderingTerm(
                  expression: tbl.decisionDate,
                  mode: drift.OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<void> createDecisionEntry({
    required String userId,
    required String title,
    required String description,
    required String options,
    required String assumptions,
    required String expectations,
    required DateTime reviewDate,
    required int reviewPeriodDays,
    required int confidenceScore,
  }) async {
    final decisionId = const Uuid().v4();
    await db.into(db.decisionEntries).insert(
          DecisionEntriesCompanion.insert(
            decisionId: decisionId,
            userId: userId,
            title: title,
            description: description.isEmpty ? '-' : description,
            options: options,
            assumptions: assumptions,
            expectations: expectations,
            decisionDate: DateTime.now(),
            reviewDate: reviewDate,
            reviewPeriodDays: drift.Value(reviewPeriodDays),
            confidenceScore: drift.Value(confidenceScore),
            isReviewed: const drift.Value(false),
          ),
        );
  }

  Future<void> reviewDecisionEntry({
    required String decisionId,
    required String reviewReflection,
  }) async {
    await (db.update(db.decisionEntries)
          ..where((tbl) => tbl.decisionId.equals(decisionId)))
        .write(
      DecisionEntriesCompanion(
        isReviewed: const drift.Value(true),
        reviewReflection: drift.Value(reviewReflection),
      ),
    );
  }
}

final decisionJournalServiceProvider = Provider<DecisionJournalService>((ref) {
  return DecisionJournalService(ref.watch(dbProvider));
});
