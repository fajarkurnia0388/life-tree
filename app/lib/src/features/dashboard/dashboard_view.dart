import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/domain/priority_helper.dart';
import '../../core/domain/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local_db/database.dart';
import 'dashboard_provider.dart';
import 'widgets/domain_insight_dialog.dart';
import 'widgets/action_of_the_day_card.dart';
import 'widgets/celebration_card.dart';
import 'widgets/domain_scores_card.dart';
import 'widgets/habit_list_section.dart';
import '../habit/services/habit_log_service.dart';
import 'widgets/season_badge_widget.dart';
import 'sheets/friction_intervention_sheet.dart';
import 'widgets/tree_display_widget.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  String _selectedDomainFilter = 'Semua';

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month];
  }

  Future<void> _toggleHabit(
    BuildContext context,
    Habit habit,
    HabitLog? log,
  ) async {
    final service = ref.read(habitLogServiceProvider);
    final now = DateTime.now();

    try {
      if (log != null && log.status == HabitStatus.done) {
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

  Widget _buildRadarChartCard(DashboardData data) {
    Map<String, double> scores = {
      'Tubuh': 5.0,
      'Keuangan': 5.0,
      'Hubungan': 5.0,
      'Emosi': 5.0,
      'Karir': 5.0,
      'Rekreasi': 5.0,
    };
    if (data.profile.latestDomainScores != null) {
      try {
        final Map<String, dynamic> parsed = jsonDecode(
          data.profile.latestDomainScores!,
        );
        parsed.forEach((key, value) {
          final numVal = value as num;
          if (scores.containsKey(key)) {
            scores[key] = numVal.toDouble();
          }
        });
      } catch (_) {}
    }

    return DomainScoresCard(
      data: data,
      selectedDomain: _selectedDomainFilter,
      onDomainSelected: (domain) {
        final currentScore = scores[domain] ?? 5.0;
        DomainInsightDialog.show(
          context,
          domain: domain,
          score: currentScore,
          onFocusApplied: () {
            setState(() {
              _selectedDomainFilter = (_selectedDomainFilter == domain)
                  ? 'Semua'
                  : domain;
            });
          },
        );
      },
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
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final hour = DateTime.now().hour;
            final greeting = hour < 11
                ? 'Selamat Pagi'
                : hour < 15
                ? 'Selamat Siang'
                : 'Selamat Sore';
            final now = DateTime.now();
            final dateStr = '${now.day} ${_monthName(now.month)} ${now.year}';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: dataAsync.when(
        data: (data) {
          // Filter habits today based on the selected focus domain
          final filteredHabits = _selectedDomainFilter == 'Semua'
              ? data.habitsToday
              : data.habitsToday
                    .where(
                      (hwl) => hwl.habit.domainTag == _selectedDomainFilter,
                    )
                    .toList();

          // Whether recovery (rest) mode is currently active.
          final isRecoveryActive = data.season == Season.recovery;

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
            final uncompletedFiltered = filteredHabits
                .where((hwl) => hwl.log?.status != HabitStatus.done)
                .toList();
            for (final hwl in uncompletedFiltered) {
              final score = computeHabitPriorityScore(
                habit: hwl.habit,
                domainScores: domainScores,
              );
              if (score > highestPriority) {
                highestPriority = score;
                activeActionOfTheDay = hwl.habit;
              }
            }
          }

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
                  SeasonBadgeWidget(
                    season: data.season,
                    recoveryEndDate: data.profile.recoveryEndDate,
                  ),
                  const SizedBox(height: 12),

                  // 2. Tree Vitality
                  TreeVitalityCard(
                    cumulativeDays: data.cumulativeDays,
                    season: data.season,
                    activeDomainColor: _selectedDomainFilter == 'Semua'
                        ? null
                        : DomainColors.forDomain(_selectedDomainFilter),
                  ),
                  const SizedBox(height: 16),

                  // Radar Chart Keseimbangan
                  _buildRadarChartCard(data),
                  const SizedBox(height: 16),

                  // 3. Action of the Day / Celebration State
                  if (data.allDone)
                    const CelebrationCard()
                  else if (activeActionOfTheDay != null) ...[
                    Builder(
                      builder: (context) {
                        final hwl = data.habitsToday.firstWhere(
                          (item) =>
                              item.habit.habitId ==
                              activeActionOfTheDay!.habitId,
                        );
                        return ActionOfTheDayCard(
                          habit: activeActionOfTheDay!,
                          data: data,
                          onDonePressed: () => _toggleHabit(
                            context,
                            activeActionOfTheDay!,
                            hwl.log,
                          ),
                          onNotCapablePressed: () => _showFrictionIntervention(
                            context,
                            activeActionOfTheDay!,
                          ),
                        );
                      },
                    ),
                  ] else
                    _buildNoActionsCard(theme),
                  const SizedBox(height: 24),

                  // 4. Other habits list
                  HabitListSection(
                    habitsWithLogs: filteredHabits,
                    selectedDomainFilter: _selectedDomainFilter,
                    isRecoveryActive: isRecoveryActive,
                    onDomainReset: () {
                      setState(() {
                        _selectedDomainFilter = 'Semua';
                      });
                    },
                    onHabitToggle: _toggleHabit,
                    onFrictionIntervention: _showFrictionIntervention,
                    activeActionOfTheDay: activeActionOfTheDay,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Terjadi kesalahan: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActionsBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Aksi Cepat ⚡',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.add_rounded, color: Color(0xFF2E7D32)),
                  ),
                  title: const Text(
                    'Tambah Kebiasaan Baru',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Buat kebiasaan baru di domain kehidupan Anda',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/add-habit');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.book_rounded, color: Color(0xFF1E88E5)),
                  ),
                  title: const Text(
                    'Tulis Jurnal Hari Ini',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Catat mood & jurnal harian Anda'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/journal');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
