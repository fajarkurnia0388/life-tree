import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/local_db/database.dart';
import 'dashboard_provider.dart';
import 'widgets/action_of_the_day_card.dart';
import 'widgets/celebration_card.dart';
import 'widgets/dev_toolbar_widget.dart';
import 'widgets/domain_scores_card.dart';
import 'widgets/habit_list_section.dart';
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
    return DomainScoresCard(
      data: data,
      selectedDomain: _selectedDomainFilter,
      onDomainSelected: (domain) {
        setState(() {
          _selectedDomainFilter = (_selectedDomainFilter == domain) ? 'Semua' : domain;
        });
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
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
        title: const Text('LifeTree OS'),
      ),
      body: dataAsync.when(
        data: (data) {
          // Filter habits today based on the selected focus domain
          final filteredHabits = _selectedDomainFilter == 'Semua'
              ? data.habitsToday
              : data.habitsToday.where((hwl) => hwl.habit.domainTag == _selectedDomainFilter).toList();

          // Whether recovery (rest) mode is currently active.
          final isRecoveryActive = data.season == 'Recovery';

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
                    skinId: data.profile.selectedSkin,
                    cumulativeDays: data.cumulativeDays,
                    season: data.season,
                    onSkinShopTap: () => _showSkinShop(context, ref, data.profile),
                    activeDomainColor: _selectedDomainFilter == 'Semua' ? null : _getDomainColor(_selectedDomainFilter),
                  ),
                  const SizedBox(height: 16),

                  // Dev Toolbar (only in Dev Mode)
                  if (data.profile.isDeveloperMode) ...[
                    DevToolbarWidget(data: data),
                    const SizedBox(height: 16),
                  ],

                  // Radar Chart Keseimbangan
                  _buildRadarChartCard(data),
                  const SizedBox(height: 16),

                  // 3. Action of the Day / Celebration State
                  if (data.allDone)
                    const CelebrationCard()
                  else if (activeActionOfTheDay != null) ...[
                    Builder(builder: (context) {
                      final hwl = data.habitsToday.firstWhere((item) => item.habit.habitId == activeActionOfTheDay!.habitId);
                      return ActionOfTheDayCard(
                        habit: activeActionOfTheDay!,
                        data: data,
                        onDonePressed: () => _toggleHabit(context, activeActionOfTheDay!, hwl.log),
                        onNotCapablePressed: () => _showFrictionIntervention(context, activeActionOfTheDay!),
                      );
                    })
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
        error: (err, stack) => Center(
          child: Text('Terjadi kesalahan: $err'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionsBottomSheet(context),
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Aksi Cepat'),
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
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.add_rounded, color: Color(0xFF2E7D32)),
                  ),
                  title: const Text('Tambah Kebiasaan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Buat kebiasaan baru di domain kehidupan Anda'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/add-habit');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF3E5F5),
                    child: Icon(Icons.psychology_rounded, color: Color(0xFF7B1FA2)),
                  ),
                  title: const Text('Buka Thinking Canvas', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Coret ide & selesaikan kebuntuan berpikir'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/thinking-canvas');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(Icons.analytics_rounded, color: Color(0xFFE65100)),
                  ),
                  title: const Text('Mulai Weekly Pulse Check', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Evaluasi kesejahteraan emosional mingguan (WHO-5)'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/weekly-pulse');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.health_and_safety_rounded, color: Color(0xFFC62828)),
                  ),
                  title: const Text('Safety Card (Dukungan Krisis)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Akses kontak darurat & panduan tenangkan diri'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/safety');
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
