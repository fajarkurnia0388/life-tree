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
import '../onboarding/onboarding_view.dart';
import 'package:go_router/go_router.dart';
import 'widgets/life_compass_section.dart';

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
      if (profiles.isEmpty) throw Exception('Profil tidak ditemukan');
      final userId = profiles.first.userId;

      final habits = await (db.select(db.habits)..where((tbl) => tbl.userId.equals(userId))).get();
      final habitIds = habits.map((h) => h.habitId).toList();
      final logs = habitIds.isEmpty
          ? <HabitLog>[]
          : await (db.select(db.habitLogs)..where((tbl) => tbl.habitId.isIn(habitIds))).get();
      final entries = await (db.select(db.journalEntries)..where((tbl) => tbl.userId.equals(userId))).get();
      final canvas = await (db.select(db.thinkingCanvasSessions)..where((tbl) => tbl.userId.equals(userId))).get();

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
      await db.delete(db.valueDilemmaResponses).go();
    });

    ref.invalidate(onboardingCompletedProvider);
    if (context.mounted) {
      context.go('/onboarding');
    }
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
                LifeCompassSection(
                  profile: profile,
                  onEdit: () => _showCoreValuesDialog(context, profile),
                ),
                const SizedBox(height: 16),

                Text('Pengaturan Sistem', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [
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

                      ListTile(
                        leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                        title: const Text('Reset Aplikasi', style: TextStyle(color: Colors.redAccent)),
                        subtitle: const Text('Hapus seluruh database lokal dan mengulang onboarding.'),
                        onTap: () => _resetApplication(context),
                      ),
                      const Divider(height: 1),

                      ListTile(
                        leading: Icon(
                          isDevMode ? Icons.developer_mode_rounded : Icons.developer_mode_outlined,
                          color: Colors.blueGrey,
                        ),
                        title: const Text('Mode Developer'),
                        subtitle: const Text('Aktifkan kontrol simulasi untuk pengalaman pengembangan.'),
                        trailing: Switch(
                          value: isDevMode,
                          onChanged: (val) => _toggleDeveloperMode(profile, val),
                        ),
                        onTap: () => _toggleDeveloperMode(profile, !isDevMode),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat profil: $err')),
      ),
    );
  }
}
