import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import 'package:drift/drift.dart' as drift;
import '../dashboard/dashboard_provider.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form states
  String _selectedAgeBand = '18-24';
  double _bodyScore = 5.0;
  bool _disclaimerAccepted = false;
  bool _devMode = false;
  final Map<String, double> _auditScores = {
    'Tubuh': 5.0,
    'Keuangan': 5.0,
    'Hubungan': 5.0,
    'Emosi': 5.0,
    'Karir': 5.0,
    'Rekreasi': 5.0,
  };

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (!_disclaimerAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui pernyataan persetujuan keselamatan sebelum melanjutkan.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final db = ref.read(dbProvider);
    final userId = const Uuid().v4();
    final now = DateTime.now();

    final String domainScoresJson = _devMode
        ? jsonEncode(_auditScores.map((k, v) => MapEntry(k, v.toInt())))
        : '{"Tubuh": ${_bodyScore.toInt()}}';

    // 1. Create User Profile
    final profile = UserProfilesCompanion.insert(
      userId: userId,
      ageBand: _selectedAgeBand,
      supportMode: const drift.Value('Normal'),
      engagementState: const drift.Value('Active'),
      timezone: const drift.Value('Asia/Jakarta'),
      weekStartDay: const drift.Value(1),
      latestDomainScores: drift.Value(domainScoresJson),
      canopyLoadCapacity: const drift.Value(10),
      wellnessDisclaimerAcknowledged: const drift.Value(true),
      unlockedSkins: drift.Value(_devMode ? 'Default,Sakura,Maple,Bonsai' : 'Default'),
      isDeveloperMode: drift.Value(_devMode),
      createdAt: now,
      updatedAt: now,
    );

    // 2. Create Life Audit
    final audit = LifeAuditsCompanion.insert(
      auditId: const Uuid().v4(),
      userId: userId,
      domainScores: domainScoresJson,
      timestamp: now,
    );

    // 3. Create Consent Log
    final consent = ConsentLogsCompanion.insert(
      consentId: const Uuid().v4(),
      userId: userId,
      consentType: 'Wellness_Disclaimer',
      grantedAt: now,
      version: 'Wellness_v1.0',
    );

    await db.transaction(() async {
      await db.into(db.userProfiles).insert(profile);
      await db.into(db.lifeAudits).insert(audit);
      await db.into(db.consentLogs).insert(consent);
    });

    // Refresh onboarding state provider and navigate
    ref.invalidate(onboardingCompletedProvider);
    ref.invalidate(dashboardDataProvider);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWelcomeStep(theme),
                    _buildAgeStep(theme),
                    _buildAuditStep(theme),
                    _buildDisclaimerStep(theme),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(88, 48), // WCAG touch target
                      ),
                      child: Text('Kembali', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    )
                  else
                    const SizedBox(width: 88),
                  ElevatedButton(
                    onPressed: _currentPage == 3 ? _completeOnboarding : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(120, 48), // WCAG touch target
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(_currentPage == 3 ? 'Mulai' : 'Lanjut'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '🌳',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        Text(
          'Selamat Datang di LifeTree',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Sebuah Personal OS untuk membantumu berorientasi diri secara damai tanpa rasa bersalah (Anti-Guilt).',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          color: theme.colorScheme.primary.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.12)),
          ),
          child: SwitchListTile(
            title: const Text('Mode Developer', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Aktifkan untuk membuka semua skin pohon & mengakses seluruh 6 domain saat onboarding.'),
            value: _devMode,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _devMode = val;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgeStep(ThemeData theme) {
    final ageBands = ['Under 18', '18-24', '25-35', '36-45', '46+'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Berapa usia Anda?',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Kami menyesuaikan lingkungan dukungan berdasarkan rentang usia Anda.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...ageBands.map((band) {
          final isSelected = _selectedAgeBand == band;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedAgeBand = band;
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54), // WCAG touch target
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.12),
                  width: isSelected ? 2 : 1,
                ),
                backgroundColor: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                band,
                style: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAuditStep(ThemeData theme) {
    if (_devMode) {
      final domains = ['Tubuh', 'Keuangan', 'Hubungan', 'Emosi', 'Karir', 'Rekreasi'];
      final domainEmojis = {
        'Tubuh': '🏃',
        'Keuangan': '💰',
        'Hubungan': '🤝',
        'Emosi': '🧠',
        'Karir': '📚',
        'Rekreasi': '🎮',
      };
      final domainDescriptions = {
        'Tubuh': 'Kondisi fisik & energi Anda hari ini',
        'Keuangan': 'Kestabilan & kenyamanan finansial Anda',
        'Hubungan': 'Kualitas relasi sosial & keluarga',
        'Emosi': 'Kedamaian batin & kontrol kecemasan',
        'Karir': 'Perkembangan karir & rencana belajar',
        'Rekreasi': 'Kepuasan waktu istirahat & hobi',
      };

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Evaluasi Awal (Full Life Audit)',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mode Developer Aktif: Evaluasi seluruh 6 domain kehidupan.',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...domains.map((domain) {
              final score = _auditScores[domain]!;
              final emoji = domainEmojis[domain]!;
              final desc = domainDescriptions[domain]!;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  domain,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  desc,
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            score.toInt().toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: score,
                        min: 1.0,
                        max: 10.0,
                        divisions: 9,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                        onChanged: (val) {
                          setState(() {
                            _auditScores[domain] = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Evaluasi Awal (Life Audit)',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('🏃', style: TextStyle(fontSize: 32)),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Domain Fokus Pertama: Tubuh',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Bagaimana kondisi fisik & energi Anda hari ini?',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '1 = Sangat lelah/Sakit, 10 = Bugar/Sangat berenergi',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _bodyScore.toInt().toString(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Slider(
          value: _bodyScore,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
          onChanged: (val) {
            setState(() {
              _bodyScore = val;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDisclaimerStep(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Komitmen Keselamatan',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
            ),
            child: SingleChildScrollView(
              child: Text(
                'Disclaimer Penting:\n\n'
                '1. LifeTree BUKAN merupakan aplikasi medis atau alat diagnosis psikologis klinis. Layanan ini dirancang sebagai jurnal orientasi diri dan pemantau kebiasaan (habit tracker) pribadi.\n\n'
                '2. Kami tidak memberikan saran medis, diagnosis, maupun perawatan kesehatan mental secara profesional.\n\n'
                '3. Aplikasi ini bekerja 100% secara offline-first pada perangkat Anda untuk menjamin privasi penuh. Seluruh data Anda disimpan secara lokal.\n\n'
                '4. Jika Anda mengalami kondisi krisis emosional atau membutuhkan bantuan segera, harap gunakan tombol Safety Card untuk melihat daftar kontak darurat layanan bantuan profesional (seperti SEJIWA 119 Ext 8).',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _disclaimerAccepted,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                setState(() {
                  _disclaimerAccepted = val ?? false;
                });
              },
            ),
            const Expanded(
              child: Text(
                'Saya memahami dan menyetujui pernyataan keselamatan di atas.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Global state provider for onboarding status checking
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(dbProvider);
  final profiles = await db.select(db.userProfiles).get();
  if (profiles.isEmpty) return false;
  return profiles.first.wellnessDisclaimerAcknowledged;
});
