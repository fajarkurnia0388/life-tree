import 'package:drift/drift.dart';
import '../../../data/local_db/database.dart';

/// Service untuk mengagregasi aktivitas habit logs menjadi data heatmap
class ActivityHeatmapService {
  final AppDatabase _db;

  ActivityHeatmapService(this._db);

  /// Mengambil jumlah habits yang selesai per tanggal untuk 365 hari terakhir
  /// Returns Map<DateTime, int> dimana key adalah tanggal dan value adalah jumlah habits
  Future<Map<DateTime, int>> getActivityForLast365Days(String userId) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));

    // Query habit logs yang status 'Done' dalam 365 hari terakhir
    // Join dengan Habits table untuk filter by userId
    final query =
        _db.select(_db.habitLogs).join([
          innerJoin(
            _db.habits,
            _db.habits.habitId.equalsExp(_db.habitLogs.habitId),
          ),
        ])..where(
          _db.habits.userId.equals(userId) &
              _db.habitLogs.status.equals('Done') &
              _db.habitLogs.date.isBiggerOrEqualValue(startDate),
        );

    final results = await query.get();

    // Aggregate by date (ignore time)
    final Map<DateTime, int> activityMap = {};

    for (final row in results) {
      final log = row.readTable(_db.habitLogs);
      final dateOnly = DateTime(log.date.year, log.date.month, log.date.day);
      activityMap[dateOnly] = (activityMap[dateOnly] ?? 0) + 1;
    }

    return activityMap;
  }

  /// Helper untuk generate list of dates untuk 52 weeks (364 days)
  /// Dimulai dari hari yang sama minggu lalu, aligned ke hari Senin
  List<DateTime> generateLast52Weeks() {
    final today = DateTime.now();
    final todayWeekday = today.weekday; // 1 = Monday, 7 = Sunday

    // Find the most recent Sunday (end of week)
    final mostRecentSunday = today.subtract(Duration(days: todayWeekday % 7));

    // Go back 52 weeks (364 days) from that Sunday
    final startDate = mostRecentSunday.subtract(const Duration(days: 364));

    // Generate all dates from startDate to mostRecentSunday
    final List<DateTime> dates = [];
    for (int i = 0; i <= 364; i++) {
      final date = startDate.add(Duration(days: i));
      dates.add(DateTime(date.year, date.month, date.day));
    }

    return dates;
  }

  /// Helper untuk convert activity count ke level (0-4)
  /// Level digunakan untuk menentukan intensitas warna
  int getActivityLevel(int count) {
    if (count == 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    return 3;
  }
}
