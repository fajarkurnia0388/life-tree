import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// GitHub-style activity heatmap showing daily habit completion over 52 weeks
class ActivityHeatmapWidget extends StatelessWidget {
  final Map<DateTime, int> activityData;
  final List<DateTime> dateRange;

  const ActivityHeatmapWidget({
    super.key,
    required this.activityData,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aktivitas 52 Minggu Terakhir',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildLegend(theme, isDark),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeatmapGrid(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid(ThemeData theme, bool isDark) {
    // Organize dates into weeks (columns) and days (rows)
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < dateRange.length; i += 7) {
      final weekDates = dateRange.skip(i).take(7).toList();
      weeks.add(weekDates);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month labels
          _buildMonthLabels(weeks, theme),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDayLabels(theme),
              const SizedBox(width: 8),
              SizedBox(
                height: 105,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((week) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: week.map((date) {
                          return _buildDayCell(date, theme, isDark);
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthLabels(List<List<DateTime>> weeks, ThemeData theme) {
    final labels = <Widget>[];
    String? currentMonth;
    int segmentStart = 0;

    for (int i = 0; i <= weeks.length; i++) {
      final monthLabel = i < weeks.length
          ? weeks[i].first.month.toString()
          : null;

      if (i == weeks.length || monthLabel != currentMonth) {
        if (currentMonth != null) {
          final weekCount = i - segmentStart;
          final labelWidth = (12 * weekCount) + (3 * (weekCount - 1));
          labels.add(
            SizedBox(
              width: labelWidth.toDouble(),
              child: Text(
                currentMonth,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }
        if (i < weeks.length) {
          currentMonth = monthLabel;
          segmentStart = i;
        }
      }
    }

    return Row(
      children: [
        const SizedBox(width: 38), // Offset for day labels + gap
        ...labels,
      ],
    );
  }

  Widget _buildDayLabels(ThemeData theme) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const rowHeight = 15.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (index) {
        return SizedBox(
          height: rowHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                days[index],
                textAlign: TextAlign.left,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(DateTime date, ThemeData theme, bool isDark) {
    final count = activityData[date] ?? 0;
    final level = _getActivityLevel(count);
    final color = _getColorForLevel(level, isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Tooltip(
        message: _getTooltipText(date, count),
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Text(
          'Sedikit',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        ...List.generate(4, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _getColorForLevel(index, isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          'Banyak',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  int _getActivityLevel(int count) {
    if (count == 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    return 3;
  }

  Color _getColorForLevel(int level, bool isDark) {
    if (isDark) {
      // Dark mode colors
      switch (level) {
        case 0:
          return const Color(0xFF161B22); // GitHub dark empty
        case 1:
          return const Color(0xFF0E4429); // Light green
        case 2:
          return const Color(0xFF006D32); // Medium green
        case 3:
          return const Color(0xFF26A641); // Dark green
        default:
          return const Color(0xFF161B22);
      }
    } else {
      // Light mode colors
      switch (level) {
        case 0:
          return const Color(0xFFEBEDF0); // GitHub light empty
        case 1:
          return const Color(0xFF9BE9A8); // Light green
        case 2:
          return const Color(0xFF40C463); // Medium green
        case 3:
          return const Color(0xFF30A14E); // Dark green
        default:
          return const Color(0xFFEBEDF0);
      }
    }
  }

  String _getTooltipText(DateTime date, int count) {
    final dateStr = DateFormat('d MMM yyyy').format(date);
    if (count == 0) {
      return '$dateStr\nTidak ada aktivitas';
    }
    return '$dateStr\n$count kebiasaan selesai';
  }
}
