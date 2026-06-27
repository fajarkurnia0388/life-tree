/// Maps (skinId, stage) pairs to asset paths.
/// Also defines growth stage thresholds.
class TreeSkinConfig {
  TreeSkinConfig._();

  // Growth stage names
  static const String stageSeed = 'seed';
  static const String stageSprout = 'sprout';
  static const String stageSapling = 'sapling';
  static const String stageBlooming = 'blooming';
  static const String stageMature = 'mature';
  static const String stageRecovery = 'recovery';

  /// Determine the growth stage based on cumulative days and season.
  static String getStage(int cumulativeDays, String season) {
    if (season == 'Recovery') return stageRecovery;
    if (cumulativeDays == 0) return stageSeed;
    if (cumulativeDays < 8) return stageSprout;
    if (cumulativeDays < 30) return stageSapling;
    if (cumulativeDays < 60) return stageBlooming;
    return stageMature;
  }

  /// Human-readable stage label for UI display.
  static String getStageLabel(int cumulativeDays, String season) {
    if (season == 'Recovery') return 'Pohon Istirahat Bersalju ❄️';
    if (cumulativeDays == 0) return 'Benih — Awal Perjalanan 🌰';
    if (cumulativeDays < 8) return 'Tunas Kecil (0–7 Hari) 🌱';
    if (cumulativeDays < 30) return 'Batang Muda (8–29 Hari) 🌿';
    if (cumulativeDays < 60) return 'Pohon Mekar (30–59 Hari) 🌸';
    return 'Pohon Dewasa (60+ Hari) 🌲';
  }

  /// Returns the asset path for the given skin and stage.
  /// Falls back to [stageMature] if the specific stage asset is missing.
  static String getAssetPath(String skinId, String stage) {
    final skin = _normalizeSkin(skinId);
    final effectiveStage = _resolveStage(stage);
    return 'assets/trees/$skin/$effectiveStage.png';
  }

  /// Fallback chain: recovery → mature if recovery.png is missing for now.
  static String _resolveStage(String stage) {
    // recovery images will be added in next asset batch; use mature as fallback
    if (stage == stageRecovery) return stageMature;
    return stage;
  }

  static String _normalizeSkin(String skinId) {
    switch (skinId) {
      case 'Sakura':
        return 'sakura';
      case 'Maple':
        return 'maple';
      case 'Bonsai':
        return 'bonsai';
      default:
        return 'default';
    }
  }

  /// Progress bar value (0.0 to 1.0) within the current stage.
  static double getProgress(int cumulativeDays, String season) {
    if (season == 'Recovery') return 1.0;
    if (cumulativeDays == 0) return 0.0;
    if (cumulativeDays < 8) return cumulativeDays / 8.0;
    if (cumulativeDays < 30) return (cumulativeDays - 7) / 22.0;
    if (cumulativeDays < 60) return (cumulativeDays - 30) / 30.0;
    return 1.0;
  }

  /// Progress bar color per season.
  static const Map<String, int> stageColors = {
    'Recovery': 0xFF7CB9E8,  // sky blue (recovery)
    'seed':     0xFFA8C5A0,  // light sage
    'sprout':   0xFF7BAC75,  // fresh green
    'sapling':  0xFF5A9B54,  // medium green
    'blooming': 0xFF3E8B47,  // deep green
    'mature':   0xFF2D6B38,  // rich forest green
  };
}
