import 'app_constants.dart';
/// Maps (skinId, stage) pairs to asset paths.
/// Also defines growth stage thresholds.
///
/// Growth uses a 10-stage model (plus recovery) so that the visual transition
/// from day 0 → 100 feels smooth when crossfading between realistic image
/// assets. If a given stage asset has not been added yet, [getAssetPath] falls
/// back to the nearest available stage so the app never shows a broken image.
class TreeSkinConfig {
  TreeSkinConfig._();

  // ─── Growth stage names (ordered young → old) ──────────────────────────────
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
  /// e.g. sprout applies for days 1..7 (cumulativeDays < 8).
  /// The last stage (mature) has no upper bound.
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
    if (season == Season.recovery) return 'Pohon Istirahat Bersalju ❄️';
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

  /// Returns the asset path for the given skin and stage, with a fallback to the
  /// nearest available stage if the exact asset has not been generated yet.
  static String getAssetPath(String skinId, String stage) {
    final skin = _normalizeSkin(skinId);
    final effectiveStage = _resolveStage(skin, stage);
    return 'assets/trees/$skin/$effectiveStage.png';
  }

  /// Set of stages for which assets actually exist on disk per skin.
  /// Update this map as you add the realistic PNG assets. Stages NOT listed
  /// here will fall back to the nearest available older stage (then mature).
  ///
  /// NOTE: Right now only the original 5-stage set ships in pubspec assets.
  /// As you drop in the new multi-stage realistic renders, add their names here.
  static const Map<String, Set<String>> _availableStages = {
    'default': {
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
    },
    'sakura': {stageSeed, stageSprout, stageSapling, stageBlooming, stageMature},
    'maple': {stageSeed, stageSprout, stageSapling, stageBlooming, stageMature},
    'bonsai': {stageSeed, stageSprout, stageSapling, stageBlooming, stageMature},
  };

  /// Resolve the requested stage to one that actually has an asset.
  /// Strategy: if the exact stage is missing, walk *backwards* through the
  /// ordered stages to the closest younger stage that exists; if none, use the
  /// closest older one; recovery → mature.
  static String _resolveStage(String skin, String stage) {
    final available = _availableStages[skin] ?? const {stageMature};

    if (stage == stageRecovery) {
      return available.contains(stageRecovery) ? stageRecovery : stageMature;
    }

    if (available.contains(stage)) return stage;

    final idx = orderedStages.indexOf(stage);
    if (idx == -1) return stageMature;

    // Walk backwards (younger) for the nearest existing stage.
    for (int i = idx; i >= 0; i--) {
      if (available.contains(orderedStages[i])) return orderedStages[i];
    }
    // Walk forwards (older) as a last resort.
    for (int i = idx + 1; i < orderedStages.length; i++) {
      if (available.contains(orderedStages[i])) return orderedStages[i];
    }
    return stageMature;
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

  /// Progress bar value (0.0 to 1.0) of overall growth from seed → mature.
  /// Smoothly interpolated across the whole 0–90 day journey.
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
