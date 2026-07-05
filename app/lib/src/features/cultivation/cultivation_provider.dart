import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/i18n/daoji_vocabulary_level.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../dashboard/dashboard_provider.dart';
import 'cultivation_constants.dart';
import 'cultivation_layer.dart';

/// Legacy 3-level language setting used by older widgets.
///
/// New code should prefer DaojiVocabularyLevel from core/i18n. This provider is
/// kept for compatibility while the UI migrates from CultivationStrings to the
/// central DaojiText registry.
final cultivationLanguageLevelProvider =
    StateNotifierProvider<
      CultivationLanguageLevelNotifier,
      CultivationLanguageLevel
    >((ref) {
      final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
      return CultivationLanguageLevelNotifier(
        initialLevel: _legacyLevelFromVocabulary(vocabularyLevel),
      );
    });

CultivationLanguageLevel _legacyLevelFromVocabulary(
  DaojiVocabularyLevel vocabularyLevel,
) {
  return switch (vocabularyLevel) {
    DaojiVocabularyLevel.mortal => CultivationLanguageLevel.plain,
    DaojiVocabularyLevel.human => CultivationLanguageLevel.plain,
    DaojiVocabularyLevel.earth => CultivationLanguageLevel.hybrid,
    DaojiVocabularyLevel.heaven => CultivationLanguageLevel.full,
  };
}

/// Notifier for legacy cultivation language level.
class CultivationLanguageLevelNotifier
    extends StateNotifier<CultivationLanguageLevel> {
  CultivationLanguageLevelNotifier({
    CultivationLanguageLevel initialLevel = CultivationLanguageLevel.hybrid,
  }) : super(initialLevel);

  /// Cycle to next legacy level.
  void cycleLevel() {
    state = switch (state) {
      CultivationLanguageLevel.plain => CultivationLanguageLevel.hybrid,
      CultivationLanguageLevel.hybrid => CultivationLanguageLevel.full,
      CultivationLanguageLevel.full => CultivationLanguageLevel.plain,
    };
  }

  /// Set specific legacy level.
  void setLevel(CultivationLanguageLevel level) {
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
