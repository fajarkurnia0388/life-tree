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
import 'widgets/quick_actions_panel.dart';
import 'widgets/dashboard_alerts.dart';
import 'sheets/friction_intervention_sheet.dart';
import 'widgets/tree_display_widget.dart';
import 'widgets/skin_shop_bottom_sheet.dart';
import '../../core/domain/priority_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

  Color _getDomainBgColor(String? domain, bool isDark) {
    final baseColor = _getDomainColor(domain);
    return baseColor.withOpacity(isDark ? 0.08 : 0.04);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Habit Marketplace',
            onPressed: () => context.push('/marketplace'),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Safety Card',
            onPressed: () => context.push('/safety'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings / Export',
            onPressed: () => _showExportMenu(context, ref),
          ),
        ],
      ),
      body: dataAsync.when(
        data: (data) {
          final isDevMode = data.profile.isDeveloperMode;

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

                  // Life Compass (Core Values)
                  _buildLifeCompassWidget(context, data.profile),
                  const SizedBox(height: 16),

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

                  // Status Detail Domain Card
                  _buildDomainScoresCard(context, data),
                  const SizedBox(height: 16),

                  // Weekly Pulse Banner (Sunday or Developer Mode)
                  if (DateTime.now().weekday == DateTime.sunday || isDevMode) ...[
                    WeeklyPulseBanner(isSunday: DateTime.now().weekday == DateTime.sunday),
                    const SizedBox(height: 16),
                  ],

                  // Overdue Decisions Alert Card
                  if (data.hasOverdueDecisions) ...[
                    const OverdueDecisionAlert(),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 8),

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
                  const SizedBox(height: 32),

                  // 5. Quick actions panel
                  const QuickActionsPanel(),
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
  }

  Widget _buildDomainScoresCard(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
    final domainEmojis = {
      'Tubuh': '🏃',
      'Keuangan': '💰',
      'Hubungan': '🤝',
      'Emosi': '🧠',
      'Karir': '📚',
      'Rekreasi': '🎮',
    };

    final focusDomain = data.actionOfTheDay?.domainTag;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status Detail Domain 📊',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Detail kemajuan nilai dan tingkat keaktifan domain kehidupan.',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 16),
            ...domains.map((domain) {
              final isActive = activeDomains.contains(domain);
              final score = scores[domain] ?? 3.0;
              final emoji = domainEmojis[domain]!;
              final color = _getDomainColor(domain);
              final isFiltered = _selectedDomainFilter == domain;
              final isFocus = focusDomain == domain;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isFiltered 
                      ? color.withOpacity(isDark ? 0.12 : 0.06) 
                      : (isDark ? const Color(0xFF222C26) : const Color(0xFFFBFBFB)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFiltered ? color : Colors.transparent,
                    width: isFiltered ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          domain,
                          style: TextStyle(
                            fontWeight: isFiltered ? FontWeight.bold : FontWeight.w600,
                            color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        if (isFocus) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '🎯 FOKUS',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          isActive ? '${score.toStringAsFixed(1)} / 10' : 'Non-aktif (Soon)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isFiltered ? FontWeight.bold : FontWeight.normal,
                            color: isActive ? color : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isActive ? (score / 10.0) : 0.0,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        color: isActive ? color : Colors.grey[400],
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }



  void _toggleDeveloperMode(BuildContext context, WidgetRef ref, UserProfile profile, bool enable) async {
    final db = ref.read(dbProvider);
    try {
      await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
          .write(UserProfilesCompanion(
        isDeveloperMode: drift.Value(enable),
      ));

      ref.invalidate(dashboardDataProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable
                ? 'Mode Developer Aktif: Fitur simulasi dan semua skin terbuka!'
                : 'Mode Developer Nonaktif: Fitur simulasi ditutup.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah mode developer: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateThemeMode(BuildContext context, WidgetRef ref, UserProfile profile, String mode) async {
    final db = ref.read(dbProvider);
    try {
      await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
          .write(UserProfilesCompanion(themeMode: drift.Value(mode)));

      ref.invalidate(dashboardDataProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tema berhasil diubah ke ${mode == 'System' ? 'Sistem' : mode == 'Light' ? 'Terang' : 'Gelap'}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah tema: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCoreValuesDialog(BuildContext context, WidgetRef ref, UserProfile profile) {
    List<String> currentValues = ['', '', ''];
    try {
      final jsonStr = profile.coreValues;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final parsed = List<String>.from(jsonDecode(jsonStr));
        for (int i = 0; i < parsed.length && i < 3; i++) {
          currentValues[i] = parsed[i];
        }
      }
    } catch (_) {}

    final controller1 = TextEditingController(text: currentValues[0]);
    final controller2 = TextEditingController(text: currentValues[1]);
    final controller3 = TextEditingController(text: currentValues[2]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tentukan Kompas Hidup 🧭'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pilih 3 nilai inti hidup Anda (misal: Disiplin, Kebebasan, Kreativitas, Kesehatan, Cinta).',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nilai Cepat (Ketuk untuk isi):',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    'Kesehatan 🏃',
                    'Kebebasan 🗽',
                    'Keluarga 👨‍👩‍👧',
                    'Belajar 📚',
                    'Karir 💼',
                    'Kreativitas 🎨',
                    'Kedamaian ☮️',
                    'Disiplin 🛡️',
                  ].map((val) {
                    return ActionChip(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      label: Text(val, style: const TextStyle(fontSize: 10)),
                      onPressed: () {
                        if (controller1.text.trim().isEmpty) {
                          controller1.text = val;
                        } else if (controller2.text.trim().isEmpty) {
                          controller2.text = val;
                        } else if (controller3.text.trim().isEmpty) {
                          controller3.text = val;
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller1,
                  decoration: const InputDecoration(labelText: 'Nilai 1', hintText: 'Misal: Kesehatan'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller2,
                  decoration: const InputDecoration(labelText: 'Nilai 2', hintText: 'Misal: Kebebasan'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller3,
                  decoration: const InputDecoration(labelText: 'Nilai 3', hintText: 'Misal: Belajar'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final val1 = controller1.text.trim();
                final val2 = controller2.text.trim();
                final val3 = controller3.text.trim();
                final values = [val1, val2, val3].where((v) => v.isNotEmpty).toList();

                final db = ref.read(dbProvider);
                try {
                  await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
                      .write(UserProfilesCompanion(coreValues: drift.Value(jsonEncode(values))));
                  ref.invalidate(dashboardDataProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kompas hidup berhasil disimpan!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLifeCompassWidget(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    List<String> values = [];
    try {
      final jsonStr = profile.coreValues;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        values = List<String>.from(jsonDecode(jsonStr));
      }
    } catch (_) {}

    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: theme.colorScheme.primary.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.explore_outlined, size: 16, color: Colors.teal),
            const SizedBox(width: 4),
            Text(
              'Kompas Hidup: ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            ...values.map((v) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    v,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showExportMenu(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.read(dashboardDataProvider).valueOrNull;
    final profile = dashboardData?.profile;
    final isDevMode = profile != null && profile.isDeveloperMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Manajemen Data Lokal & Developer',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (profile != null) ...[
                    ListTile(
                      leading: const Icon(Icons.brightness_medium_rounded, color: Colors.amber),
                      title: const Text('Mode Tema Aplikasi'),
                      subtitle: const Text('Pilih gaya visual terang, gelap, atau sistem.'),
                      trailing: DropdownButton<String>(
                        value: profile.themeMode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'System', child: Text('Sistem')),
                          DropdownMenuItem(value: 'Light', child: Text('Terang')),
                          DropdownMenuItem(value: 'Dark', child: Text('Gelap')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            Navigator.pop(context);
                            _updateThemeMode(context, ref, profile, val);
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.balance_rounded, color: Colors.indigo),
                      title: const Text('Decision Journal (Jurnal Keputusan)'),
                      subtitle: const Text('Mencatat asumsi awal dan meninjau kembali bias keputusan dalam 90 hari.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/decision-journal');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.explore_rounded, color: Colors.teal),
                      title: const Text('Life Compass (3 Nilai Inti)'),
                      subtitle: const Text('Tentukan 3 nilai inti hidup Anda sebagai kompas harian.'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(context);
                        _showCoreValuesDialog(context, ref, profile);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        isDevMode ? Icons.developer_mode_rounded : Icons.developer_mode_outlined,
                        color: Colors.blue,
                      ),
                      title: Text(isDevMode ? 'Matikan Mode Developer' : 'Aktifkan Mode Developer'),
                      subtitle: Text(isDevMode ? 'Mengunci kembali semua skin premium.' : 'Membuka kunci seluruh skin premium untuk pengujian.'),
                      trailing: Switch(
                        value: isDevMode,
                        onChanged: (val) {
                          Navigator.pop(context);
                          _toggleDeveloperMode(context, ref, profile, val);
                        },
                      ),
                    ),
                    const Divider(),
                    if (isDevMode) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.nature_people_rounded, color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Simulasi Usia Pohon',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final currentOverride = ref.watch(devCumulativeDaysOverrideProvider);
                                    return Text(
                                      currentOverride != null ? '$currentOverride Hari (Virtual)' : 'Default (Data Riil)',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final currentOverride = ref.watch(devCumulativeDaysOverrideProvider) ?? dashboardData?.cumulativeDays ?? 0;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: currentOverride.toDouble().clamp(0.0, 100.0),
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        label: '$currentOverride Hari',
                                        onChanged: (val) {
                                          ref.read(devAgePlayProvider.notifier).stop();
                                          ref.read(devCumulativeDaysOverrideProvider.notifier).state = val.toInt();
                                        },
                                      ),
                                    ),
                                    Consumer(
                                      builder: (context, ref, child) {
                                        final isPlaying = ref.watch(devAgePlayProvider);
                                        return IconButton(
                                          icon: Icon(
                                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            ref.read(devAgePlayProvider.notifier).toggle();
                                          },
                                          tooltip: isPlaying ? 'Jeda Simulasi' : 'Putar Simulasi',
                                        );
                                      },
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(devAgePlayProvider.notifier).stop();
                                        ref.read(devCumulativeDaysOverrideProvider.notifier).state = null;
                                      },
                                      child: const Text('Reset', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Celestial Sky Simulation Panel
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.withOpacity(0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.nights_stay_rounded, color: Colors.purple, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Simulasi Waktu Langit',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final currentMode = ref.watch(devTimeOfDayOverrideProvider);
                                    final label = switch (currentMode) {
                                      CelestialTime.auto    => 'Auto (Waktu Riil)',
                                      CelestialTime.morning => 'Pagi 🌅',
                                      CelestialTime.noon    => 'Siang ☀️',
                                      CelestialTime.sunset  => 'Sore 🌇',
                                      CelestialTime.night   => 'Malam 🌌',
                                    };
                                    return Text(
                                      label,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final currentMode = ref.watch(devTimeOfDayOverrideProvider);
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: CelestialTime.values.map((time) {
                                            final label = switch (time) {
                                              CelestialTime.auto    => 'Auto 📱',
                                              CelestialTime.morning => 'Pagi 🌅',
                                              CelestialTime.noon    => 'Siang ☀️',
                                              CelestialTime.sunset  => 'Sore 🌇',
                                              CelestialTime.night   => 'Malam 🌌',
                                            };
                                            final isSelected = currentMode == time;
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 6.0),
                                              child: ChoiceChip(
                                                label: Text(label, style: const TextStyle(fontSize: 11)),
                                                selected: isSelected,
                                                selectedColor: Colors.purple.withOpacity(0.2),
                                                onSelected: (selected) {
                                                  if (selected) {
                                                    ref.read(devTimePlayProvider.notifier).stop();
                                                    ref.read(devTimeOfDayOverrideProvider.notifier).state = time;
                                                  }
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isPlaying = ref.watch(devTimePlayProvider);
                                    return IconButton(
                                      icon: Icon(
                                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                        color: Colors.purple,
                                        size: 24,
                                      ),
                                      onPressed: () {
                                        ref.read(devTimePlayProvider.notifier).toggle();
                                      },
                                      tooltip: isPlaying ? 'Jeda Simulasi Waktu' : 'Putar Simulasi Waktu',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ],
                  ListTile(
                    leading: Icon(Icons.download_rounded, color: CalmTheme.primarySage),
                    title: const Text('Ekspor Data Ke JSON (Lokal)'),
                    subtitle: const Text('Seluruh data profil, habit, jurnal, dan canvas Anda.'),
                    onTap: () {
                      Navigator.pop(context);
                      _exportDataAsJson(context, ref);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                    title: const Text('Reset Aplikasi (Hapus Semua Data)', style: TextStyle(color: Colors.redAccent)),
                    subtitle: const Text('Menghapus seluruh database lokal dan mengulang onboarding.'),
                    onTap: () {
                      Navigator.pop(context);
                      _resetApplication(context, ref);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _resetApplication(BuildContext context, WidgetRef ref) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Semua Data?'),
          content: const Text(
            'Tindakan ini akan menghapus seluruh profil, jurnal, kebiasaan, dan data Anda secara permanen dari perangkat ini. '
            'Anda akan dikembalikan ke halaman Onboarding awal.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus Permanen'),
            ),
          ],
        );
      },
    );

    if (proceed != true) return;

    final db = ref.read(dbProvider);
    await db.transaction(() async {
      await db.delete(db.userProfiles).go();
      await db.delete(db.lifeAudits).go();
      await db.delete(db.weeklyPulses).go();
      await db.delete(db.habits).go();
      await db.delete(db.habitLogs).go();
      await db.delete(db.journalEntries).go();
      await db.delete(db.thinkingCanvasSessions).go();
      await db.delete(db.consentLogs).go();
      await db.delete(db.reminderPreferences).go();
      await db.delete(db.wellnessPromptLogs).go();
      await db.delete(db.decisionEntries).go();
    });

    ref.invalidate(onboardingCompletedProvider);
    ref.invalidate(dashboardDataProvider);

    if (context.mounted) {
      context.go('/onboarding');
    }
  }

  Future<void> _exportDataAsJson(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    try {
      final profiles = await db.select(db.userProfiles).get();
      final habits = await db.select(db.habits).get();
      final logs = await db.select(db.habitLogs).get();
      final entries = await db.select(db.journalEntries).get();
      final canvas = await db.select(db.thinkingCanvasSessions).get();

      final data = {
        'profiles': profiles.map((p) => {
          'user_id': p.userId,
          'age_band': p.ageBand,
          'support_mode': p.supportMode,
          'engagement_state': p.engagementState,
          'timezone': p.timezone,
          'latest_domain_scores': p.latestDomainScores,
          'canopy_load_capacity': p.canopyLoadCapacity,
          'wellness_disclaimer_acknowledged': p.wellnessDisclaimerAcknowledged,
          'created_at': p.createdAt.toIso8601String(),
        }).toList(),
        'habits': habits.map((h) => {
          'habit_id': h.habitId,
          'title': h.title,
          'domain_tag': h.domainTag,
          'status': h.status,
          'frequency': h.frequency,
          'initiation_friction': h.initiationFriction,
          'energy_cost': h.energyCost,
          'impact_score': h.impactScore,
          'lifetime_done_count': h.lifetimeDoneCount,
        }).toList(),
        'habit_logs': logs.map((l) => {
          'log_id': l.logId,
          'habit_id': l.habitId,
          'date': l.date.toIso8601String(),
          'status': l.status,
          'friction_reason_selected': l.frictionReasonSelected,
        }).toList(),
        'journal_entries': entries.map((e) => {
          'entry_id': e.entryId,
          'date': e.date.toIso8601String(),
          'mood_score': e.moodScore,
          'keyword': e.keyword,
          'text_content': e.textContent,
          'entry_type': e.entryType,
        }).toList(),
        'thinking_canvas_sessions': canvas.map((c) => {
          'session_id': c.sessionId,
          'method_key': c.methodKey,
          'topic': c.topic,
          'summary_text': c.summaryText,
          'next_action': c.nextAction,
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/lifetree_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'LifeTree Data Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor data: $e')),
        );
      }
    }
  }
}
