/// Daoji vocabulary/register levels.
///
/// This is intentionally separate from locale/language. Locale answers
/// "which language?" (id/en), while vocabulary level answers "how much
/// cultivation terminology?".
enum DaojiVocabularyLevel {
  mortal,
  human,
  earth,
  heaven,
}

extension DaojiVocabularyLevelX on DaojiVocabularyLevel {
  String get displayName {
    return switch (this) {
      DaojiVocabularyLevel.mortal => 'Mortal',
      DaojiVocabularyLevel.human => 'Human',
      DaojiVocabularyLevel.earth => 'Earth',
      DaojiVocabularyLevel.heaven => 'Heaven',
    };
  }

  String get description {
    return switch (this) {
      DaojiVocabularyLevel.mortal => 'Bahasa paling sederhana dan langsung.',
      DaojiVocabularyLevel.human =>
        'Bahasa yang lebih manusiawi dan hangat.',
      DaojiVocabularyLevel.earth =>
        'Bahasa yang lebih dekat dengan dunia dan bumi.',
      DaojiVocabularyLevel.heaven =>
        'Bahasa yang lebih tinggi dan penuh nuansa surgawi.',
    };
  }

  bool get cultivationThemeEnabled => this != DaojiVocabularyLevel.mortal;
}

DaojiVocabularyLevel parseDaojiVocabularyLevel(String? value) {
  if (value == null || value.trim().isEmpty) {
    return DaojiVocabularyLevel.mortal; // Default updated to Mortal
  }
  
  // Legacy Mapping to ensure backward compatibility with DB
  return switch (value.trim()) {
    'practical' => DaojiVocabularyLevel.mortal,
    'gentleCultivation' => DaojiVocabularyLevel.human,
    'daoStream' => DaojiVocabularyLevel.earth,
    'immortalCultivation' => DaojiVocabularyLevel.heaven,
    _ => DaojiVocabularyLevel.values.firstWhere(
        (level) => level.name == value,
        orElse: () => DaojiVocabularyLevel.mortal,
      ),
  };
}
