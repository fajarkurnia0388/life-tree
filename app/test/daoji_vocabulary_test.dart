import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/core/i18n/daoji_text_key.dart';
import 'package:daoji/src/core/i18n/daoji_text_resolver.dart';
import 'package:daoji/src/core/i18n/daoji_vocabulary_level.dart';

void main() {
  group('DaojiVocabularyLevel', () {
    test('uses the mortal/human/earth/heaven labels', () {
      expect(DaojiVocabularyLevel.mortal.displayName, 'Mortal');
      expect(DaojiVocabularyLevel.human.displayName, 'Human');
      expect(DaojiVocabularyLevel.earth.displayName, 'Earth');
      expect(DaojiVocabularyLevel.heaven.displayName, 'Heaven');
    });

    test('parses valid values and falls back safely', () {
      expect(
        parseDaojiVocabularyLevel('practical'),
        DaojiVocabularyLevel.mortal,
      );
      expect(
        parseDaojiVocabularyLevel('gentleCultivation'),
        DaojiVocabularyLevel.human,
      );
      expect(
        parseDaojiVocabularyLevel('daoStream'),
        DaojiVocabularyLevel.earth,
      );
      expect(
        parseDaojiVocabularyLevel('immortalCultivation'),
        DaojiVocabularyLevel.heaven,
      );
      expect(parseDaojiVocabularyLevel(null), DaojiVocabularyLevel.mortal);
      expect(parseDaojiVocabularyLevel('broken'), DaojiVocabularyLevel.mortal);
      expect(parseDaojiVocabularyLevel('mortal'), DaojiVocabularyLevel.mortal);
      expect(parseDaojiVocabularyLevel('human'), DaojiVocabularyLevel.human);
      expect(parseDaojiVocabularyLevel('earth'), DaojiVocabularyLevel.earth);
      expect(parseDaojiVocabularyLevel('heaven'), DaojiVocabularyLevel.heaven);
    });
  });

  group('DaojiText', () {
    test('resolves navigation labels by vocabulary level', () {
      expect(
        DaojiText.resolve(DaojiTextKey.navHome, DaojiVocabularyLevel.mortal),
        'Home',
      );
      expect(
        DaojiText.resolve(DaojiTextKey.navHome, DaojiVocabularyLevel.earth),
        'Training Hub',
      );
      expect(
        DaojiText.resolve(DaojiTextKey.navHome, DaojiVocabularyLevel.heaven),
        'Void Sanctuary',
      );
    });

    test('keeps safety text consistent across all levels', () {
      final values = DaojiVocabularyLevel.values
          .map((level) => DaojiText.resolve(DaojiTextKey.safetyTitle, level))
          .toSet();
      expect(values.length, 1);
      expect(values.single, 'Safety Support');
    });

    test('maps domain keys to current vocabulary labels', () {
      expect(
        DaojiText.domainLabel('Hubungan', DaojiVocabularyLevel.earth),
        'Bonding Path',
      );
      expect(
        DaojiText.domainLabel('Hubungan', DaojiVocabularyLevel.heaven),
        'Karma Path',
      );
      expect(
        DaojiText.domainLabel('Rekreasi', DaojiVocabularyLevel.earth),
        'Spirit Path',
      );
    });

    test('applies placeholder parameters', () {
      expect(
        DaojiText.resolve(
          DaojiTextKey.safetyCall,
          DaojiVocabularyLevel.mortal,
          params: {'number': '119'},
        ),
        'Call 119',
      );
    });
  });
}
