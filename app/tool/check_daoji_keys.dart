
// ignore_for_file: avoid_print
import 'package:daoji/src/core/i18n/daoji_text_key.dart';
import 'package:daoji/src/core/i18n/daoji_text_resolver.dart';
import 'package:daoji/src/core/i18n/daoji_vocabulary_level.dart';

/// Run: dart run tool/check_daoji_keys.dart
void main() {
  var failed = 0;
  for (final key in DaojiTextKey.values) {
    final v = DaojiText.resolve(key, DaojiVocabularyLevel.mortal);
    if (v.trim().isEmpty || (v.startsWith('[[') && v.endsWith(']]'))) {
      print('MISSING mortal: ${key.name} -> $v');
      failed++;
    }
  }
  if (failed == 0) {
    print('OK: ${DaojiTextKey.values.length} keys resolve for mortal');
  } else {
    print('FAIL: $failed keys');
    throw StateError('daoji keys incomplete');
  }
}
