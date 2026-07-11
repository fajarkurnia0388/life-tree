import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/i18n/daoji_text_key.dart';
import '../../core/i18n/daoji_text_resolver.dart';
import '../../core/i18n/daoji_vocabulary_level.dart';
import '../../core/i18n/daoji_vocabulary_provider.dart';
import '../../core/providers/db_provider.dart';
import '../../core/services/error_handler_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/domain/app_constants.dart';

class WeeklyPulseView extends ConsumerStatefulWidget {
  const WeeklyPulseView({super.key});

  @override
  ConsumerState<WeeklyPulseView> createState() => _WeeklyPulseViewState();
}

class _WeeklyPulseViewState extends ConsumerState<WeeklyPulseView> {
  final List<int?> _answers = List.filled(5, null);
  final _reflectionController = TextEditingController();
  bool _isSaving = false;

  int _currentStep = 0;
  final PageController _pageController = PageController();

  List<String> _getQuestions(DaojiVocabularyLevel level) => [
        DaojiText.resolve(DaojiTextKey.weeklyPulseQuestion1, level),
        DaojiText.resolve(DaojiTextKey.weeklyPulseQuestion2, level),
        DaojiText.resolve(DaojiTextKey.weeklyPulseQuestion3, level),
        DaojiText.resolve(DaojiTextKey.weeklyPulseQuestion4, level),
        DaojiText.resolve(DaojiTextKey.weeklyPulseQuestion5, level),
      ];

  List<Map<String, dynamic>> _getOptions(DaojiVocabularyLevel level) => [
        {'value': 5, 'label': DaojiText.resolve(DaojiTextKey.weeklyPulseOption5, level)},
        {'value': 4, 'label': DaojiText.resolve(DaojiTextKey.weeklyPulseOption4, level)},
        {'value': 3, 'label': DaojiText.resolve(DaojiTextKey.weeklyPulseOption3, level)},
        {'value': 2, 'label': DaojiText.resolve(DaojiTextKey.weeklyPulseOption2, level)},
        {'value': 1, 'label': DaojiText.resolve(DaojiTextKey.weeklyPulseOption1, level)},
        {'value': 0, 'label': DaojiText.resolve(DaojiTextKey.weeklyPulseOption0, level)},
      ];

  Future<void> _submitPulse() async {
    if (_isSaving) return;
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    if (_answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DaojiText.resolve(
              DaojiTextKey.weeklyPulseAlertAnswerAll,
              vocabularyLevel,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final db = ref.read(dbProvider);

    try {
      final profiles = await db.select(db.userProfiles).get();
      if (profiles.isEmpty) throw Exception('Profil pengguna tidak ditemukan');
      final userId = profiles.first.userId;

      // 1. Calculate WHO-5 scores
      final totalRawScore = _answers.reduce(
        (value, element) => value! + element!,
      )!;
      // Map 0-25 range to SQLite 1-10 range for score column constraint
      final mappedScore = (totalRawScore / 2.5).round().clamp(1, 10);
      final percentage = totalRawScore * 4; // 0-100%

      // 2. Prepare JSON reflection text
      final metadata = {
        'raw_total': totalRawScore,
        'percentage': percentage,
        'answers': _answers,
        'user_reflection': _reflectionController.text.trim(),
      };

      // 3. Write into database
      final now = DateTime.now();
      final mondayOffset = now.weekday - DateTime.monday;
      final weekStartDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: mondayOffset));

      final existing =
          await (db.select(db.weeklyPulses)..where(
                (tbl) =>
                    tbl.userId.equals(userId) &
                    tbl.weekStartDate.equals(weekStartDate),
              ))
              .get();

      if (existing.isNotEmpty) {
        await (db.update(
          db.weeklyPulses,
        )..where((tbl) => tbl.pulseId.equals(existing.first.pulseId))).write(
          WeeklyPulsesCompanion(
            score: drift.Value(mappedScore),
            reflectionText: drift.Value(jsonEncode(metadata)),
          ),
        );
      } else {
        await db
            .into(db.weeklyPulses)
            .insert(
              WeeklyPulsesCompanion.insert(
                pulseId: const Uuid().v4(),
                userId: userId,
                domainTag: 'WHO-5',
                score: mappedScore,
                reflectionText: drift.Value(jsonEncode(metadata)),
                weekStartDate: weekStartDate,
              ),
            );
      }

      // Sync WHO-5 score to 'Emosi' domain in userProfiles.latestDomainScores
      final currentProfile = profiles.first;
      Map<String, dynamic> domainScores = {};
      if (currentProfile.latestDomainScores != null) {
        try {
          domainScores = jsonDecode(currentProfile.latestDomainScores!);
        } catch (e, stackTrace) {
          ErrorHandlerService().logError(
            e,
            stackTrace,
            context: 'WeeklyPulseView.parseDomainScores',
          );
        }
      }
      domainScores['Emosi'] = mappedScore.toDouble();
      final domainScoresJson = jsonEncode(domainScores);
      await (db.update(
        db.userProfiles,
      )..where((tbl) => tbl.userId.equals(userId))).write(
        UserProfilesCompanion(
          latestDomainScores: drift.Value(domainScoresJson),
          updatedAt: drift.Value(now),
        ),
      );

      // Log a historical snapshot of domain scores in lifeAudits table
      await db.into(db.lifeAudits).insert(
            LifeAuditsCompanion.insert(
              auditId: const Uuid().v4(),
              userId: userId,
              domainScores: domainScoresJson,
              timestamp: now,
            ),
          );

      // Auto-set SupportMode based on WHO-5 well-being threshold (< 50% = Recovery).
      // This is a protective intervention: system adapts to user's real condition.
      final newSupportMode = percentage < 50 ? SupportMode.recovery : SupportMode.normal;
      final recoveryEndDate = percentage < 50
          ? drift.Value<DateTime?>(now.add(const Duration(days: 7)))
          : const drift.Value<DateTime?>(null);
      await (db.update(db.userProfiles)
            ..where((tbl) => tbl.userId.equals(userId)))
          .write(UserProfilesCompanion(
        supportMode: drift.Value(newSupportMode),
        recoveryEndDate: recoveryEndDate,
        updatedAt: drift.Value(now),
      ));

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
        // Show wellness review prompt if WHO-5 is low (< 50%)
        final isLowMood = percentage < 50;
        if (isLowMood) {
          final profiles = await db.select(db.userProfiles).get();
          if (profiles.isNotEmpty) {
            await db
                .into(db.wellnessPromptLogs)
                .insert(
                  WellnessPromptLogsCompanion.insert(
                    promptId: const Uuid().v4(),
                    userId: profiles.first.userId,
                    triggerType: WellnessPromptTrigger.weeklyPulse,
                    promptedAt: DateTime.now(),
                  ),
                );
          }
        }
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                DaojiText.resolve(
                  isLowMood
                      ? DaojiTextKey.weeklyPulseTitleLow
                      : DaojiTextKey.weeklyPulseTitleHigh,
                  vocabularyLevel,
                ),
              ),
              content: Text(
                DaojiText.resolve(
                  isLowMood
                      ? DaojiTextKey.weeklyPulseDescriptionLow
                      : DaojiTextKey.weeklyPulseDescriptionHigh,
                  vocabularyLevel,
                  params: {'percentage': percentage},
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    context.go('/'); // Back to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    DaojiText.resolve(
                      DaojiTextKey.weeklyBackDashboard,
                      vocabularyLevel,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              DaojiText.resolve(
                DaojiTextKey.weeklyPulseSaveError,
                vocabularyLevel,
                params: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildQuestionCard(BuildContext context, int qIndex) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DaojiText.resolve(
                        DaojiTextKey.weeklyIntro,
                        vocabularyLevel,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DaojiText.resolve(
                        DaojiTextKey.weeklyPulseQuestionCount,
                        vocabularyLevel,
                        params: {'step': qIndex + 1, 'total': 5},
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getQuestions(vocabularyLevel)[qIndex],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 32),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: _getOptions(vocabularyLevel).map((opt) {
                          final isSelected = _answers[qIndex] == opt['value'];
                          return Card(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.08,
                                  )
                                : Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.15,
                                      ),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                              ),
                              title: Text(
                                opt['label'] as String,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                setState(() {
                                  _answers[qIndex] = opt['value'] as int?;
                                });
                                // Auto advance after 300ms for smooth transition
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    if (mounted && _currentStep == qIndex) {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.read(daojiVocabularyLevelValueProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DaojiText.resolve(
                  DaojiTextKey.weeklyPulseOptionalReflection,
                  vocabularyLevel,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                DaojiText.resolve(
                  DaojiTextKey.weeklyPulseReflectionHint,
                  vocabularyLevel,
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _reflectionController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: DaojiText.resolve(
                      DaojiTextKey.weeklyPulseReflectionPlaceholder,
                      vocabularyLevel,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);
    const totalSteps = 6;
    final isLastStep = _currentStep == totalSteps - 1;
    final canGoNext = _currentStep < 5 ? _answers[_currentStep] != null : true;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DaojiText.resolve(DaojiTextKey.weeklyTitle, vocabularyLevel),
        ),
      ),
      body: _isSaving
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(DaojiText.resolve(DaojiTextKey.weeklyPulseSaving, vocabularyLevel)),
                ],
              ),
            )
          : Column(
              children: [
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentStep + 1) / totalSteps,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    DaojiText.resolve(
                      DaojiTextKey.weeklyPulseStep,
                      vocabularyLevel,
                      params: {'step': _currentStep + 1, 'total': totalSteps},
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Stepper PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalSteps,
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    itemBuilder: (context, index) {
                      if (index < 5) {
                        return _buildQuestionCard(context, index);
                      } else {
                        return _buildReflectionCard(context);
                      }
                    },
                  ),
                ),
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            DaojiText.resolve(
                              DaojiTextKey.systemBack,
                              vocabularyLevel,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 100),
                      ElevatedButton(
                        onPressed: canGoNext
                            ? () {
                                if (!isLastStep) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _submitPulse();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          minimumSize: const Size(100, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isLastStep
                              ? DaojiText.resolve(
                                  DaojiTextKey.systemSubmit,
                                  vocabularyLevel,
                                )
                              : DaojiText.resolve(
                                  DaojiTextKey.systemNext,
                                  vocabularyLevel,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
