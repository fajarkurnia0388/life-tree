import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daoji/src/core/theme/theme.dart';

void main() {
  test('Circadian Theme mapping returns correct styles based on hours', () {
    // Fajar: 5 - 8
    final fajarTheme = CalmTheme.fajarTheme;
    expect(fajarTheme.scaffoldBackgroundColor, const Color(0xFFF3EBF6));

    // Siang: 8 - 15
    final siangTheme = CalmTheme.siangTheme;
    expect(siangTheme.scaffoldBackgroundColor, const Color(0xFFEDF2F7));

    // Senja: 15 - 18
    final senjaTheme = CalmTheme.senjaTheme;
    expect(senjaTheme.scaffoldBackgroundColor, const Color(0xFFFDF5E6));

    // Malam: other hours
    final malamTheme = CalmTheme.malamTheme;
    expect(malamTheme.scaffoldBackgroundColor, const Color(0xFF0A0F0D));
  });
}
