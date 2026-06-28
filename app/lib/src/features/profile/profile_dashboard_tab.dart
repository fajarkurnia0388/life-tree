import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import '../dashboard/widgets/skin_shop_bottom_sheet.dart';
import '../onboarding/onboarding_view.dart';
import 'package:go_router/go_router.dart';

class ProfileDashboardTab extends ConsumerStatefulWidget {
  const ProfileDashboardTab({super.key});

  @override
  ConsumerState<ProfileDashboardTab> createState() => _ProfileDashboardTabState();
}

class _ProfileDashboardTabState extends ConsumerState<ProfileDashboardTab> {
  bool _isExporting = false;

  void _showCoreValuesDialog(BuildContext context, UserProfile profile) {
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

  void _showSkinShop(BuildContext context, UserProfile profile) {
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

  Future<void> _updateThemeMode(UserProfile profile, String mode) async {
    final db = ref.read(dbProvider);
    try {
      await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
          .write(UserProfilesCompanion(themeMode: drift.Value(mode)));
      ref.invalidate(dashboardDataProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tema berhasil diubah ke ${mode == 'System' ? 'Sistem' : mode == 'Light' ? 'Terang' : 'Gelap'}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah tema: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleDeveloperMode(UserProfile profile, bool enable) async {
    final db = ref.read(dbProvider);
    try {
      await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
          .write(UserProfilesCompanion(
        isDeveloperMode: drift.Value(enable),
      ));

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable
                ? 'Mode Developer Aktif: Fitur simulasi dan semua skin terbuka!'
                : 'Mode Developer Nonaktif: Fitur simulasi ditutup.'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah mode developer: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportDataAsJson() async {
    setState(() {
      _isExporting = true;
    });
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

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'LifeTree Data Export',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor data: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _resetApplication(BuildContext context) async {
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
    if (context.mounted) {
      context.go('/onboarding');
    }
  }


  Widget _buildLifeCompassSection(BuildContext context, UserProfile profile) {
    final theme = Theme.of(context);
    List<String> values = [];
    try {
      final jsonStr = profile.coreValues;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        values = List<String>.from(jsonDecode(jsonStr));
      }
    } catch (_) {}

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.explore_rounded, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Kompas Hidup 🧭', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                IconButton(
                  onPressed: () => _showCoreValuesDialog(context, profile),
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  tooltip: 'Ubah Kompas Hidup',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tiga nilai inti hidup Anda yang menuntun arah kebiasaan dan keseimbangan harian:',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            if (values.isEmpty)
              Center(
                child: TextButton.icon(
                  onPressed: () => _showCoreValuesDialog(context, profile),
                  icon: const Icon(Icons.add),
                  label: const Text('Tentukan Nilai Inti'),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: values.map((v) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        v,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )).toList(),
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
        title: const Text('Profil & Pengaturan ⚙️'),
      ),
      body: dataAsync.when(
        data: (data) {
          final profile = data.profile;
          final isDevMode = profile.isDeveloperMode;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Life Compass Widget
                _buildLifeCompassSection(context, profile),
                const SizedBox(height: 16),

                // 2. Tree Skin Shop Card
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_florist_rounded, color: Colors.green),
                    ),
                    title: const Text('Toko Skin Pohon 🌸', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Skin Aktif: ${profile.selectedSkin}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showSkinShop(context, profile),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. App Settings Section Title
                Text('Pengaturan Sistem', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [
                      // Theme Switcher
                      ListTile(
                        leading: const Icon(Icons.brightness_medium_rounded, color: Colors.amber),
                        title: const Text('Mode Tema Aplikasi'),
                        subtitle: const Text('Pilih gaya visual terang atau gelap.'),
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
                              _updateThemeMode(profile, val);
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),

                      // Export Data JSON
                      ListTile(
                        leading: const Icon(Icons.share_rounded, color: Colors.blue),
                        title: const Text('Ekspor Data Lokal'),
                        subtitle: const Text('Bagikan cadangan database lokal Anda sebagai file JSON.'),
                        trailing: _isExporting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: _isExporting ? null : _exportDataAsJson,
                      ),
                      const Divider(height: 1),

                      // Reset Application
                      ListTile(
                        leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                        title: const Text('Reset Aplikasi', style: TextStyle(color: Colors.redAccent)),
                        subtitle: const Text('Hapus seluruh database lokal dan mengulang onboarding.'),
                        onTap: () => _resetApplication(context),
                      ),
                      const Divider(height: 1),

                      // Developer Mode Toggle
                      ListTile(
                        leading: Icon(
                          isDevMode ? Icons.developer_mode_rounded : Icons.developer_mode_outlined,
                          color: Colors.blueGrey,
                        ),
                        title: const Text('Mode Developer'),
                        subtitle: const Text('Buka semua skin premium & aktifkan kontrol simulasi.'),
                        trailing: Switch(
                          value: isDevMode,
                          onChanged: (val) => _toggleDeveloperMode(profile, val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Developer Mode Options (Sliders & Simulations)
                if (isDevMode) ...[
                  Text('Developer Tools 🛠️', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: const Icon(Icons.tune_rounded, color: Colors.blueGrey),
                      title: const Text('Buka Kontrol Simulasi'),
                      subtitle: Consumer(
                        builder: (context, ref, child) {
                          final ageOverride = ref.watch(devCumulativeDaysOverrideProvider);
                          final timeOverride = ref.watch(devTimeOfDayOverrideProvider);
                          final ageText = ageOverride != null ? '$ageOverride Hari Virtual' : 'Usia Riil';
                          final timeText = switch (timeOverride) {
                            CelestialTime.auto    => 'Waktu Riil',
                            CelestialTime.morning => 'Pagi 🌅',
                            CelestialTime.noon    => 'Siang ☀️',
                            CelestialTime.sunset  => 'Sore 🌇',
                            CelestialTime.night   => 'Malam 🌙',
                          };
                          return Text('$ageText  •  $timeText', style: const TextStyle(fontSize: 12));
                        },
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showDevToolsSheet(context),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat profil: $err')),
      ),
    );
  }

  void _showDevToolsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Developer Tools 🛠️',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // --- Tree Age Slider ---
                Row(
                  children: [
                    const Icon(Icons.nature_people_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text('Simulasi Usia Pohon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, child) {
                        final current = ref.watch(devCumulativeDaysOverrideProvider);
                        return Text(
                          current != null ? '$current Hari (Virtual)' : 'Usia Riil',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                        );
                      },
                    ),
                  ],
                ),
                Consumer(
                  builder: (context, ref, child) {
                    // Ambil dashboardData dari ref untuk cumulativeDays riil
                    final realDays = ref.watch(dashboardDataProvider).valueOrNull?.cumulativeDays ?? 0;
                    final current = ref.watch(devCumulativeDaysOverrideProvider) ?? realDays;
                    return Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: current.toDouble().clamp(0.0, 100.0),
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: '$current Hari',
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
                              ),
                              onPressed: () => ref.read(devAgePlayProvider.notifier).toggle(),
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

                const Divider(height: 28),

                // --- Celestial Time ---
                Row(
                  children: [
                    const Icon(Icons.nights_stay_rounded, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    const Text('Simulasi Waktu Langit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const Spacer(),
                    Consumer(
                      builder: (context, ref, child) {
                        final mode = ref.watch(devTimeOfDayOverrideProvider);
                        final label = switch (mode) {
                          CelestialTime.auto    => 'Waktu Riil',
                          CelestialTime.morning => 'Pagi 🌅',
                          CelestialTime.noon    => 'Siang ☀️',
                          CelestialTime.sunset  => 'Sore 🌇',
                          CelestialTime.night   => 'Malam 🌙',
                        };
                        return Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, child) {
                    final currentMode = ref.watch(devTimeOfDayOverrideProvider);
                    return SegmentedButton<CelestialTime>(
                      segments: const [
                        ButtonSegment(value: CelestialTime.auto,    label: Text('Auto',  style: TextStyle(fontSize: 10))),
                        ButtonSegment(value: CelestialTime.morning,  label: Text('🌅',   style: TextStyle(fontSize: 13))),
                        ButtonSegment(value: CelestialTime.noon,     label: Text('☀️',   style: TextStyle(fontSize: 13))),
                        ButtonSegment(value: CelestialTime.sunset,   label: Text('🌇',   style: TextStyle(fontSize: 13))),
                        ButtonSegment(value: CelestialTime.night,    label: Text('🌙',   style: TextStyle(fontSize: 13))),
                      ],
                      selected: {currentMode},
                      onSelectionChanged: (val) {
                        ref.read(devTimeOfDayOverrideProvider.notifier).state = val.first;
                      },
                    );
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
