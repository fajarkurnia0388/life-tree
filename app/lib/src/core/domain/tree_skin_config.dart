import 'app_constants.dart';

/// Defines skin behavior for the conceptual tree UI.
class TreeSkinConfig {
  TreeSkinConfig._();

  static const Set<String> supportedSkins = {
    TreeSkin.defaultSkin,
    TreeSkin.sakura,
    TreeSkin.maple,
    TreeSkin.bonsai,
    TreeSkin.bambooImmortal,
    TreeSkin.peachBlossom,
    TreeSkin.ancientPine,
  };

  static String normalizeSkinId(String? skinId) {
    if (skinId == null || skinId.trim().isEmpty) {
      return TreeSkin.defaultSkin;
    }

    final normalized = skinId.trim();
    return supportedSkins.contains(normalized)
        ? normalized
        : TreeSkin.defaultSkin;
  }

  /// Progress bar value (0.0 to 1.0) for the conceptual tree view.
  static double getProgress(int cumulativeDays, String season) {
    if (season == Season.recovery) return 1.0;
    if (cumulativeDays <= 0) return 0.0;
    if (cumulativeDays >= 90) return 1.0;
    return (cumulativeDays / 90.0).clamp(0.0, 1.0);
  }

  /// Progress bar color for the conceptual tree view.
  static const Map<String, int> progressColors = {Season.recovery: 0xFF7CB9E8};
}
