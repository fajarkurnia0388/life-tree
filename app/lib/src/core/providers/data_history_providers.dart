import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_db/database.dart';
import 'db_provider.dart';
import 'package:drift/drift.dart' as drift;

final weeklyPulsesHistoryProvider = StreamProvider<List<WeeklyPulse>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.weeklyPulses)
        ..orderBy([
          (tbl) => drift.OrderingTerm(
                expression: tbl.weekStartDate,
                mode: drift.OrderingMode.asc,
              ),
        ]))
      .watch();
});

final lifeAuditsHistoryProvider = StreamProvider<List<LifeAudit>>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.lifeAudits)
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
