import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/domain/app_constants.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/services/snackbar_service.dart';
import '../../core/widgets/loading_state_widget.dart';
import '../../core/utils/profile_json_helpers.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/button_theme.dart';
import '../../core/animations/dialog_animations.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'marketplace_service.dart';
import 'models/marketplace_template_model.dart';
import 'widgets/share_template_bottom_sheet.dart';
import 'widgets/marketplace_template_card.dart';

class MarketplaceView extends ConsumerStatefulWidget {
  const MarketplaceView({super.key});

  @override
  ConsumerState<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends ConsumerState<MarketplaceView> {
  final _searchController = TextEditingController();
  String _selectedTemplateType = 'habit';
  String _selectedDomain = 'Semua';
  String _sortBy = 'Terpopuler';
  late Future<List<MarketplaceTemplateModel>> _templatesFuture;

  final List<String> _templateTypes = ['habit', 'core_value'];
  final Map<String, String> _templateTypeLabels = {
    'habit': '🎯 Kebiasaan',
    'core_value': '💎 Nilai Inti',
  };
  final List<String> _domains = [
    'Semua',
    'Tubuh',
    'Keuangan',
    'Hubungan',
    'Emosi',
    'Karir',
    'Rekreasi',
  ];
  final List<String> _sortOptions = ['Terpopuler', 'Terbaik', 'Terbaru'];

  @override
  void initState() {
    super.initState();
    _refreshTemplates();
  }

  void _refreshTemplates() {
    final service = ref.read(marketplaceServiceProvider);
    setState(() {
      _templatesFuture = service.fetchTemplates(
        templateType: _selectedTemplateType,
        domain: _selectedDomain,
        query: _searchController.text,
        sortBy: _sortBy,
      );
    });
  }

  Future<void> _downloadTemplate(MarketplaceTemplateModel t) async {
    if (t.isHabit) {
      await _downloadHabitTemplate(t);
    } else if (t.isCoreValue) {
      await _downloadCoreValueTemplate(t);
    }
  }

  Future<void> _downloadHabitTemplate(MarketplaceTemplateModel t) async {
    final dashboardAsync = ref.read(dashboardDataProvider);
    final isLowWellBeing = dashboardAsync.whenOrNull(data: (d) => d.isLowWellBeing) ?? false;
    if (isLowWellBeing) {
      if (mounted) {
        SnackBarService.showInfo(
          context,
          '🌿 Daoji menyarankan beristirahat sejenak.\n'
          'Kesehatan emosional Anda sedang dalam mode pemulihan. '
          'Selesaikan weekly pulse berikutnya untuk membuka kembali fitur ini.',
        );
      }
      return;
    }

    final db = ref.read(dbProvider);
    final service = ref.read(marketplaceServiceProvider);
    final meta = t.habitMetadata;
    if (meta == null) return;

    try {
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception('Profil tidak ditemukan');
      final userId = profiles.first.userId;

      final existing =
          await (db.select(db.habits)..where(
                (tbl) =>
                    tbl.userId.equals(userId) &
                    tbl.title.equals(t.title) &
                    tbl.deletedAt.isNull(),
              ))
              .get();

      if (existing.isNotEmpty) {
        if (mounted) {
          SnackBarService.showWarning(
            context,
            'Anda sudah memiliki kebiasaan "${t.title}"!',
          );
        }
        return;
      }

      final habitId = const Uuid().v4();
      final now = DateTime.now();

      final newHabit = HabitsCompanion.insert(
        habitId: habitId,
        userId: userId,
        domainTag: drift.Value(t.domainTag),
        title: t.title,
        status: const drift.Value(HabitStatus.active),
        frequency: const drift.Value('Daily'),
        initiationFriction: drift.Value(meta.friction),
        originalFriction: drift.Value(meta.friction),
        energyCost: drift.Value(meta.energy),
        impactScore: drift.Value(meta.impact),
        mvaDurationMin: drift.Value(meta.mvaDuration),
        createdAt: now,
      );

      final reminder = ReminderPreferencesCompanion.insert(habitId: habitId);

      await db.into(db.habits).insert(newHabit);
      await db.into(db.reminderPreferences).insert(reminder);
      await service.incrementDownloads(t.templateId);

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          'Kebiasaan "${t.title}" berhasil diunduh ke daftar lokal!',
        );
        _refreshTemplates();
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Gagal mengunduh: $e',
        );
      }
    }
  }

  Future<void> _downloadCoreValueTemplate(MarketplaceTemplateModel t) async {
    final db = ref.read(dbProvider);
    final service = ref.read(marketplaceServiceProvider);

    try {
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception('Profil tidak ditemukan');
      final profile = profiles.first;

      // Parse existing core values
      final currentValues = profile.parsedCoreValues;

      if (currentValues.contains(t.title)) {
        if (mounted) {
          SnackBarService.showWarning(
            context,
            '"${t.title}" sudah ada di nilai inti Anda!',
          );
        }
        return;
      }

      if (currentValues.length >= 3) {
        if (mounted) {
          SnackBarService.showWarning(
            context,
            'Nilai inti maksimal 3. Hapus salah satu terlebih dahulu.',
          );
        }
        return;
      }

      currentValues.add(t.title);
      await (db.update(
        db.userProfiles,
      )..where((tbl) => tbl.userId.equals(profile.userId))).write(
        UserProfilesCompanion(
          coreValues: drift.Value(const JsonEncoder().convert(currentValues)),
        ),
      );

      await service.incrementDownloads(t.templateId);
      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        SnackBarService.showSuccess(
          context,
          'Nilai "${t.title}" berhasil ditambahkan ke Life Compass!',
        );
        _refreshTemplates();
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(
          context,
          'Gagal mengunduh: $e',
        );
      }
    }
  }

  Future<void> _rateTemplate(MarketplaceTemplateModel t) async {
    final service = ref.read(marketplaceServiceProvider);
    int selectedStars = 5;

    final proceed = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                DaojiText.resolve(
                  DaojiTextKey.marketRateDialogTitle,
                  ref.read(daojiVocabularyLevelValueProvider),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DaojiText.resolve(
                      DaojiTextKey.marketRateDialogQuestion,
                      ref.read(daojiVocabularyLevelValueProvider),
                      params: {'title': t.title},
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= selectedStars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 36,
                        ),
                        tooltip: 'Pilih $starIndex bintang',
                        onPressed: () {
                          setDialogState(() {
                            selectedStars = starIndex;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: AppButtonStyles.secondary(context),
                  child: Text(
                    DaojiText.resolve(
                      DaojiTextKey.systemCancel,
                      ref.read(daojiVocabularyLevelValueProvider),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: AppButtonStyles.primary(context),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    DaojiText.resolve(
                      DaojiTextKey.systemSave,
                      ref.read(daojiVocabularyLevelValueProvider),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (proceed == true) {
      await service.rateTemplate(t.templateId, selectedStars);
      if (mounted) {
        SnackBarService.showSuccess(
          context,
          DaojiText.resolve(
            DaojiTextKey.marketRatingThanks,
            ref.read(daojiVocabularyLevelValueProvider),
          ),
        );
        _refreshTemplates();
      }
    }
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ShareTemplateBottomSheet(
          onSuccess: () {
            _refreshTemplates();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DaojiText.resolve(DaojiTextKey.marketTitle, vocabularyLevel),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: DaojiText.resolve(
              DaojiTextKey.marketShareTooltip,
              vocabularyLevel,
            ),
            onPressed: _showShareDialog,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Template Type Selector
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _templateTypes.length,
              itemBuilder: (context, index) {
                final type = _templateTypes[index];
                final label = _templateTypeLabels[type]!;
                final isSelected = _selectedTemplateType == type;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedTemplateType = type;
                        });
                        _refreshTemplates();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: DaojiText.resolve(
                  DaojiTextKey.marketSearchLabel,
                  vocabularyLevel,
                ),
                hintText: DaojiText.resolve(
                  DaojiTextKey.marketSearchHint,
                  vocabularyLevel,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Bersihkan pencarian',
                  onPressed: () {
                    _searchController.clear();
                    _refreshTemplates();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => _refreshTemplates(),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _domains.length,
              itemBuilder: (context, index) {
                final domain = _domains[index];
                final isSelected = _selectedDomain == domain;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(domain),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDomain = domain;
                        });
                        _refreshTemplates();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Urutkan:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _sortOptions.length,
                      itemBuilder: (context, index) {
                        final option = _sortOptions[index];
                        final isSelected = _sortBy == option;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              option,
                              style: const TextStyle(fontSize: 11),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _sortBy = option;
                                });
                                _refreshTemplates();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<MarketplaceTemplateModel>>(
              future: _templatesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingStateWidget(message: 'Memuat template...'),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}'),
                  );
                }

                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: DaojiText.resolve(
                      DaojiTextKey.marketNoTemplatesTitle,
                      vocabularyLevel,
                    ),
                    message: _searchController.text.isNotEmpty
                        ? DaojiText.resolve(
                            DaojiTextKey.marketNoTemplatesSearchMessage,
                            vocabularyLevel,
                          )
                        : DaojiText.resolve(
                            DaojiTextKey.marketNoTemplatesEmptyMessage,
                            vocabularyLevel,
                          ),
                    actionLabel: DaojiText.resolve(
                      DaojiTextKey.marketShareActionLabel,
                      vocabularyLevel,
                    ),
                    onAction: _showShareDialog,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final t = list[index];
                    return MarketplaceTemplateCard(
                      template: t,
                      onRate: () => _rateTemplate(t),
                      onDownload: () => _downloadTemplate(t),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
