import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/db_provider.dart';
import '../../../data/local_db/database.dart';

class ValueCompassService {
  final AppDatabase _db;
  ValueCompassService(this._db);

  /// Catat satu jawaban binary, lalu hitung ulang & cache skor tersirat.
  Future<void> recordBinaryResponse({
    required String userId,
    required String dilemmaKey,
    required String chosenOptionLabel, // 'A' atau 'B'
    required String chosenValueTag,
    String? reason, // Optional reason for the choice
  }) async {
    final responseId = const Uuid().v4();
    await _db.transaction(() async {
      await _db
          .into(_db.valueDilemmaResponses)
          .insert(
            ValueDilemmaResponsesCompanion.insert(
              responseId: responseId,
              userId: userId,
              dilemmaKey: dilemmaKey,
              chosenValueTag: drift.Value(chosenValueTag),
              chosenOptionLabel: drift.Value(chosenOptionLabel),
              responseReason: drift.Value(reason),
              answeredAt: DateTime.now(),
            ),
          );
      await _recomputeRevealedValues(userId);
    });
  }

  /// Record "both important" or "depends on context" response.
  /// This does NOT affect revealed value scores (neutral stance).
  Future<void> recordNeutralResponse({
    required String userId,
    required String dilemmaKey,
    required String neutralLabel, // 'Both' or 'Depends'
    String? reason,
  }) async {
    final responseId = const Uuid().v4();
    await _db
        .into(_db.valueDilemmaResponses)
        .insert(
          ValueDilemmaResponsesCompanion.insert(
            responseId: responseId,
            userId: userId,
            dilemmaKey: dilemmaKey,
            chosenOptionLabel: drift.Value(neutralLabel),
            responseReason: drift.Value(reason),
            answeredAt: DateTime.now(),
          ),
        );
    // No recompute — neutral answers don't affect value scores
  }

  Future<void> recordOpenResponse({
    required String userId,
    required String dilemmaKey,
    required String text,
  }) async {
    final responseId = const Uuid().v4();
    await _db
        .into(_db.valueDilemmaResponses)
        .insert(
          ValueDilemmaResponsesCompanion.insert(
            responseId: responseId,
            userId: userId,
            dilemmaKey: dilemmaKey,
            openTextResponse: drift.Value(text),
            answeredAt: DateTime.now(),
          ),
        );
    // Tidak memengaruhi skor — tidak perlu recompute.
  }

  /// Hitung ulang tally lengkap dari seluruh respons (bukan incremental).
  /// Dataset kecil (puluhan-ratusan baris per user) sehingga full-scan aman.
  Future<void> _recomputeRevealedValues(String userId) async {
    final responses =
        await (_db.select(_db.valueDilemmaResponses)..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.deletedAt.isNull() &
                  tbl.chosenValueTag.isNotNull(),
            ))
            .get();

    final tally = <String, int>{};
    for (final r in responses) {
      final tag = r.chosenValueTag!;
      tally[tag] = (tally[tag] ?? 0) + 1;
    }

    await (_db.update(
      _db.userProfiles,
    )..where((tbl) => tbl.userId.equals(userId))).write(
      UserProfilesCompanion(
        revealedValueScores: drift.Value(jsonEncode(tally)),
        revealedValueLastUpdatedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  /// Ambil top-N nilai tersirat. Mengembalikan list kosong jika data
  /// belum cukup (minResponses belum tercapai) — JANGAN tampilkan
  /// insight prematur ke pengguna.
  Future<List<String>> getTopRevealedValues({
    required UserProfile profile,
    int topN = 3,
    int minResponses = 5,
  }) async {
    if (profile.revealedValueScores == null) return [];
    final Map<String, dynamic> raw = jsonDecode(profile.revealedValueScores!);
    final totalResponses = raw.values.fold<int>(
      0,
      (sum, v) => sum + (v as int),
    );
    if (totalResponses < minResponses) return [];

    final entries = raw.entries.toList()
      ..sort((a, b) {
        final cmp = (b.value as int).compareTo(a.value as int);
        if (cmp != 0) return cmp;
        return a.key.compareTo(b.key); // tie-break alfabetis, deterministik
      });
    return entries.take(topN).map((e) => e.key).toList();
  }
}

final valueCompassServiceProvider = Provider<ValueCompassService>((ref) {
  return ValueCompassService(ref.watch(dbProvider));
});

final revealedValuesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(valueCompassServiceProvider);
  final db = ref.watch(dbProvider);
  final profiles = await db.select(db.userProfiles).get();
  if (profiles.isEmpty) return [];
  return service.getTopRevealedValues(profile: profiles.first);
});
