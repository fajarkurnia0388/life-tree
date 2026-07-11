import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_level.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/button_theme.dart';
import '../../../core/animations/dialog_animations.dart';
import '../../onboarding/onboarding_view.dart';
import '../dashboard_provider.dart';
import '../services/dashboard_action_service.dart';

/// Bottom Sheet untuk Settings (Export, Reset, Theme)
class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  Future<void> _toggleDeveloperMode(WidgetRef ref, bool enabled) async {
    final profile = await ref.read(userProfileProvider.future);
    if (profile == null) return;

    await ref
        .read(dashboardActionServiceProvider)
        .toggleDeveloperMode(profile.userId, enabled);
    ref.invalidate(dashboardDataProvider);
  }

  Future<void> _exportDataAsJson(BuildContext context, WidgetRef ref) async {
    final profile = await ref.read(userProfileProvider.future);
    if (profile == null) return;

    final exportData = await ref
        .read(dashboardActionServiceProvider)
        .exportAllUserData(profile.userId);
    if (exportData.isEmpty) return;

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    File? exportFile;
    try {
      final tempDir = await getTemporaryDirectory();
      exportFile = File(
        '${tempDir.path}/daoji_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await exportFile.writeAsString(jsonString, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(exportFile.path, mimeType: 'application/json')],
          subject: 'Daoji Data Export',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DaojiText.resolve(
                DaojiTextKey.settingsExportFailed,
                ref.read(daojiVocabularyLevelValueProvider),
                params: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (exportFile != null && await exportFile.exists()) {
        await exportFile.delete();
      }
    }
  }

  Future<void> _resetApplication(BuildContext context, WidgetRef ref) async {
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);

    // Confirm reset
    final confirm = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          DaojiText.resolve(DaojiTextKey.settingsReset, vocabularyLevel),
        ),
        content: Text(
          DaojiText.resolve(
            DaojiTextKey.settingsResetConfirmBody,
            vocabularyLevel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: AppButtonStyles.secondary(context),
            child: Text(
              DaojiText.resolve(DaojiTextKey.systemCancel, vocabularyLevel),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppButtonStyles.destructive(context),
            child: Text(
              DaojiText.resolve(
                DaojiTextKey.settingsResetConfirmAction,
                vocabularyLevel,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete all data
    await ref.read(dashboardActionServiceProvider).resetAllUserData();

    ref.invalidate(dashboardDataProvider);
    ref.invalidate(onboardingCompletedProvider);
    ref.invalidate(appThemeModeProvider);

    if (context.mounted) {
      Navigator.of(context).pop();
      context.go('/onboarding');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DaojiText.resolve(
              DaojiTextKey.settingsResetSuccess,
              vocabularyLevel,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.valueOrNull;

    final currentMode = profile?.themeMode ?? 'System';
    final circadianEnabled = profile?.circadianEnabled ?? false;
    final devMode = profile?.isDeveloperMode ?? false;

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DaojiText.resolve(DaojiTextKey.settingsTitle, vocabularyLevel),
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: Text(
              DaojiText.resolve(DaojiTextKey.settingsExport, vocabularyLevel),
            ),
            subtitle: Text(
              DaojiText.resolve(
                DaojiTextKey.settingsExportSubtitle,
                vocabularyLevel,
              ),
            ),
            onTap: () => _exportDataAsJson(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: Text(
              DaojiText.resolve(DaojiTextKey.settingsReset, vocabularyLevel),
            ),
            subtitle: Text(
              DaojiText.resolve(
                DaojiTextKey.settingsResetSubtitle,
                vocabularyLevel,
              ),
            ),
            onTap: () => _resetApplication(context, ref),
            tileColor: Colors.red.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema Tampilan'),
            trailing: DropdownButton<String>(
              value: currentMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'Light', child: Text('Terang')),
                DropdownMenuItem(value: 'Dark', child: Text('Gelap')),
                DropdownMenuItem(value: 'System', child: Text('Sistem')),
              ],
              onChanged: (newMode) async {
                if (newMode == null) return;
                if (profile == null) return;
                await ref
                    .read(dashboardActionServiceProvider)
                    .updateThemeMode(profile.userId, newMode);
                ref.invalidate(dashboardDataProvider);
                ref.invalidate(appThemeModeProvider);
              },
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.wb_twilight_rounded),
            title: const Text('Palet Sirkadian'),
            subtitle: const Text('Warna berubah sesuai waktu alam'),
            trailing: Switch(
              value: circadianEnabled,
              onChanged: (enabled) async {
                if (profile == null) return;
                await ref
                    .read(dashboardActionServiceProvider)
                    .toggleCircadianTheme(profile.userId, enabled);
                ref.invalidate(dashboardDataProvider);
                ref.invalidate(appThemeModeProvider);
              },
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(
              DaojiText.resolve(
                DaojiTextKey.settingsVocabularyStyle,
                vocabularyLevel,
              ),
            ),
            subtitle: Text(vocabularyLevel.description),
            trailing: DropdownButton<DaojiVocabularyLevel>(
              value: vocabularyLevel,
              underline: const SizedBox.shrink(),
              items: DaojiVocabularyLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.displayName),
                );
              }).toList(),
              onChanged: (newLevel) {
                if (newLevel != null) {
                  ref
                      .read(daojiVocabularyControllerProvider)
                      .setLevel(newLevel);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(
              devMode
                  ? Icons.developer_mode_rounded
                  : Icons.developer_mode_outlined,
              color: Colors.blueGrey,
            ),
            title: Text(
              DaojiText.resolve(DaojiTextKey.settingsDevMode, vocabularyLevel),
            ),
            subtitle: Text(
              DaojiText.resolve(
                DaojiTextKey.settingsDevModeSubtitle,
                vocabularyLevel,
              ),
            ),
            trailing: Switch(
              value: devMode,
              onChanged: (value) => _toggleDeveloperMode(ref, value),
            ),
          ),
        ],
      ),
    );
  }
}
