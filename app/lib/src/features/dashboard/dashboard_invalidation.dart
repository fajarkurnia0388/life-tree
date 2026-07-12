import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_provider.dart';
import 'growth_map_provider.dart';

/// Helper untuk menginvalidasi seluruh dashboard graph.
/// Gunakan ini setiap kali ada mutasi yang mempengaruhi dashboard.
void invalidateDashboardGraph(WidgetRef ref) {
  ref.invalidate(cumulativeDaysProvider);
  ref.invalidate(currentSeasonProvider);
  ref.invalidate(habitsTodayProvider);
  ref.invalidate(actionOfTheDayProvider);
  ref.invalidate(overdueDecisionsProvider);
  ref.invalidate(wellBeingStatusProvider);
  ref.invalidate(growthMapProvider);
  ref.invalidate(dashboardDataProvider);
}
