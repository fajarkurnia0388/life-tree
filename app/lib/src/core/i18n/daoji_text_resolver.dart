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
      DaojiVocabularyLevel.practical: 'Physical',
      DaojiVocabularyLevel.gentleCultivation: 'Physical',
      DaojiVocabularyLevel.daoStream: 'Physical',
      DaojiVocabularyLevel.immortalCultivation: 'Physical',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Physical Path',
      DaojiVocabularyLevel.gentleCultivation: 'Physical Path',
      DaojiVocabularyLevel.daoStream: 'Physical Path',
      DaojiVocabularyLevel.immortalCultivation: 'Physical Path',
    },
  ),
  'Keuangan': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Material',
      DaojiVocabularyLevel.gentleCultivation: 'Material',
      DaojiVocabularyLevel.daoStream: 'Material',
      DaojiVocabularyLevel.immortalCultivation: 'Material',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Material Path',
      DaojiVocabularyLevel.gentleCultivation: 'Material Path',
      DaojiVocabularyLevel.daoStream: 'Material Path',
      DaojiVocabularyLevel.immortalCultivation: 'Material Path',
    },
  ),
  'Hubungan': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Bonding',
      DaojiVocabularyLevel.gentleCultivation: 'Bonding',
      DaojiVocabularyLevel.daoStream: 'Bonding',
      DaojiVocabularyLevel.immortalCultivation: 'Bonding',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Bonding Path',
      DaojiVocabularyLevel.gentleCultivation: 'Bonding Path',
      DaojiVocabularyLevel.daoStream: 'Bonding Path',
      DaojiVocabularyLevel.immortalCultivation: 'Bonding Path',
    },
  ),
  'Emosi': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Mind',
      DaojiVocabularyLevel.gentleCultivation: 'Mind',
      DaojiVocabularyLevel.daoStream: 'Mind',
      DaojiVocabularyLevel.immortalCultivation: 'Mind',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Mind Path',
      DaojiVocabularyLevel.gentleCultivation: 'Mind Path',
      DaojiVocabularyLevel.daoStream: 'Mind Path',
      DaojiVocabularyLevel.immortalCultivation: 'Mind Path',
    },
  ),
  'Karir': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Mastery',
      DaojiVocabularyLevel.gentleCultivation: 'Mastery',
      DaojiVocabularyLevel.daoStream: 'Mastery',
      DaojiVocabularyLevel.immortalCultivation: 'Mastery',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Mastery Path',
      DaojiVocabularyLevel.gentleCultivation: 'Mastery Path',
      DaojiVocabularyLevel.daoStream: 'Mastery Path',
      DaojiVocabularyLevel.immortalCultivation: 'Mastery Path',
    },
  ),
  'Rekreasi': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.practical: 'Spirit',
      DaojiVocabularyLevel.gentleCultivation: 'Spirit',
      DaojiVocabularyLevel.daoStream: 'Spirit',
      DaojiVocabularyLevel.immortalCultivation: 'Spirit',
    },
    fullLabels: {
      DaojiVocabularyLevel.practical: 'Spirit Path',
      DaojiVocabularyLevel.gentleCultivation: 'Spirit Path',
      DaojiVocabularyLevel.daoStream: 'Spirit Path',
      DaojiVocabularyLevel.immortalCultivation: 'Spirit Path',
    },
  ),
};
