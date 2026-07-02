import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:io';
import 'dart:convert';
import '../../../core/providers/db_provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/button_theme.dart';
import '../../../core/animations/dialog_animations.dart';
import '../../../data/local_db/database.dart';
import '../dashboard_provider.dart';

/// Bottom Sheet untuk Settings (Export, Reset, Theme)
class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({
    super.key,
  });

  Future<void> _exportDataAsJson(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);
    final profile = await (db.select(db.userProfiles)..limit(1)).getSingleOrNull();
    if (profile == null) return;

    // Gather all data scoped to the current user
    final habits = await (db.select(db.habits)
          ..where((tbl) => tbl.userId.equals(profile.userId) & tbl.deletedAt.isNull()))
        .get();
    final habitIds = habits.map((h) => h.habitId).toList();
    final habitLogs = habitIds.isEmpty
        ? <HabitLog>[]
        : await (db.select(db.habitLogs)
              ..where((tbl) => tbl.habitId.isIn(habitIds) & tbl.deletedAt.isNull()))
            .get();
    final journalEntries = await (db.select(db.journalEntries)
          ..where((tbl) => tbl.userId.equals(profile.userId) & tbl.deletedAt.isNull()))
        .get();
    final weeklyPulses = await (db.select(db.weeklyPulses)
          ..where((tbl) => tbl.userId.equals(profile.userId) & tbl.deletedAt.isNull()))
        .get();

    final Map<String, dynamic> exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'profile': {
        'userId': profile.userId,
        'ageBand': profile.ageBand,
        'supportMode': profile.supportMode,
        'timezone': profile.timezone,
      },
      'habits': habits.map((h) => h.toJson()).toList(),
      'habitLogs': habitLogs.map((l) => l.toJson()).toList(),
      'journalEntries': journalEntries.map((e) => e.toJson()).toList(),
      'weeklyPulses': weeklyPulses.map((p) => p.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    try {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _resetApplication(BuildContext context, WidgetRef ref) async {
    final db = ref.read(dbProvider);

    // Confirm reset
    final confirm = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Aplikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua data? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppButtonStyles.secondary(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppButtonStyles.destructive(context).copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.red),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete all data
    await db.delete(db.habitLogs).go();
    await db.delete(db.habits).go();
    await db.delete(db.journalEntries).go();
    await db.delete(db.thinkingCanvasSessions).go();
    await db.delete(db.weeklyPulses).go();
    await db.delete(db.decisionEntries).go();
    await db.delete(db.lifeAudits).go();
    await db.delete(db.consentLogs).go();
    await db.delete(db.reminderPreferences).go();
    await db.delete(db.userProfiles).go();
    await db.delete(db.wellnessPromptLogs).go();

    ref.invalidate(dashboardDataProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data telah dihapus.')),
      );
    }
  }

  Future<void> _toggleThemeMode(WidgetRef ref, bool isDark) async {
    final db = ref.read(dbProvider);
    final profile = await (db.select(db.userProfiles)..limit(1)).getSingleOrNull();
    if (profile == null) return;
    await (db.update(db.userProfiles)..where((tbl) => tbl.userId.equals(profile.userId)))
        .write(UserProfilesCompanion(themeMode: drift.Value(isDark ? 'Dark' : 'Light')));
    ref.invalidate(dashboardDataProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pengaturan',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Ekspor Data'),
            subtitle: const Text('Simpan semua data ke file JSON'),
            onTap: () => _exportDataAsJson(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text('Reset Aplikasi'),
            subtitle: const Text('Hapus semua data dan kembali ke awal'),
            onTap: () => _resetApplication(context, ref),
            tileColor: Colors.red.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: ref.watch(appThemeModeProvider).valueOrNull == ThemeMode.dark,
              onChanged: (value) => _toggleThemeMode(ref, value),
            ),
          ),
        ],
      ),
    );
  }
}
