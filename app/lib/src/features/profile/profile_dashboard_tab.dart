import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/utils/profile_json_helpers.dart';
import '../../core/theme/button_theme.dart';
import '../../core/widgets/loading_state_widget.dart';
import '../../data/local_db/database.dart';
import '../cultivation/cultivation_provider.dart';
import '../cultivation/cultivation_strings.dart';
import '../cultivation/cultivation_constants.dart';
import '../dashboard/dashboard_provider.dart';
import '../dashboard/widgets/domain_insight_dialog.dart';
import '../dashboard/widgets/domain_scores_card.dart';
import '../dashboard/widgets/settings_bottom_sheet.dart';
import 'activity_heatmap_provider.dart';
import 'widgets/activity_heatmap_widget.dart';
import 'widgets/life_compass_section.dart';
class ProfileDashboardTab extends ConsumerStatefulWidget {
  const ProfileDashboardTab({super.key});

  @override
  ConsumerState<ProfileDashboardTab> createState() =>
      _ProfileDashboardTabState();
}

class _ProfileDashboardTabState extends ConsumerState<ProfileDashboardTab> {
  String _selectedDomainFilter = 'Semua';

  void _showCoreValuesDialog(BuildContext context, UserProfile profile) {
    final languageLevel = ref.read(cultivationLanguageLevelProvider);
    List<String> currentValues = ['', '', ''];
    final parsed = profile.parsedCoreValues;
    for (int i = 0; i < parsed.length && i < 3; i++) {
      currentValues[i] = parsed[i];
    }

    showDialog(
      context: context,
      builder: (context) {
        return _EditCompassDialog(
          profile: profile,
          initialValues: currentValues,
          languageLevel: languageLevel,
        );
      },
    );
  }

  Widget _buildVitalityRadarCard(DashboardData data) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    final scores = data.profile.parsedDomainScores;

    return DomainScoresCard(
      data: data,
      selectedDomain: _selectedDomainFilter,
      onDomainSelected: (domain) {
        final currentScore = scores[domain] ?? 5.0;
        DomainInsightDialog.show(
          context,
          domain: domain,
          score: currentScore,
          displayDomain: DaojiText.domainLabel(domain, vocabularyLevel),
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

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(dashboardDataProvider);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DaojiText.resolve(DaojiTextKey.navProfile, vocabularyLevel),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: DaojiText.resolve(
              DaojiTextKey.settingsTitle,
              vocabularyLevel,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                isScrollControlled: true,
                builder: (context) => const SettingsBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: dataAsync.when(
        data: (data) {
          final profile = data.profile;
          final activityDataAsync = ref.watch(
            activityHeatmapDataProvider(profile.userId),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildVitalityRadarCard(data),
                const SizedBox(height: 16),
                // Activity Heatmap
                activityDataAsync.when(
                  data: (activityData) {
                    final service = ref.read(activityHeatmapServiceProvider);
                    final dateRange = service.generateLast52Weeks();
                    return ActivityHeatmapWidget(
                      activityData: activityData,
                      dateRange: dateRange,
                    );
                  },
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: LoadingStateWidget(
                          message: 'Memuat aktivitas...',
                        ),
                      ),
                    ),
                  ),
                  error: (err, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Gagal memuat aktivitas: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LifeCompassSection(
                  profile: profile,
                  onEdit: () => _showCoreValuesDialog(context, profile),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: LoadingStateWidget(message: 'Memuat profil...')),
        error: (err, _) => Center(child: Text('Gagal memuat profil: $err')),
      ),
    );
  }
}

class _EditCompassDialog extends ConsumerStatefulWidget {
  final UserProfile profile;
  final List<String> initialValues;
  final CultivationLanguageLevel languageLevel;

  const _EditCompassDialog({
    required this.profile,
    required this.initialValues,
    required this.languageLevel,
  });

  @override
  ConsumerState<_EditCompassDialog> createState() => _EditCompassDialogState();
}

class _EditCompassDialogState extends ConsumerState<_EditCompassDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller1;
  late final TextEditingController _controller2;
  late final TextEditingController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController(text: widget.initialValues[0]);
    _controller2 = TextEditingController(text: widget.initialValues[1]);
    _controller3 = TextEditingController(text: widget.initialValues[2]);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        '${CultivationStrings.lifeCompassTitle(widget.languageLevel)} 🧭',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Panduan Memilih Nilai Inti',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Pilih nilai yang tetap ingin Anda jaga saat hidup sedang sulit\n'
                      '• Pilih nilai yang terasa paling penting dalam keputusan berulang\n'
                      '• Jika bingung, mulai dari 1 nilai dulu — Anda bisa tambah nanti',
                      style: TextStyle(fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    label: Text(
                      val,
                      style: const TextStyle(fontSize: 10),
                    ),
                    onPressed: () {
                      if (_controller1.text.trim().isEmpty) {
                        _controller1.text = val;
                      } else if (_controller2.text.trim().isEmpty) {
                        _controller2.text = val;
                      } else if (_controller3.text.trim().isEmpty) {
                        _controller3.text = val;
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller1,
                decoration: const InputDecoration(
                  labelText: 'Nilai 1',
                  hintText: 'Misal: Kesehatan',
                ),
                maxLength: 50,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Minimal isi 1 nilai inti';
                  }
                  if (value.trim().length < 2) {
                    return 'Minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller2,
                decoration: const InputDecoration(
                  labelText: 'Nilai 2 (opsional)',
                  hintText: 'Misal: Kebebasan',
                ),
                maxLength: 50,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 2) {
                    return 'Minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller3,
                decoration: const InputDecoration(
                  labelText: 'Nilai 3 (opsional)',
                  hintText: 'Misal: Belajar',
                ),
                maxLength: 50,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 2) {
                    return 'Minimal 2 karakter';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: AppButtonStyles.secondary(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: AppButtonStyles.primary(context),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final val1 = _controller1.text.trim();
            final val2 = _controller2.text.trim();
            final val3 = _controller3.text.trim();
            final values = [
              val1,
              val2,
              val3,
            ].where((v) => v.isNotEmpty).toList();

            final db = ref.read(dbProvider);
            try {
              await (db.update(
                db.userProfiles,
              )..where((tbl) => tbl.userId.equals(widget.profile.userId))).write(
                UserProfilesCompanion(
                  coreValues: drift.Value(values),
                ),
              );
              ref.invalidate(dashboardDataProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${CultivationStrings.lifeCompassTitle(widget.languageLevel)} berhasil disimpan!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menyimpan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
