import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/db_provider.dart';
import 'services/activity_heatmap_service.dart';

/// Provider untuk ActivityHeatmapService
final activityHeatmapServiceProvider = Provider<ActivityHeatmapService>((ref) {
  final db = ref.watch(dbProvider);
  return ActivityHeatmapService(db);
});

/// Provider untuk data activity heatmap (365 days)
final activityHeatmapDataProvider =
    FutureProvider.family<Map<DateTime, int>, String>((ref, userId) async {
      final service = ref.watch(activityHeatmapServiceProvider);
      return service.getActivityForLast365Days(userId);
    });
