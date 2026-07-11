import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_db/database.dart';
import 'db_provider.dart';
import 'user_profile_provider.dart';

final weeklyPulsesHistoryProvider = StreamProvider<List<WeeklyPulse>>((
  ref,
) async* {
  final db = ref.watch(dbProvider);
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) {
    yield const [];
    return;
  }
  yield* (db.select(db.weeklyPulses)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull())
        ..orderBy([
          (tbl) => drift.OrderingTerm(
            expression: tbl.weekStartDate,
            mode: drift.OrderingMode.asc,
          ),
        ]))
      .watch();
});

final lifeAuditsHistoryProvider = StreamProvider<List<LifeAudit>>((ref) async* {
  final db = ref.watch(dbProvider);
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) {
    yield const [];
    return;
  }
  yield* (db.select(db.lifeAudits)
        ..where((tbl) => tbl.userId.equals(userId) & tbl.deletedAt.isNull())
        ..orderBy([
          (tbl) => drift.OrderingTerm(
            expression: tbl.timestamp,
            mode: drift.OrderingMode.asc,
          ),
        ]))
      .watch();
});

final circadianEnabledProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.userProfiles)..limit(1)).watch().map((profiles) {
    if (profiles.isEmpty) return false;
    return profiles.first.circadianEnabled;
  });
});
