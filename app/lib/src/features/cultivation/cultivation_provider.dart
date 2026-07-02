import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_provider.dart';
import 'cultivation_constants.dart';
import 'cultivation_layer.dart';

/// Provides the active 3-level language setting for cultivation terminology.
///
/// Reads from user profile's cultivationThemeEnabled flag. When theme is
/// disabled, forces Plain level. When enabled, allows user to cycle between
/// Plain/Hybrid/Full via settings (defaults to Hybrid).
final cultivationLanguageLevelProvider =
    StateNotifierProvider<
      CultivationLanguageLevelNotifier,
      CultivationLanguageLevel
    >((ref) {
      final dashboardAsync = ref.watch(dashboardDataProvider);

      // If user disabled cultivation theme entirely, force Plain
      final themeEnabled =
          dashboardAsync.whenOrNull(
            data: (data) => data.profile.cultivationThemeEnabled,
          ) ??
          true;

      return CultivationLanguageLevelNotifier(themeEnabled: themeEnabled);
    });

/// Notifier for cultivation language level that respects the theme toggle.
class CultivationLanguageLevelNotifier
    extends StateNotifier<CultivationLanguageLevel> {
  final bool themeEnabled;

  CultivationLanguageLevelNotifier({required this.themeEnabled})
    : super(
        themeEnabled
            ? CultivationLanguageLevel.hybrid
            : CultivationLanguageLevel.plain,
      );

  /// Cycle to next level (only if theme is enabled).
  void cycleLevel() {
    if (!themeEnabled) return;

    state = switch (state) {
      CultivationLanguageLevel.plain => CultivationLanguageLevel.hybrid,
      CultivationLanguageLevel.hybrid => CultivationLanguageLevel.full,
      CultivationLanguageLevel.full => CultivationLanguageLevel.plain,
    };
  }

  /// Set specific level (only if theme is enabled).
  void setLevel(CultivationLanguageLevel level) {
    if (!themeEnabled) return;
    state = level;
  }
}

/// Main cultivation layer provider.
///
/// This converts existing DashboardData into the cultivation interpretation
/// without requiring a database migration.
final cultivationProvider = Provider<AsyncValue<CultivationLayer>>((ref) {
  final dashboardAsync = ref.watch(dashboardDataProvider);

  return dashboardAsync.whenData(CultivationLayer.fromDashboard);
});

/// Convenience provider for the current cultivation season.
final cultivationSeasonProvider = Provider<AsyncValue<CultivationSeason>>((
  ref,
) {
  final cultivationAsync = ref.watch(cultivationProvider);
  return cultivationAsync.whenData((layer) => layer.season);
});

/// Convenience provider for the current realm.
final cultivationRealmProvider = Provider<AsyncValue<int>>((ref) {
  final cultivationAsync = ref.watch(cultivationProvider);
  return cultivationAsync.whenData((layer) => layer.realm);
});

/// Convenience provider for the user's current Qi level.
final cultivationQiLevelProvider = Provider<AsyncValue<double>>((ref) {
  final cultivationAsync = ref.watch(cultivationProvider);
  return cultivationAsync.whenData((layer) => layer.qiLevel);
});
