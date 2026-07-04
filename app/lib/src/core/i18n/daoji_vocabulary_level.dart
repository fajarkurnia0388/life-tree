/// Daoji vocabulary/register levels.
///
/// This is intentionally separate from locale/language. Locale answers
/// "which language?" (id/en), while vocabulary level answers "how much
/// cultivation terminology?".
enum DaojiVocabularyLevel {
  practical,
  gentleCultivation,
  daoStream,
  immortalCultivation,
}

extension DaojiVocabularyLevelX on DaojiVocabularyLevel {
  String get displayName {
    return switch (this) {
      DaojiVocabularyLevel.practical => 'Practical',
      DaojiVocabularyLevel.gentleCultivation => 'Gentle Cultivation',
      DaojiVocabularyLevel.daoStream => 'Dao Stream',
      DaojiVocabularyLevel.immortalCultivation => 'Immortal Cultivation',
    };
  }

  String get description {
    return switch (this) {
      DaojiVocabularyLevel.practical =>
        'Bahasa praktis tanpa istilah Dao/Qi/Stream.',
      DaojiVocabularyLevel.gentleCultivation =>
        'Nuansa kultivasi ringan dengan istilah practice dan stream pendek.',
      DaojiVocabularyLevel.daoStream =>
        'Default Daoji: Six Dao Streams, Dao Tree, Qi Log, Seclusion.',
      DaojiVocabularyLevel.immortalCultivation =>
        'Nuansa xianxia penuh: Meridian, Dantian, Heart Demon, Qi Deviation.',
    };
  }

  bool get cultivationThemeEnabled => this != DaojiVocabularyLevel.practical;
}

DaojiVocabularyLevel parseDaojiVocabularyLevel(String? value) {
  if (value == null || value.trim().isEmpty) {
    return DaojiVocabularyLevel.daoStream;
  }
  return DaojiVocabularyLevel.values.firstWhere(
    (level) => level.name == value,
    orElse: () => DaojiVocabularyLevel.daoStream,
  );
}
