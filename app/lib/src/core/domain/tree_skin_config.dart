import 'app_constants.dart';

/// Defines skin and growth stage behavior for the conceptual tree UI.
class TreeSkinConfig {
  TreeSkinConfig._();

  static const Set<String> supportedSkins = {
    TreeSkin.defaultSkin,
    TreeSkin.sakura,
    TreeSkin.maple,
    TreeSkin.bonsai,
  };

  static String normalizeSkinId(String? skinId) {
    if (skinId == null || skinId.trim().isEmpty) {
      return TreeSkin.defaultSkin;
    }

    final normalized = skinId.trim();
    return supportedSkins.contains(normalized) ? normalized : TreeSkin.defaultSkin;
  }

  // ─── Growth stage names (ordered from early growth to mature) ───────────
  static const String stageSeed = 'seed';
  static const String stageSprout = 'sprout';
  static const String stageSeedling = 'seedling';
  static const String stageSapling = 'sapling';
  static const String stageYoung = 'young';
  static const String stageGrowing = 'growing';
  static const String stageEstablished = 'established';
  static const String stageBlooming = 'blooming';
  static const String stageFlourishing = 'flourishing';
  static const String stageMature = 'mature';
  static const String stageRecovery = 'recovery';

  /// Ordered list of growth stages (excludes recovery, which is a season).
  static const List<String> orderedStages = [
    stageSeed,
    stageSprout,
    stageSeedling,
    stageSapling,
    stageYoung,
    stageGrowing,
    stageEstablished,
    stageBlooming,
    stageFlourishing,
    stageMature,
  ];

  /// Upper-exclusive day threshold for each stage.
  static const Map<String, int> _stageUpperBound = {
    stageSeed: 1, // day 0 only
    stageSprout: 8, // 1–7
    stageSeedling: 18, // 8–17
    stageSapling: 30, // 18–29
    stageYoung: 42, // 30–41
    stageGrowing: 54, // 42–53
    stageEstablished: 66, // 54–65
    stageBlooming: 78, // 66–77
    stageFlourishing: 90, // 78–89
    // mature: 90+
  };

  /// Determine the growth stage based on cumulative days and season.
  static String getStage(int cumulativeDays, String season) {
    if (season == Season.recovery) return stageRecovery;
    for (final stage in orderedStages) {
      final upper = _stageUpperBound[stage];
      if (upper == null) return stage; // mature (no upper bound)
      if (cumulativeDays < upper) return stage;
    }
    return stageMature;
  }

  /// Human-readable stage label for UI display.
  static String getStageLabel(int cumulativeDays, String season) {
    if (season == Season.recovery) {
      return 'Pohon Istirahat dan Pemulihan ❄️';
    }

    final stage = getStage(cumulativeDays, season);
    return switch (stage) {
      stageSeed => 'Benih — Awal Perjalanan 🌰',
      stageSprout => 'Tunas Kecil (1–7 Hari) 🌱',
      stageSeedling => 'Bibit (8–17 Hari) 🌱',
      stageSapling => 'Batang Muda (18–29 Hari) 🌿',
      stageYoung => 'Pohon Muda (30–41 Hari) 🌿',
      stageGrowing => 'Tumbuh Pesat (42–53 Hari) 🌳',
      stageEstablished => 'Pohon Mantap (54–65 Hari) 🌳',
      stageBlooming => 'Pohon Rimbun (66–77 Hari) 🌸',
      stageFlourishing => 'Pohon Subur (78–89 Hari) 🍃',
      stageMature => 'Pohon Dewasa (90+ Hari) 🌲',
      _ => 'Pohon',
    };
  }

  /// Progress bar value (0.0 to 1.0) of overall growth from seed → mature.
  static double getProgress(int cumulativeDays, String season) {
    if (season == Season.recovery) return 1.0;
    if (cumulativeDays <= 0) return 0.0;
    if (cumulativeDays >= 90) return 1.0;
    return (cumulativeDays / 90.0).clamp(0.0, 1.0);
  }

  /// Progress bar color per stage.
  static const Map<String, int> stageColors = {
    Season.recovery: 0xFF7CB9E8, // sky blue (recovery)
    stageSeed: 0xFFA8C5A0,
    stageSprout: 0xFF8FBF82,
    stageSeedling: 0xFF7BAC75,
    stageSapling: 0xFF6AA45F,
    stageYoung: 0xFF5A9B54,
    stageGrowing: 0xFF4C9249,
    stageEstablished: 0xFF3E8B47,
    stageBlooming: 0xFF34803F,
    stageFlourishing: 0xFF307A3A,
    stageMature: 0xFF2D6B38,
  };
}
