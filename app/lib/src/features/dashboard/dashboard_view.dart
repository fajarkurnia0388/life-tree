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

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

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

  Future<void> _toggleHabit(BuildContext context, WidgetRef ref, Habit habit, HabitLog? log) async {
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
  void _showFrictionIntervention(BuildContext context, WidgetRef ref, Habit habit) {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
                  ),
                  const SizedBox(height: 16),
                  
                  // Radar Chart Keseimbangan
                  _buildRadarChartCard(data),
                  const SizedBox(height: 16),

                  // Weekly Pulse Banner (Sunday or Developer Mode)
                  if (DateTime.now().weekday == DateTime.sunday ||
                      (data.profile.unlockedSkins.contains('Sakura') &&
                       data.profile.unlockedSkins.contains('Maple') &&
                       data.profile.unlockedSkins.contains('Bonsai'))) ...[
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
                  else if (data.actionOfTheDay != null)
                    _buildActionOfTheDayCard(context, ref, theme, data.actionOfTheDay!, data)
                  else
                    _buildNoActionsCard(theme),
                  const SizedBox(height: 24),

                  // 4. Other habits list
                  Text(
                    'Jadwal Kebiasaan Hari Ini',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  if (data.habitsToday.isEmpty)
                    _buildEmptyHabitsCard(theme, context)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.habitsToday.length,
                      itemBuilder: (context, index) {
                        final item = data.habitsToday[index];
                        final isAction = data.actionOfTheDay?.habitId == item.habit.habitId;
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
        return _TreeSkinShopBottomSheet(
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

    return RadarChartWidget(scores: scores);
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

    return Card(
      color: theme.colorScheme.primary.withOpacity(0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
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
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onBackground.withOpacity(0.7)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _toggleHabit(context, ref, habit, hwl.log),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(88, 48), // WCAG touch target
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tandai Selesai'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showFrictionIntervention(context, ref, habit),
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
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onBackground.withOpacity(0.6)),
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
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onBackground.withOpacity(0.6)),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAction
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.colorScheme.onBackground.withOpacity(0.08),
          width: isAction ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          item.habit.title,
          style: TextStyle(
            fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? theme.colorScheme.onBackground.withOpacity(0.6) : theme.colorScheme.onBackground,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Domain: ${item.habit.domainTag} | Beban: ${item.habit.initiationFriction + item.habit.energyCost} | ${item.habit.frequency}',
              style: const TextStyle(fontSize: 10),
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
        activeColor: theme.colorScheme.primary,
        onChanged: (_) => _toggleHabit(context, ref, item.habit, item.log),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }



  void _toggleDeveloperMode(BuildContext context, WidgetRef ref, UserProfile profile, bool enable) async {
    final db = ref.read(dbProvider);
    try {
      final updatedUnlocked = enable ? 'Default,Sakura,Maple,Bonsai' : 'Default';
      final updatedSelected = enable ? profile.selectedSkin : 'Default';

      await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
          .write(UserProfilesCompanion(
        unlockedSkins: drift.Value(updatedUnlocked),
        selectedSkin: drift.Value(updatedSelected),
      ));

      ref.invalidate(dashboardDataProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable
                ? 'Mode Developer Aktif: Semua skin premium terbuka!'
                : 'Mode Developer Nonaktif: Skin premium terkunci kembali.'),
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
                color: theme.colorScheme.onBackground.withOpacity(0.6),
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
    final isDevMode = profile != null &&
        profile.unlockedSkins.contains('Sakura') &&
        profile.unlockedSkins.contains('Maple') &&
        profile.unlockedSkins.contains('Bonsai');

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
                                          ref.read(devCumulativeDaysOverrideProvider.notifier).state = val.toInt();
                                        },
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
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
      
      // Since share_plus is added, we can use it, or just show a text dialog containing JSON
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Data Berhasil Diekspor'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salin konten JSON di bawah untuk cadangan manual Anda:'),
                    const SizedBox(height: 12),
                    SelectableText(
                      jsonString,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor data: $e')),
        );
      }
    }
  }
}

// ---------------------------------------------------------
// Friction Intervention Sheet Component
// ---------------------------------------------------------
class _FrictionInterventionSheet extends ConsumerStatefulWidget {
  final Habit habit;
  const _FrictionInterventionSheet({required this.habit});

  @override
  ConsumerState<_FrictionInterventionSheet> createState() => _FrictionInterventionSheetState();
}

class _FrictionInterventionSheetState extends ConsumerState<_FrictionInterventionSheet> {
  String? _selectedReason; // 'Kurang_Waktu', 'Kelelahan', 'Lupa'
  int _recoveryDays = 3;

  Future<void> _submitIntervention() async {
    if (_selectedReason == null) return;

    final service = ref.read(habitLogServiceProvider);
    final db = ref.read(dbProvider);
    final now = DateTime.now();

    // Safe upsert Missed log via HabitLogService (no duplicate conflict)
    await service.markMissedWithReason(
      habit: widget.habit,
      date: now,
      reason: _selectedReason!,
    );

    // Apply specific intervention logic based on user choice
    if (_selectedReason == 'Kelelahan') {
      // Enter Recovery Mode
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isNotEmpty) {
        await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profiles.first.userId)))
            .write(UserProfilesCompanion(
              supportMode: const drift.Value('Recovery'),
              updatedAt: drift.Value(now),
            ));
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ada apa hari ini?',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Jangan merasa bersalah. Menghadapi rintangan adalah bagian dari proses pembentukan kebiasaan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: theme.colorScheme.onBackground.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),

          // Reason Options
          _buildReasonTile(
            value: 'Kurang_Waktu',
            icon: Icons.timer_outlined,
            title: 'Kurang Waktu',
            desc: 'Saya hanya punya sedikit waktu hari ini.',
          ),
          _buildReasonTile(
            value: 'Kelelahan',
            icon: Icons.battery_alert_rounded,
            title: 'Kelelahan / Sakit',
            desc: 'Energi saya benar-benar terkuras hari ini.',
          ),
          _buildReasonTile(
            value: 'Lupa',
            icon: Icons.notifications_off_outlined,
            title: 'Lupa / Kurang Fokus',
            desc: 'Saya terlewat karena tidak ingat jadwalnya.',
          ),
          const SizedBox(height: 16),

          // Conditional details based on selected reason
          if (_selectedReason == 'Kurang_Waktu')
            Card(
              color: theme.colorScheme.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('💡 Tips Ringan', style: TextStyle(fontWeight: FontWeight.bold, color: CalmTheme.primarySage)),
                    const SizedBox(height: 8),
                    Text(
                      'Bagaimana jika kita kurangi target besok ke versi ringkas (${widget.habit.mvaDurationMin} menit) saja?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedReason == 'Kelelahan')
            Card(
              color: CalmTheme.secondaryBlue.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('❄️ Masuk Mode Istirahat', style: TextStyle(fontWeight: FontWeight.bold, color: CalmTheme.secondaryBlue)),
                    const SizedBox(height: 8),
                    const Text(
                      'Pohon Anda akan diselimuti salju dan notifikasi akan dijeda sementara.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [3, 5, 7].map((days) {
                        final isSelected = _recoveryDays == days;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text('$days Hari'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _recoveryDays = days);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedReason == 'Lupa')
            Card(
              color: Colors.amber.withOpacity(0.05),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('🔗 Routine Stacking', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 8),
                    Text(
                      'Coba kaitkan kebiasaan ini tepat setelah aktivitas harian yang pasti Anda lakukan (misal: setelah minum kopi pagi).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Action button
          ElevatedButton(
            onPressed: _selectedReason != null ? _submitIntervention : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(88, 52), // WCAG touch target
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Simpan & Refleksikan'),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonTile({
    required String value,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    final isSelected = _selectedReason == value;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedReason,
        onChanged: (val) {
          setState(() {
            _selectedReason = val;
          });
        },
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        secondary: Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.4)),
        selected: isSelected,
        activeColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
      ),
    );
  }
}

class _TreeSkinShopBottomSheet extends ConsumerStatefulWidget {
  final UserProfile profile;
  final VoidCallback onSuccess;
  const _TreeSkinShopBottomSheet({required this.profile, required this.onSuccess});

  @override
  ConsumerState<_TreeSkinShopBottomSheet> createState() => _TreeSkinShopBottomSheetState();
}

class _TreeSkinShopBottomSheetState extends ConsumerState<_TreeSkinShopBottomSheet> {
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _skins = [
    {
      'id': 'Default',
      'name': 'Oak Klasik 🌱',
      'description': 'Penampilan default bernuansa hijau sage yang menenangkan.',
      'price': 0,
      'preview': '🌱 🌿 🌳 🌲',
    },
    {
      'id': 'Sakura',
      'name': 'Sakura Jepang 🌸',
      'description': 'Pohon sakura dengan kelopak bunga merah muda yang mekar indah.',
      'price': 15000,
      'preview': '🌸🌱 🌸🌿 🌸🌳 🌸🌲',
    },
    {
      'id': 'Maple',
      'name': 'Golden Maple 🍁',
      'description': 'Penampilan musim gugur dengan warna emas kemerahan yang hangat.',
      'price': 15000,
      'preview': '🍁🌱 🍁🌿 🍁🌳 🍁🌲',
    },
    {
      'id': 'Bonsai',
      'name': 'Bonsai Zen 🪴',
      'description': 'Tanaman kerdil tradisional untuk melatih kedisiplinan dan ketenangan.',
      'price': 25000,
      'preview': '🪴🌱 🪴🌿 🪴🌳 🪴🌲',
    },
  ];

  Future<void> _selectSkin(String skinId) async {
    final db = ref.read(dbProvider);
    try {
      await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(widget.profile.userId)))
          .write(UserProfilesCompanion(selectedSkin: drift.Value(skinId)));
      widget.onSuccess();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tampilan pohon berhasil diubah ke skin ini!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menerapkan skin: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _buySkin(Map<String, dynamic> skin) async {
    final db = ref.read(dbProvider);
    final skinId = skin['id'] as String;
    final priceStr = 'Rp ${(skin['price'] as int).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}';

    final proceedPayment = await showDialog<bool>(
      context: context,
      builder: (context) {
        String method = 'Google Play';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Simulasi Transaksi Premium'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Anda akan membeli skin premium:\n"${skin['name']}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harga: $priceStr',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Metode Pembayaran:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: method,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Google Play', child: Text('GPay / Google Play Store')),
                      DropdownMenuItem(value: 'Transfer Bank', child: Text('Transfer Bank (Virtual Account)')),
                      DropdownMenuItem(value: 'e-Wallet', child: Text('e-Wallet (QRIS)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          method = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Bayar Sekarang'),
                ),
              ],
            );
          },
        );
      },
    );

    if (proceedPayment == true) {
      setState(() {
        _isProcessing = true;
      });

      // Simulate payment delay
      await Future.delayed(const Duration(milliseconds: 600));

      try {
        final updatedUnlocked = '${widget.profile.unlockedSkins},$skinId';
        await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(widget.profile.userId)))
            .write(UserProfilesCompanion(
          unlockedSkins: drift.Value(updatedUnlocked),
          selectedSkin: drift.Value(skinId),
        ));

        widget.onSuccess();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pembelian berhasil! Skin "${skin['name']}" telah diaktifkan.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memproses pembelian: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedList = widget.profile.unlockedSkins.split(',');

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Toko Skin Pohon 🎨',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Visualisasikan konsistensi Anda dengan gaya pohon unik.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onBackground.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_isProcessing)
            const SizedBox(
              height: 250,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memproses transaksi pembayaran...'),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _skins.length,
              itemBuilder: (context, index) {
                final s = _skins[index];
                final isUnlocked = unlockedList.contains(s['id']);
                final isSelected = widget.profile.selectedSkin == s['id'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Text(
                      (s['preview'] as String).split(' ').last,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      s['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['description'], style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          'Preview: ${s['preview']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : isUnlocked
                            ? OutlinedButton(
                                onPressed: () => _selectSkin(s['id']),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Pakai', style: TextStyle(fontSize: 12)),
                              )
                            : ElevatedButton(
                                onPressed: () => _buySkin(s),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  s['price'] == 0 ? 'Gratis' : 'Rp ${(s['price'] as int).toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
