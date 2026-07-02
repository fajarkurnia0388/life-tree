import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/dashboard_provider.dart';
import 'cultivation_constants.dart';
import 'cultivation_layer.dart';

/// Provides the active 3-level language setting for cultivation terminology.
///
/// Phase 0 keeps this in memory. A later phase can persist it in UserProfiles
/// with a vocabularyMode field.
final cultivationLanguageLevelProvider =
    StateProvider<CultivationLanguageLevel>(
      (ref) => CultivationLanguageLevel.hybrid,
    );

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
