import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
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

  final List<String> _questions = [
    'Saya merasa ceria dan bersemangat',
    'Saya merasa tenang dan rileks',
    'Saya merasa aktif dan penuh vitalitas',
    'Saya bangun tidur dengan perasaan segar dan istirahat yang cukup',
    'Kehidupan sehari-hari saya dipenuhi dengan hal-hal yang menarik bagi saya',
  ];

  final List<Map<String, dynamic>> _options = [
    {'value': 5, 'label': 'Sepanjang waktu'},
    {'value': 4, 'label': 'Sebagian besar waktu'},
    {'value': 3, 'label': 'Lebih dari separuh waktu'},
    {'value': 2, 'label': 'Kurang dari separuh waktu'},
    {'value': 1, 'label': 'Sesekali'},
    {'value': 0, 'label': 'Tidak pernah'},
  ];

  Future<void> _submitPulse() async {
    if (_answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap jawab semua 5 pertanyaan sebelum mengirim.'),
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
      await (db.update(
        db.userProfiles,
      )..where((tbl) => tbl.userId.equals(userId))).write(
        UserProfilesCompanion(
          latestDomainScores: drift.Value(jsonEncode(domainScores)),
          updatedAt: drift.Value(now),
        ),
      );

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
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
              title: Text(isLowMood ? 'Refleksi Diri 🌱' : 'Luar Biasa! ✨'),
              content: Text(
                isLowMood
                    ? 'Skor kesejahteraan emosional Anda berada di angka $percentage%. Minggu ini mungkin terasa berat. Beristirahatlah sejenak dan pertimbangkan untuk mengaktifkan Recovery Mode.'
                    : 'Skor kesejahteraan emosional Anda sangat baik ($percentage%). Pertahankan konsistensi pertumbuhan pohon Anda minggu depan!',
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
                  child: const Text('Kembali ke Dashboard'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan Weekly Pulse: $e'),
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
                      'Jawablah sejujur mungkin berdasarkan apa yang Anda rasakan selama 2 minggu terakhir.',
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
                      'Pertanyaan ${qIndex + 1} dari 5',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _questions[qIndex],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 32),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: _options.map((opt) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Refleksi Diri (Opsional) ✍️',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Tuliskan catatan refleksi mingguan Anda, hambatan terbesar Anda, atau hal yang paling disyukuri minggu ini.',
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
                    hintText: 'Tulis refleksi Anda di sini...',
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
    const totalSteps = 6;
    final isLastStep = _currentStep == totalSteps - 1;
    final canGoNext = _currentStep < 5 ? _answers[_currentStep] != null : true;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Pulse Check')),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyimpan hasil refleksi mingguan...'),
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
                    'Langkah ${_currentStep + 1} dari $totalSteps',
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
                          child: const Text('Kembali'),
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
                        child: Text(isLastStep ? 'Kirim' : 'Lanjut'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
