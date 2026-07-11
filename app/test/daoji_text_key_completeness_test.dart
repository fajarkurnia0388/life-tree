import 'package:flutter_test/flutter_test.dart';
import 'package:daoji/src/core/i18n/daoji_text_key.dart';
import 'package:daoji/src/core/i18n/daoji_text_resolver.dart';
import 'package:daoji/src/core/i18n/daoji_vocabulary_level.dart';

void main() {
  group('DaojiTextKey completeness (mortal)', () {
    test('every key resolves to a non-empty, non-placeholder string', () {
      final missing = <String>[];
      final placeholders = <String>[];

      for (final key in DaojiTextKey.values) {
        final value = DaojiText.resolve(key, DaojiVocabularyLevel.mortal);
        if (value.trim().isEmpty) {
          missing.add(key.name);
        }
        if (value.startsWith('[[') && value.endsWith(']]')) {
          placeholders.add(key.name);
        }
      }

      expect(
        missing,
        isEmpty,
        reason: 'Empty mortal strings: $missing',
      );
      expect(
        placeholders,
        isEmpty,
        reason: 'Unresolved mortal keys (fallback [[name]]): $placeholders',
      );
    });
  });

  group('DaojiTextKey resolve all levels', () {
    test('no level returns empty string for any key', () {
      final bad = <String>[];
      for (final level in DaojiVocabularyLevel.values) {
        for (final key in DaojiTextKey.values) {
          final value = DaojiText.resolve(key, level);
          if (value.trim().isEmpty) {
            bad.add('${level.name}.${key.name}');
          }
        }
      }
      expect(bad, isEmpty, reason: 'Empty resolves: $bad');
    });
  });
}
