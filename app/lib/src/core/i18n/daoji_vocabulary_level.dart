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
      DaojiVocabularyLevel.practical => 'Mortal',
      DaojiVocabularyLevel.gentleCultivation => 'Human',
      DaojiVocabularyLevel.daoStream => 'Earth',
      DaojiVocabularyLevel.immortalCultivation => 'Heaven',
    };
  }

  String get description {
    return switch (this) {
      DaojiVocabularyLevel.practical =>
        'Bahasa paling sederhana dan langsung.',
      DaojiVocabularyLevel.gentleCultivation =>
        'Bahasa yang lebih manusiawi dan hangat.',
      DaojiVocabularyLevel.daoStream =>
        'Bahasa yang lebih dekat dengan dunia dan bumi.',
      DaojiVocabularyLevel.immortalCultivation =>
        'Bahasa yang lebih tinggi dan penuh nuansa surgawi.',
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
