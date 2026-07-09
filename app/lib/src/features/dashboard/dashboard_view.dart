import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/domain/priority_helper.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/domain/app_constants.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/widgets/error_state_widget.dart';
import '../../core/widgets/loading_state_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local_db/database.dart';
import 'dashboard_provider.dart';
import 'widgets/action_of_the_day_card.dart';
import 'widgets/celebration_card.dart';
import 'widgets/habit_list_section.dart';
import '../habit/services/habit_log_service.dart';
import 'widgets/season_badge_widget.dart';
import 'sheets/friction_intervention_sheet.dart';
import 'widgets/tree_display_widget.dart';
import '../cultivation/widgets/cultivation_badge.dart';
import '../cultivation/widgets/cultivation_progress_bar.dart';

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

  Widget _buildNoActionsCard(ThemeData theme, vocabularyLevel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('🍃', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              DaojiText.resolve(
                DaojiTextKey.dashboardNoActionsTitle,
                vocabularyLevel,
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              DaojiText.resolve(
                DaojiTextKey.dashboardNoActionsBody,
                vocabularyLevel,
              ),
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
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final hour = DateTime.now().hour;
            final greeting = hour < 4
                ? 'Selamat Malam'
                : hour < 11
                ? 'Selamat Pagi'
                : hour < 15
                ? 'Selamat Siang'
                : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';
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
        actions: [
          dataAsync.when(
            data: (data) => _buildCanopyLoadBadge(context, data),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Dukungan Kesehatan Diri',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/safety');
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(child: CultivationBadge()),
          ),
        ],
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
              } catch (e, stackTrace) {
                ErrorHandlerService().logError(
                  e,
                  stackTrace,
                  context: 'DashboardView.calculateFilteredAction',
                );
              }
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

          // Calculate balance index (average domain score / 10.0)
          double balanceIndex = 0.5; // default fallback
          if (data.profile.latestDomainScores != null) {
            try {
              final Map<String, dynamic> scores = jsonDecode(
                data.profile.latestDomainScores!,
              );
              if (scores.isNotEmpty) {
                final total = scores.values.fold<double>(
                  0.0,
                  (sum, val) => sum + (val as num).toDouble(),
                );
                balanceIndex = (total / scores.length) / 10.0;
              }
            } catch (e, stackTrace) {
              ErrorHandlerService().logError(
                e,
                stackTrace,
                context: 'DashboardView.parseBalanceIndex',
              );
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
                    isLowWellBeing: data.isLowWellBeing,
                  ),
                  const SizedBox(height: 12),

                  // 2. Cultivation Progress
                  const CultivationProgressBar(),
                  const SizedBox(height: 8),
                  const SizedBox(height: 12),

                  // 3. Tree Vitality
                  TreeVitalityCard(
                    cumulativeDays: data.cumulativeDays,
                    season: data.season,
                    activeDomainColor: _selectedDomainFilter == 'Semua'
                        ? null
                        : DomainColors.forDomain(_selectedDomainFilter),
                    selectedDomain: _selectedDomainFilter == 'Semua'
                        ? null
                        : _selectedDomainFilter,
                    onDomainNavigate: (domain) {
                      setState(() {
                        _selectedDomainFilter = domain;
                      });
                    },
                    onDomainReset: () {
                      setState(() {
                        _selectedDomainFilter = 'Semua';
                      });
                    },
                    balanceIndex: balanceIndex,
                  ),
                  const SizedBox(height: 16),

                  // 3. Action of the Day / Celebration State
                  if (data.allDone)
                    CelebrationCard(
                      cumulativeDays: data.cumulativeDays,
                      vocabularyLevel: vocabularyLevel,
                    )
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
                    _buildNoActionsCard(theme, vocabularyLevel),
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
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: SkeletonLoadingWidget(
            itemCount: 4,
            itemHeight: 76,
          ),
        ),
        error: (err, stack) => ErrorStateWidget(
          message: DaojiText.resolve(
            DaojiTextKey.dashboardLoadError,
            vocabularyLevel,
          ),
          error: err.toString(),
          onRetry: () {
            ref.invalidate(dashboardDataProvider);
          },
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Tambah aktivitas baru',
        hint: 'Buka menu untuk menambah jurnal, kebiasaan, atau refleksi',
        button: true,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showQuickActionsBottomSheet(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCanopyLoadBadge(BuildContext context, DashboardData data) {
    final currentLoad = data.habitsToday.fold<int>(
      0,
      (sum, hwl) => sum + hwl.habit.initiationFriction + hwl.habit.energyCost,
    );
    final capacity = data.dynamicCanopyCapacity;
    if (capacity <= 0 || currentLoad <= capacity) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Tooltip(
        message:
            'Beban hari ini: $currentLoad/$capacity — pertimbangkan menunda habit baru',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 14, color: theme.colorScheme.error),
              const SizedBox(width: 4),
              Text(
                '$currentLoad/$capacity',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
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
        final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
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
                  DaojiText.resolve(
                    DaojiTextKey.dashboardQuickActionsTitle,
                    vocabularyLevel,
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: DaojiText.resolve(
                    DaojiTextKey.dashboardAddPracticeTitle,
                    vocabularyLevel,
                  ),
                  hint: 'Buka halaman untuk membuat kebiasaan baru',
                  button: true,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.add_rounded, color: Color(0xFF2E7D32)),
                    ),
                    title: Text(
                      DaojiText.resolve(
                        DaojiTextKey.dashboardAddPracticeTitle,
                        vocabularyLevel,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DaojiText.resolve(
                        DaojiTextKey.dashboardAddPracticeSubtitle,
                        vocabularyLevel,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/add-habit');
                    },
                  ),
                ),
                const Divider(),
                Semantics(
                  label: DaojiText.resolve(
                    DaojiTextKey.dashboardJournalTitle,
                    vocabularyLevel,
                  ),
                  hint:
                      'Buka halaman jurnal untuk mencatat mood dan refleksi harian',
                  button: true,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE3F2FD),
                      child: Icon(Icons.book_rounded, color: Color(0xFF1E88E5)),
                    ),
                    title: Text(
                      DaojiText.resolve(
                        DaojiTextKey.dashboardJournalTitle,
                        vocabularyLevel,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DaojiText.resolve(
                        DaojiTextKey.dashboardJournalSubtitle,
                        vocabularyLevel,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/journal');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
