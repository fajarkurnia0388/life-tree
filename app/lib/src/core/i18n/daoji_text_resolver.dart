import 'package:flutter/widgets.dart';

import 'daoji_text_key.dart';
import 'daoji_text_registry_id.dart';
import 'daoji_vocabulary_level.dart';

class DaojiText {
  const DaojiText._();

  static String resolve(
    DaojiTextKey key,
    DaojiVocabularyLevel level, {
    Locale? locale,
    Map<String, Object?> params = const {},
  }) {
    // P0 ships Indonesian copy with English Daoji brand terms.
    // The locale parameter is accepted so the API is bilingual-ready.
    final table = daojiTextsId;
    final levels = _fallbackLevels(level);

    String? value;
    for (final candidate in levels) {
      value = table[candidate]?[key];
      if (value != null) break;
    }
    value ??= '[[${key.name}]]';

    return _applyParams(value, params);
  }

  static List<DaojiVocabularyLevel> _fallbackLevels(
    DaojiVocabularyLevel level,
  ) {
    return switch (level) {
      DaojiVocabularyLevel.immortalCultivation => const [
        DaojiVocabularyLevel.immortalCultivation,
        DaojiVocabularyLevel.daoStream,
        DaojiVocabularyLevel.gentleCultivation,
        DaojiVocabularyLevel.practical,
      ],
      DaojiVocabularyLevel.daoStream => const [
        DaojiVocabularyLevel.daoStream,
        DaojiVocabularyLevel.gentleCultivation,
        DaojiVocabularyLevel.practical,
      ],
      DaojiVocabularyLevel.gentleCultivation => const [
        DaojiVocabularyLevel.gentleCultivation,
        DaojiVocabularyLevel.practical,
      ],
      DaojiVocabularyLevel.practical => const [DaojiVocabularyLevel.practical],
    };
  }

  static String _applyParams(String input, Map<String, Object?> params) {
    var output = input;
    for (final entry in params.entries) {
      output = output.replaceAll('{${entry.key}}', '${entry.value ?? ''}');
    }
    return output;
  }

  static String domainLabel(
    String? domain,
    DaojiVocabularyLevel level, {
    bool short = false,
  }) {
    final key = domain ?? 'Tubuh';
    final labels = _domainLabels[key] ?? _domainLabels['Tubuh']!;
    if (short) {
      return labels.shortLabels[level] ?? labels.shortLabels[DaojiVocabularyLevel.daoStream]!;
    }
    return labels.fullLabels[level] ?? labels.fullLabels[DaojiVocabularyLevel.daoStream]!;
  }

  static String streamNeedsCare(String? domain, DaojiVocabularyLevel level) {
    final stream = domainLabel(domain, level);
    return resolve(
      DaojiTextKey.actionSubtitle,
      level,
      params: {'stream': stream},
    );
  }
}

class _DomainVocabularyLabels {
  const _DomainVocabularyLabels({
    required this.shortLabels,
    required this.fullLabels,
  });

  final Map<DaojiVocabularyLevel, String> shortLabels;
  final Map<DaojiVocabularyLevel, String> fullLabels;
}

const Map<String, _DomainVocabularyLabels> _domainLabels = {
  'Tubuh': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Tubuh',
      DaojiVocabularyLevel.gentleCultivation: 'Vital',
      DaojiVocabularyLevel.daoStream: 'Vital',
      DaojiVocabularyLevel.immortalCultivation: 'Vital',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Tubuh',
      DaojiVocabularyLevel.gentleCultivation: 'Vital',
      DaojiVocabularyLevel.daoStream: 'Vital Stream',
      DaojiVocabularyLevel.immortalCultivation: 'Vital Meridian',
    },
  ),
  'Keuangan': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Sumber Daya',
      DaojiVocabularyLevel.gentleCultivation: 'Reserve',
      DaojiVocabularyLevel.daoStream: 'Reserve',
      DaojiVocabularyLevel.immortalCultivation: 'Reserve',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Sumber Daya',
      DaojiVocabularyLevel.gentleCultivation: 'Reserve',
      DaojiVocabularyLevel.daoStream: 'Reserve Stream',
      DaojiVocabularyLevel.immortalCultivation: 'Reserve Meridian',
    },
  ),
  'Hubungan': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Relasi',
      DaojiVocabularyLevel.gentleCultivation: 'Karma',
      DaojiVocabularyLevel.daoStream: 'Karma',
      DaojiVocabularyLevel.immortalCultivation: 'Karma',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Relasi',
      DaojiVocabularyLevel.gentleCultivation: 'Karma',
      DaojiVocabularyLevel.daoStream: 'Karma Stream',
      DaojiVocabularyLevel.immortalCultivation: 'Karmic Meridian',
    },
  ),
  'Emosi': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Pikiran & Emosi',
      DaojiVocabularyLevel.gentleCultivation: 'Mind',
      DaojiVocabularyLevel.daoStream: 'Mind',
      DaojiVocabularyLevel.immortalCultivation: 'Mind',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Pikiran & Emosi',
      DaojiVocabularyLevel.gentleCultivation: 'Mind',
      DaojiVocabularyLevel.daoStream: 'Mind Stream',
      DaojiVocabularyLevel.immortalCultivation: 'Mind Sea Meridian',
    },
  ),
  'Karir': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Kerja & Skill',
      DaojiVocabularyLevel.gentleCultivation: 'Mastery',
      DaojiVocabularyLevel.daoStream: 'Mastery',
      DaojiVocabularyLevel.immortalCultivation: 'Mastery',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Kerja & Skill',
      DaojiVocabularyLevel.gentleCultivation: 'Mastery',
      DaojiVocabularyLevel.daoStream: 'Mastery Stream',
      DaojiVocabularyLevel.immortalCultivation: 'Mastery Meridian',
    },
  ),
  'Rekreasi': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Rehat & Makna',
      DaojiVocabularyLevel.gentleCultivation: 'Spirit',
      DaojiVocabularyLevel.daoStream: 'Spirit',
      DaojiVocabularyLevel.immortalCultivation: 'Spirit',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Rehat & Makna',
      DaojiVocabularyLevel.gentleCultivation: 'Spirit',
      DaojiVocabularyLevel.daoStream: 'Spirit Stream',
      DaojiVocabularyLevel.immortalCultivation: 'Spirit Meridian',
    },
  ),
};
