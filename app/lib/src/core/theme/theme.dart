import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/db_provider.dart';

class CalmTheme {
  // Light Mode Palette (Aligned with Landing Page)
  static const Color primarySage = Color(0xFF7C9A72);
  static const Color primaryContainer = Color(0xFFA3BC99);
  static const Color secondaryBlue = Color(0xFF6B8F9E);
  static const Color backgroundCream = Color(0xFFF5F0E8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDarkSage = Color(0xFF2C2C2C);
  static const Color alertMutedRed = Color(0xFFC97A7A);

  // Dark Mode Palette
  static const Color primarySageDark = Color(0xFF8BB599);
  static const Color primaryContainerDark = Color(0xFF2E4237);
  static const Color secondaryBlueDark = Color(0xFF9CC0DE);
  static const Color backgroundDark = Color(0xFF19241E);
  static const Color surfaceDark = Color(0xFF213028);
  static const Color textLightSage = Color(0xFFE4ECE8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primarySage,
        primaryContainer: primaryContainer,
        secondary: secondaryBlue,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onSurface: textDarkSage,
        onPrimaryContainer: textDarkSage,
        error: alertMutedRed,
      ),
      scaffoldBackgroundColor: backgroundCream,
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEDE6D8), width: 1),
        ),
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDarkSage),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textDarkSage),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textDarkSage),
        bodyLarge: TextStyle(fontSize: 16, color: textDarkSage),
        bodyMedium: TextStyle(fontSize: 14, color: textDarkSage),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundCream,
        elevation: 0,
        iconTheme: IconThemeData(color: textDarkSage),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDarkSage, fontFamily: 'Inter'),
      ),
      buttonTheme: const ButtonThemeData(
        minWidth: 88,
        height: 48, // Touch target guideline
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primarySageDark,
        primaryContainer: primaryContainerDark,
        secondary: secondaryBlueDark,
        surface: surfaceDark,
        onPrimary: backgroundDark,
        onSurface: textLightSage,
        onPrimaryContainer: textLightSage,
        error: alertMutedRed,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2C3E34), width: 1),
        ),
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textLightSage),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textLightSage),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textLightSage),
        bodyLarge: TextStyle(fontSize: 16, color: textLightSage),
        bodyMedium: TextStyle(fontSize: 14, color: textLightSage),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: backgroundDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textLightSage),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textLightSage, fontFamily: 'Inter'),
      ),
      buttonTheme: const ButtonThemeData(
        minWidth: 88,
        height: 48, // Touch target guideline
      ),
    );
  }
}

final appThemeModeProvider = StreamProvider<ThemeMode>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.userProfiles)..limit(1)).watch().map((profiles) {
    if (profiles.isEmpty) return ThemeMode.system;
    final mode = profiles.first.themeMode;
    if (mode == 'Light') return ThemeMode.light;
    if (mode == 'Dark') return ThemeMode.dark;
    return ThemeMode.system;
  });
});
