import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import 'dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/theme/theme.dart';
import '../onboarding/onboarding_view.dart';
import 'widgets/radar_chart_widget.dart';
import '../habit/services/habit_log_service.dart';
import 'widgets/season_badge_widget.dart';
import 'sheets/friction_intervention_sheet.dart';
import 'widgets/tree_display_widget.dart';
import 'widgets/skin_shop_bottom_sheet.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  String _selectedDomainFilter = 'Semua';

  Color _getDomainColor(String? domain) {
    switch (domain) {
      case 'Tubuh':
        return const Color(0xFF6B8E78); // Forest Sage
      case 'Keuangan':
        return const Color(0xFFC29B38); // Soft Gold
      case 'Hubungan':
        return const Color(0xFFC78585); // Muted Rose
      case 'Emosi':
        return const Color(0xFF8595C7); // Periwinkle Indigo
      case 'Karir':
        return const Color(0xFF6CA8B5); // Calm Teal
      case 'Rekreasi':
        return const Color(0xFFD49E6A); // Warm Apricot
      default:
        return const Color(0xFF6B8E78); // Default Sage
    }
  }


  String _getDomainEmoji(String domain) {
    switch (domain) {
      case 'Tubuh': return '🏃';
      case 'Keuangan': return '💰';
      case 'Hubungan': return '🤝';
      case 'Emosi': return '🧠';
      case 'Karir': return '📚';
      case 'Rekreasi': return '🎮';
      default: return '🌱';
    }
  }

  Future<void> _toggleHabit(BuildContext context, Habit habit, HabitLog? log) async {
    final service = ref.read(habitLogServiceProvider);
    final now = DateTime.now();

    try {
      if (log != null && log.status == 'Done') {
        // Uncheck habit via service (safe delete + decrement)
        await service.markUnchecked(habit: habit, log: log);
      } else {
        // Check habit via service (safe upsert to Done)
        await service.markDone(habit: habit, date: now);
      }
      ref.invalidate(dashboardDataProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status kebiasaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Opens the Friction Intervention sheet when user taps "Tidak Sanggup"
  void _showFrictionIntervention(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FrictionInterventionSheet(habit: habit);
      },
    ).then((_) {
      ref.invalidate(dashboardDataProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeTree OS'),
      ),
      body: dataAsync.when(
        data: (data) {

          // Filter habits today based on the selected focus domain
          final filteredHabits = _selectedDomainFilter == 'Semua'
              ? data.habitsToday
              : data.habitsToday.where((hwl) => hwl.habit.domainTag == _selectedDomainFilter).toList();

          // Calculate dynamic Action of the Day inside the filtered view
          Habit? activeActionOfTheDay;
          if (_selectedDomainFilter == 'Semua') {
            activeActionOfTheDay = data.actionOfTheDay;
          } else {
            Map<String, dynamic> domainScores = {};
            if (data.profile.latestDomainScores != null) {
              try {
                domainScores = jsonDecode(data.profile.latestDomainScores!);
              } catch (_) {}
            }
            double highestPriority = -1.0;
            final uncompletedFiltered = filteredHabits.where((hwl) => hwl.log?.status != 'Done').toList();
            for (final hwl in uncompletedFiltered) {
              final habit = hwl.habit;
              final domain = habit.domainTag ?? 'Tubuh';
              final domainScoreVal = domainScores[domain] ?? 5;
              final domainScore = (domainScoreVal is num) ? domainScoreVal.toDouble() : 5.0;
              final domainDeficit = 10.0 - domainScore;

              final totalLoad = habit.initiationFriction + habit.energyCost;
              final score = (domainDeficit * habit.impactScore) / (totalLoad > 0 ? totalLoad : 1);
              if (score > highestPriority) {
                highestPriority = score;
                activeActionOfTheDay = habit;
              }
            }
          }

          final activeColor = _selectedDomainFilter == 'Semua' ? theme.colorScheme.primary : _getDomainColor(_selectedDomainFilter);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardDataProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Season status
                  SeasonBadgeWidget(season: data.season),
                  const SizedBox(height: 12),

                  // 2. Tree Vitality
                  TreeVitalityCard(
                    skinId: data.profile.selectedSkin,
                    cumulativeDays: data.cumulativeDays,
                    season: data.season,
                    onSkinShopTap: () => _showSkinShop(context, ref, data.profile),
                    activeDomainColor: _selectedDomainFilter == 'Semua' ? null : _getDomainColor(_selectedDomainFilter),
                  ),
                  const SizedBox(height: 16),
                  
                  // Radar Chart Keseimbangan
                  _buildRadarChartCard(data),
                  const SizedBox(height: 16),

                  // 3. Action of the Day / Celebration State
                  if (data.allDone)
                    _buildCelebrationCard(theme)
                  else if (activeActionOfTheDay != null)
                    _buildActionOfTheDayCard(context, ref, theme, activeActionOfTheDay, data)
                  else
                    _buildNoActionsCard(theme),
                  const SizedBox(height: 24),

                  // 4. Other habits list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jadwal Kebiasaan Hari Ini',
                        style: theme.textTheme.titleLarge,
                      ),
                      if (_selectedDomainFilter != 'Semua')
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedDomainFilter = 'Semua';
                            });
                          },
                          icon: const Icon(Icons.clear, size: 14),
                          label: const Text('Reset', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: activeColor,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (filteredHabits.isEmpty)
                    _buildEmptyDomainHabitsCard(theme, context, _selectedDomainFilter)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredHabits.length,
                      itemBuilder: (context, index) {
                        final item = filteredHabits[index];
                        final isAction = activeActionOfTheDay?.habitId == item.habit.habitId;
                        return _buildHabitItemTile(context, ref, theme, item, isAction);
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Terjadi kesalahan: $err'),
        ),
      ),
    );
  }



  void _showSkinShop(BuildContext context, WidgetRef ref, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TreeSkinShopBottomSheet(
          profile: profile,
          onSuccess: () {
            ref.invalidate(dashboardDataProvider);
          },
        );
      },
    );
  }

  Widget _buildRadarChartCard(DashboardData data) {
    Map<String, double> scores = {
      'Tubuh': 5.0,
      'Keuangan': 3.0,
      'Hubungan': 3.0,
      'Emosi': 3.0,
      'Karir': 3.0,
      'Rekreasi': 3.0,
    };

    try {
      final jsonStr = data.profile.latestDomainScores;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> parsed = jsonDecode(jsonStr);
        parsed.forEach((key, value) {
          final numVal = value as num;
          if (scores.containsKey(key)) {
            scores[key] = numVal.toDouble();
          }
        });
      }
    } catch (_) {}

    final List<String> domains = ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
    for (final domain in domains) {
      final domainHabits = data.habitsToday.where((h) => h.habit.domainTag == domain);
      final completedHabits = domainHabits.where((h) => h.log?.status == 'Done');
      if (domainHabits.isNotEmpty) {
        final baselineScore = scores[domain] ?? 5.0;
        final dailyRatio = completedHabits.length / domainHabits.length;
        final dailyScore = dailyRatio * 10.0;
        scores[domain] = (baselineScore * 0.7 + dailyScore * 0.3).clamp(1.0, 10.0);
      }
    }

    final isDevMode = data.profile.isDeveloperMode;

    final activeDomains = <String>{'Tubuh'};
    if (isDevMode) {
      activeDomains.addAll(['Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi']);
    } else {
      try {
        final jsonStr = data.profile.latestDomainScores;
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final Map<String, dynamic> parsed = jsonDecode(jsonStr);
          activeDomains.addAll(parsed.keys);
        }
      } catch (_) {}
      for (final hwl in data.habitsToday) {
        if (hwl.habit.domainTag != null) {
          activeDomains.add(hwl.habit.domainTag!);
        }
      }
    }

    return RadarChartWidget(
      scores: scores,
      activeDomains: activeDomains,
      selectedDomain: _selectedDomainFilter == 'Semua' ? null : _selectedDomainFilter,
      onDomainSelected: (domain) {
        setState(() {
          _selectedDomainFilter = (_selectedDomainFilter == domain) ? 'Semua' : domain;
        });
      },
    );
  }



  Widget _buildCelebrationCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20.0),
        child: Column(
          children: [
            const Text('🌳✨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Hari ini milikmu. Pohonmu sedang tumbuh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua kebiasaan terjadwal untuk hari ini telah selesai dilingkari.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOfTheDayCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Habit habit,
    DashboardData data,
  ) {
    final hwl = data.habitsToday.firstWhere((item) => item.habit.habitId == habit.habitId);
    final domainColor = _getDomainColor(habit.domainTag);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: domainColor.withOpacity(isDark ? 0.08 : 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: domainColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: domainColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'ACTION OF THE DAY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              habit.title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  avatar: Text(_getDomainEmoji(habit.domainTag ?? 'Tubuh')),
                  label: Text(habit.domainTag ?? 'Tubuh'),
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'Beban: ${habit.initiationFriction + habit.energyCost} Poin',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleHabit(context, habit, hwl.log),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: domainColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(88, 48), // WCAG touch target
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tandai Selesai'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showFrictionIntervention(context, habit),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 48), // WCAG touch target
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                  child: const Text('Tidak Sanggup', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActionsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('🍃', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada kebiasaan yang terjadwal untuk hari ini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Gunakan waktu hari ini untuk beristirahat atau tambahkan kebiasaan baru.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHabitsCard(ThemeData theme, BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/add-habit'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          child: Column(
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              const Text(
                'Belum ada kebiasaan aktif',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Ketuk untuk membuat kebiasaan pertamamu di domain Tubuh.',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitItemTile(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    HabitWithLog item,
    bool isAction,
  ) {
    final isDone = item.log?.status == 'Done';
    final domainColor = _getDomainColor(item.habit.domainTag);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAction
              ? domainColor.withOpacity(0.6)
              : theme.colorScheme.onSurface.withOpacity(0.08),
          width: isAction ? 1.5 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDone 
              ? (isDark ? Colors.transparent : Colors.grey[50]) 
              : domainColor.withOpacity(isDark ? 0.04 : 0.02),
          border: Border(
            left: BorderSide(color: domainColor, width: 4),
          ),
        ),
        child: CheckboxListTile(
          title: Text(
            item.habit.title,
            style: TextStyle(
              fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? theme.colorScheme.onSurface.withOpacity(0.6) : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: domainColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_getDomainEmoji(item.habit.domainTag ?? 'Tubuh')} ${item.habit.domainTag}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: domainColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Beban: ${item.habit.initiationFriction + item.habit.energyCost} | ${item.habit.frequency}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              if (item.habit.goalTag != null && item.habit.goalTag!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '🎯 Target: ${item.habit.goalTag}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          value: isDone,
          activeColor: domainColor,
          onChanged: (_) => _toggleHabit(context, item.habit, item.log),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }

  Widget _buildEmptyDomainHabitsCard(ThemeData theme, BuildContext context, String domain) {
    if (domain == 'Semua') {
      return _buildEmptyHabitsCard(theme, context);
    }
    final emoji = _getDomainEmoji(domain);
    final message = switch (domain) {
      'Keuangan' => 'Tidak ada kebiasaan finansial terjadwal hari ini. Tetap catat pengeluaran secara mandiri! 💰',
      'Hubungan' => 'Hari ini kosong dari agenda sosial. Sempatkan menyapa orang terdekat! 🤝',
      'Emosi' => 'Tidak ada latihan emosi terjadwal. Luangkan 1 menit untuk bernapas lega! 🧠',
      'Karir' => 'Fokus belajar hari ini selesai. Istirahatkan pikiran Anda untuk menyerap materi! 📚',
      'Rekreasi' => 'Tidak ada jadwal santai hari ini. Berikan jeda sejenak untuk hobi Anda! 🎮',
      _ => 'Tidak ada kebiasaan terjadwal untuk domain $domain hari ini. 🍃',
    };

    return Card(
      color: _getDomainColor(domain).withOpacity(0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _getDomainColor(domain).withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.8), height: 1.4),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/add-habit'),
              icon: const Icon(Icons.add, size: 16),
              label: Text('Tambah Kebiasaan $domain'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _getDomainColor(domain),
                side: BorderSide(color: _getDomainColor(domain)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }}
