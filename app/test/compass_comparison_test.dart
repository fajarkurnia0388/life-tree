import 'package:flutter_test/flutter_test.dart';
import 'package:life_tree/src/features/profile/widgets/compass_comparison_dialog.dart';

void main() {
  group('Compass Comparison Tests', () {
    test('compareCompass returns empty list when both lists are empty', () {
      final res = compareCompass(declaredValues: [], revealedValues: []);
      expect(res.aligned, isEmpty);
      expect(res.declaredOnly, isEmpty);
      expect(res.revealedOnly, isEmpty);
    });

    test('compareCompass detects fully aligned values', () {
      final res = compareCompass(
        declaredValues: ['Kesehatan', 'Kebebasan', 'Keluarga'],
        revealedValues: ['Kebebasan', 'Kesehatan', 'Keluarga'],
      );
      expect(res.aligned, containsAll(['Kesehatan', 'Kebebasan', 'Keluarga']));
      expect(res.declaredOnly, isEmpty);
      expect(res.revealedOnly, isEmpty);
    });

    test('compareCompass categorizes declaredOnly and revealedOnly correctly', () {
      final res = compareCompass(
        declaredValues: ['Kesehatan', 'Kebebasan', 'Disiplin'],
        revealedValues: ['Kebebasan', 'Stabilitas', 'Kejujuran'],
      );
      expect(res.aligned, equals(['Kebebasan']));
      expect(res.declaredOnly, containsAll(['Kesehatan', 'Disiplin']));
      expect(res.revealedOnly, containsAll(['Stabilitas', 'Kejujuran']));
    });

    test('compareCompass handles spaces and trim correctly', () {
      final res = compareCompass(
        declaredValues: [' Kesehatan ', 'Kebebasan'],
        revealedValues: ['Kesehatan', ' Kebebasan '],
      );
      expect(res.aligned, containsAll(['Kesehatan', 'Kebebasan']));
      expect(res.declaredOnly, isEmpty);
      expect(res.revealedOnly, isEmpty);
    });
  });
}
