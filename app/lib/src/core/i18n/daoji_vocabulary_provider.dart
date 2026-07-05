import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_db/database.dart';
import '../providers/db_provider.dart';
import 'daoji_vocabulary_level.dart';

final daojiVocabularyLevelProvider = StreamProvider<DaojiVocabularyLevel>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.userProfiles)..limit(1)).watch().map((profiles) {
    if (profiles.isEmpty) return DaojiVocabularyLevel.earth;
    return parseDaojiVocabularyLevel(profiles.first.vocabularyLevel);
  });
});

final daojiVocabularyLevelValueProvider = Provider<DaojiVocabularyLevel>((ref) {
  return ref.watch(daojiVocabularyLevelProvider).valueOrNull ??
      DaojiVocabularyLevel.earth;
});

final daojiVocabularyControllerProvider = Provider<DaojiVocabularyController>((
  ref,
) {
  return DaojiVocabularyController(ref);
});

class DaojiVocabularyController {
  DaojiVocabularyController(this._ref);

  final Ref _ref;

  Future<void> setLevel(DaojiVocabularyLevel level) async {
    final db = _ref.read(dbProvider);
    final profile = await (db.select(
      db.userProfiles,
    )..limit(1)).getSingleOrNull();
    if (profile == null) return;

    await (db.update(db.userProfiles)
          ..where((tbl) => tbl.userId.equals(profile.userId)))
        .write(
      UserProfilesCompanion(
        vocabularyLevel: drift.Value(level.name),
        cultivationThemeEnabled: drift.Value(level.cultivationThemeEnabled),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
  }
}
