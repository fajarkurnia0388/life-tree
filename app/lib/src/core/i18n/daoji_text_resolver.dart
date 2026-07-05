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
      DaojiVocabularyLevel.heaven => const [
        DaojiVocabularyLevel.heaven,
        DaojiVocabularyLevel.earth,
        DaojiVocabularyLevel.human,
        DaojiVocabularyLevel.mortal,
      ],
      DaojiVocabularyLevel.earth => const [
        DaojiVocabularyLevel.earth,
        DaojiVocabularyLevel.human,
        DaojiVocabularyLevel.mortal,
      ],
      DaojiVocabularyLevel.human => const [
        DaojiVocabularyLevel.human,
        DaojiVocabularyLevel.mortal,
      ],
      DaojiVocabularyLevel.mortal => const [DaojiVocabularyLevel.mortal],
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
      return labels.shortLabels[level] ??
          labels.shortLabels[DaojiVocabularyLevel.earth]!;
    }
    return labels.fullLabels[level] ??
        labels.fullLabels[DaojiVocabularyLevel.earth]!;
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
      DaojiVocabularyLevel.mortal: 'Fisik',
      DaojiVocabularyLevel.human: 'Physical',
      DaojiVocabularyLevel.earth: 'Physical',
      DaojiVocabularyLevel.heaven: 'Meridian',
    },
    fullLabels: {
      DaojiVocabularyLevel.mortal: 'Jalur Fisik',
      DaojiVocabularyLevel.human: 'Physical Path',
      DaojiVocabularyLevel.earth: 'Physical Path',
      DaojiVocabularyLevel.heaven: 'Meridian Path',
    },
  ),
  'Keuangan': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.mortal: 'Uang',
      DaojiVocabularyLevel.human: 'Material',
      DaojiVocabularyLevel.earth: 'Material',
      DaojiVocabularyLevel.heaven: 'Reserve',
    },
    fullLabels: {
      DaojiVocabularyLevel.mortal: 'Jalur Keuangan',
      DaojiVocabularyLevel.human: 'Material Path',
      DaojiVocabularyLevel.earth: 'Material Path',
      DaojiVocabularyLevel.heaven: 'Reserve Path',
    },
  ),
  'Hubungan': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.mortal: 'Relasi',
      DaojiVocabularyLevel.human: 'Bonding',
      DaojiVocabularyLevel.earth: 'Bonding',
      DaojiVocabularyLevel.heaven: 'Karma',
    },
    fullLabels: {
      DaojiVocabularyLevel.mortal: 'Jalur Relasi',
      DaojiVocabularyLevel.human: 'Bonding Path',
      DaojiVocabularyLevel.earth: 'Bonding Path',
      DaojiVocabularyLevel.heaven: 'Karma Path',
    },
  ),
  'Emosi': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.mortal: 'Emosi',
      DaojiVocabularyLevel.human: 'Mind',
      DaojiVocabularyLevel.earth: 'Mind',
      DaojiVocabularyLevel.heaven: 'Shen',
    },
    fullLabels: {
      DaojiVocabularyLevel.mortal: 'Jalur Emosi',
      DaojiVocabularyLevel.human: 'Mind Path',
      DaojiVocabularyLevel.earth: 'Mind Path',
      DaojiVocabularyLevel.heaven: 'Shen Path',
    },
  ),
  'Karir': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.mortal: 'Karir',
      DaojiVocabularyLevel.human: 'Mastery',
      DaojiVocabularyLevel.earth: 'Mastery',
      DaojiVocabularyLevel.heaven: 'Dharma',
    },
    fullLabels: {
      DaojiVocabularyLevel.mortal: 'Jalur Karir',
      DaojiVocabularyLevel.human: 'Mastery Path',
      DaojiVocabularyLevel.earth: 'Mastery Path',
      DaojiVocabularyLevel.heaven: 'Dharma Path',
    },
  ),
  'Rekreasi': _DomainVocabularyLabels(
    shortLabels: {
      DaojiVocabularyLevel.mortal: 'Rekreasi',
      DaojiVocabularyLevel.human: 'Spirit',
      DaojiVocabularyLevel.earth: 'Spirit',
      DaojiVocabularyLevel.heaven: 'Qi',
    },
    fullLabels: {
      DaojiVocabularyLevel.mortal: 'Jalur Rekreasi',
      DaojiVocabularyLevel.human: 'Spirit Path',
      DaojiVocabularyLevel.earth: 'Spirit Path',
      DaojiVocabularyLevel.heaven: 'Qi Path',
    },
  ),
};
