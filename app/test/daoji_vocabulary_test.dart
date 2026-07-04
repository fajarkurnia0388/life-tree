import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/core/i18n/daoji_text_key.dart';
import 'package:daoji/src/core/i18n/daoji_text_resolver.dart';
import 'package:daoji/src/core/i18n/daoji_vocabulary_level.dart';

void main() {
  group('DaojiVocabularyLevel', () {
    test('parses valid values and falls back safely', () {
      expect(
        parseDaojiVocabularyLevel('practical'),
        DaojiVocabularyLevel.practical,
      );
      expect(
        parseDaojiVocabularyLevel('gentleCultivation'),
        DaojiVocabularyLevel.gentleCultivation,
      );
      expect(
        parseDaojiVocabularyLevel('daoStream'),
        DaojiVocabularyLevel.daoStream,
      );
      expect(
        parseDaojiVocabularyLevel('immortalCultivation'),
        DaojiVocabularyLevel.immortalCultivation,
      );
      expect(parseDaojiVocabularyLevel(null), DaojiVocabularyLevel.daoStream);
      expect(parseDaojiVocabularyLevel('broken'), DaojiVocabularyLevel.daoStream);
    });
  });

  group('DaojiText', () {
    test('resolves navigation labels by vocabulary level', () {
      expect(
        DaojiText.resolve(
          DaojiTextKey.navHome,
          DaojiVocabularyLevel.practical,
        ),
        'Beranda',
      );
      expect(
        DaojiText.resolve(
          DaojiTextKey.navHome,
          DaojiVocabularyLevel.daoStream,
        ),
        'Dao Tree',
      );
      expect(
        DaojiText.resolve(
          DaojiTextKey.navHome,
          DaojiVocabularyLevel.immortalCultivation,
        ),
        'Inner World',
      );
    });

    test('keeps safety text practical across all levels', () {
      final values = DaojiVocabularyLevel.values
          .map((level) => DaojiText.resolve(DaojiTextKey.safetyTitle, level))
          .toSet();
      expect(values.length, 1);
      expect(values.single, 'Dukungan Kesehatan Diri');
    });

    test('maps legacy domain keys to Six Dao Streams vocabulary', () {
      expect(
        DaojiText.domainLabel('Hubungan', DaojiVocabularyLevel.daoStream),
        'Karma Stream',
      );
      expect(
        DaojiText.domainLabel(
          'Hubungan',
          DaojiVocabularyLevel.immortalCultivation,
        ),
        'Karmic Meridian',
      );
      expect(
        DaojiText.domainLabel('Rekreasi', DaojiVocabularyLevel.daoStream),
        'Spirit Stream',
      );
    });

    test('applies placeholder parameters', () {
      expect(
        DaojiText.resolve(
          DaojiTextKey.safetyCall,
          DaojiVocabularyLevel.practical,
          params: {'number': '119'},
        ),
        'Hubungi 119',
      );
    });
  });
}
