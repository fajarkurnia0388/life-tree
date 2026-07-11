import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daoji/src/core/theme/theme.dart';
import 'package:daoji/src/features/dashboard/dashboard_provider.dart';

void main() {
  test('circadian period changes only at configured boundaries', () {
    expect(celestialTimeFor(DateTime(2026, 7, 11, 4, 59)), CelestialTime.night);
    expect(celestialTimeFor(DateTime(2026, 7, 11, 5)), CelestialTime.morning);
    expect(celestialTimeFor(DateTime(2026, 7, 11, 8)), CelestialTime.noon);
    expect(celestialTimeFor(DateTime(2026, 7, 11, 15)), CelestialTime.sunset);
    expect(celestialTimeFor(DateTime(2026, 7, 11, 18)), CelestialTime.night);
  });

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
