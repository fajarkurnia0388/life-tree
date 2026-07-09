import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/db_provider.dart';
import '../../features/dashboard/dashboard_provider.dart';

class CalmTheme {
  // Daoji Premium Palette (Aligned with landing page)
  static const Color obsidian = Color(0xFF050807);
  static const Color daoSurface = Color(0xFF13231C);
  static const Color daoSurfaceElevated = Color(0xFF1A332A);
  static const Color daoJade = Color(0xFF6FAE90);
  static const Color daoJadeSoft = Color(0xFFB8DDC6);
  static const Color daoGold = Color(0xFFD8B56C);
  static const Color daoCream = Color(0xFFF2F6F0);
  static const Color daoMuted = Color(0xFFA8B8B0);

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
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDarkSage,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDarkSage,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDarkSage,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textDarkSage),
        bodyMedium: TextStyle(fontSize: 14, color: textDarkSage),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundCream,
        elevation: 0,
        iconTheme: IconThemeData(color: textDarkSage),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDarkSage,
          fontFamily: 'Inter',
        ),
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
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textLightSage,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textLightSage,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLightSage,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textLightSage),
        bodyMedium: TextStyle(fontSize: 14, color: textLightSage),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: backgroundDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textLightSage),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textLightSage,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  static ThemeData get fajarTheme {
    return lightTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF3EBF6),
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: const Color(0xFF907C9E),
        primaryContainer: const Color(0xFFD4C2DC),
      ),
    );
  }

  static ThemeData get siangTheme {
    return lightTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFEDF2F7),
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: const Color(0xFF4A7C9D),
        primaryContainer: const Color(0xFFA5C3D6),
      ),
    );
  }

  static ThemeData get senjaTheme {
    return lightTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFFDF5E6),
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: const Color(0xFFC78550),
        primaryContainer: const Color(0xFFEBC1A0),
      ),
    );
  }

  static ThemeData get malamTheme {
    return darkTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0A0F0D),
      colorScheme: darkTheme.colorScheme.copyWith(
        primary: const Color(0xFF55826B),
        primaryContainer: const Color(0xFF1E3A2F),
        surface: const Color(0xFF121B17),
      ),
    );
  }
}

final appThemeRawModeProvider = StreamProvider<String>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.userProfiles)..limit(1)).watch().map((profiles) {
    if (profiles.isEmpty) return 'System';
    return profiles.first.themeMode;
  });
});

final appThemeModeProvider = StreamProvider<ThemeMode>((ref) {
  final rawModeAsync = ref.watch(appThemeRawModeProvider);
  return rawModeAsync.when(
    data: (mode) {
      ThemeMode resolvedMode = ThemeMode.system;
      if (mode == 'Light') resolvedMode = ThemeMode.light;
      if (mode == 'Dark') resolvedMode = ThemeMode.dark;
      // 'Circadian' is deprecated - now handled by circadianEnabledProvider
      return Stream.value(resolvedMode);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final circadianEnabledProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(dbProvider);
  return (db.select(db.userProfiles)..limit(1)).watch().map((profiles) {
    if (profiles.isEmpty) return false;
    return profiles.first.circadianEnabled;
  });
});

final appDynamicThemeProvider = Provider<ThemeData>((ref) {
  final circadianAsync = ref.watch(circadianEnabledProvider);
  final circadianEnabled = circadianAsync.valueOrNull ?? false;
  
  final themeModeAsync = ref.watch(appThemeModeProvider);
  final themeMode = themeModeAsync.valueOrNull ?? ThemeMode.system;
  final devTimeOverride = ref.watch(devTimeOfDayOverrideProvider);

  // Determine base theme from themeMode
  ThemeData baseTheme;
  if (themeMode == ThemeMode.dark) {
    baseTheme = CalmTheme.darkTheme;
  } else {
    baseTheme = CalmTheme.lightTheme;
  }

  // If circadian is enabled, apply circadian palette overlay
  if (circadianEnabled || devTimeOverride != CelestialTime.auto) {
    CelestialTime activeTime = devTimeOverride;
    if (activeTime == CelestialTime.auto) {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 8) {
        activeTime = CelestialTime.morning;
      } else if (hour >= 8 && hour < 15) {
        activeTime = CelestialTime.noon;
      } else if (hour >= 15 && hour < 18) {
        activeTime = CelestialTime.sunset;
      } else {
        activeTime = CelestialTime.night;
      }
    }

    // Apply circadian tint to base theme
    switch (activeTime) {
      case CelestialTime.morning:
        return _applyCircadianTint(baseTheme, CalmTheme.fajarTheme);
      case CelestialTime.noon:
        return _applyCircadianTint(baseTheme, CalmTheme.siangTheme);
      case CelestialTime.sunset:
        return _applyCircadianTint(baseTheme, CalmTheme.senjaTheme);
      case CelestialTime.night:
      default:
        return _applyCircadianTint(baseTheme, CalmTheme.malamTheme);
    }
  }

  return baseTheme;
});

/// Apply circadian color palette to base theme while preserving brightness
ThemeData _applyCircadianTint(ThemeData base, ThemeData circadian) {
  return base.copyWith(
    primaryColor: circadian.primaryColor,
    scaffoldBackgroundColor: circadian.scaffoldBackgroundColor,
    colorScheme: base.colorScheme.copyWith(
      primary: circadian.colorScheme.primary,
      primaryContainer: circadian.colorScheme.primaryContainer,
    ),
  );
}
