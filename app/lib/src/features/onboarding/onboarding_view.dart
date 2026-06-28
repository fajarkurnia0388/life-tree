import 'dart:async';
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
  final bool _devMode = false;

  // P0-08: Disclaimer progressive disclosure gating
  static const int _readGateSeconds = 5;
  Timer? _readGateTimer;
  int _readSecondsRemaining = _readGateSeconds;
  bool _readGateElapsed = false;
  // Comprehension check: null = unanswered, true = correct, false = wrong
  bool? _comprehensionCorrect;

  bool get _canAcceptDisclaimer => _readGateElapsed;
  bool get _disclaimerComplete =>
      _disclaimerAccepted && _readGateElapsed && _comprehensionCorrect == true;
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

  // P0-08: Start the mandatory read gate countdown when reaching the
  // disclaimer step. Idempotent — does nothing if already running/elapsed.
  void _startReadGate() {
    if (_readGateElapsed || _readGateTimer != null) return;
    _readSecondsRemaining = _readGateSeconds;
    _readGateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _readSecondsRemaining--;
        if (_readSecondsRemaining <= 0) {
          _readGateElapsed = true;
          timer.cancel();
          _readGateTimer = null;
        }
      });
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _readGateTimer?.cancel();
    _pageController.dispose();
    super.dispose();
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
                      color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.primary.withValues(alpha: 0.2),
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
                    // P0-08: begin mandatory read countdown on disclaimer step.
                    if (page == 3) {
                      _startReadGate();
                    }
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
                      child: Text('Kembali', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    )
                  else
                    const SizedBox(width: 88),
                  ElevatedButton(
                    onPressed: _currentPage == 3
                        ? (_disclaimerComplete ? _completeOnboarding : null)
                        : _nextPage,
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...ageBands.map((band) {
          final isSelected = _selectedAgeBand == band;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: 'Pilih kelompok usia $band',
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedAgeBand = band;
                  });
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54), // WCAG touch target
                  side: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                    width: isSelected ? 2 : 1,
                  ),
                  backgroundColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
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
                  side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
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
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
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
                        inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
          inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.2),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // (a) Bold one-line headline
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🌱', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LifeTree BUKAN aplikasi medis.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Luangkan waktu sebentar untuk membaca. Tidak perlu terburu-buru.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // (b) Progressive disclosure: expandable detail sections
          _buildDisclaimerSection(
            theme,
            title: 'Apa itu LifeTree?',
            icon: Icons.spa_outlined,
            body:
                'LifeTree adalah jurnal orientasi diri dan pendamping kebiasaan '
                '(habit tracker) pribadi. Tujuannya membantumu berorientasi diri '
                'secara damai tanpa rasa bersalah — bukan untuk mendiagnosis '
                'atau merawat kondisi apa pun.',
          ),
          _buildDisclaimerSection(
            theme,
            title: 'Batasan Penting',
            icon: Icons.info_outline,
            body:
                'LifeTree BUKAN aplikasi medis atau alat diagnosis psikologis klinis. '
                'Kami tidak memberikan saran medis, diagnosis, maupun perawatan '
                'kesehatan mental secara profesional.\n\n'
                'Jika kamu mengalami kondisi krisis emosional atau membutuhkan '
                'bantuan segera, gunakan tombol Safety Card untuk melihat daftar '
                'kontak darurat layanan bantuan profesional (seperti SEJIWA 119 Ext 8).',
          ),
          _buildDisclaimerSection(
            theme,
            title: 'Privasi & Data',
            icon: Icons.lock_outline,
            body:
                'Aplikasi ini bekerja 100% secara offline-first pada perangkatmu '
                'untuk menjamin privasi penuh. Seluruh datamu disimpan secara lokal '
                'di perangkat ini.',
          ),
          const SizedBox(height: 16),

          // (d) Lightweight comprehension check
          _buildComprehensionCheck(theme),
          const SizedBox(height: 16),

          // (c) Acceptance checkbox, gated by read countdown
          _buildAcceptanceRow(theme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required String body,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.08)),
      ),
      child: Theme(
        // Remove ExpansionTile's default divider lines for a cleaner look.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: theme.colorScheme.primary),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComprehensionCheck(ThemeData theme) {
    // 2 options; the first is correct.
    const options = <String>[
      'Pendamping kebiasaan (bukan medis)',
      'Alat diagnosis & perawatan medis',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sebelum lanjut, LifeTree adalah aplikasi...?',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (index) {
            final isCorrectOption = index == 0;
            final isSelected = _comprehensionCorrect != null &&
                ((isCorrectOption && _comprehensionCorrect == true) ||
                    (!isCorrectOption && _comprehensionCorrect == false));
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: 'Pilih jawaban: ${options[index]}',
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _comprehensionCorrect = isCorrectOption;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48), // WCAG touch target
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    backgroundColor: isSelected
                        ? (isCorrectOption
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.redAccent.withValues(alpha: 0.08))
                        : Colors.transparent,
                    side: BorderSide(
                      color: isSelected
                          ? (isCorrectOption ? theme.colorScheme.primary : Colors.redAccent)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          options[index],
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          isCorrectOption ? Icons.check_circle : Icons.cancel_outlined,
                          size: 20,
                          color: isCorrectOption ? theme.colorScheme.primary : Colors.redAccent,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_comprehensionCorrect == false) ...[
            const SizedBox(height: 8),
            Text(
              'Coba lagi ya — LifeTree hadir sebagai pendamping, bukan layanan medis.',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcceptanceRow(ThemeData theme) {
    final enabled = _canAcceptDisclaimer;
    final countdownLabel = 'Baca dulu... (${_readSecondsRemaining}s)';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          checked: _disclaimerAccepted,
          label: enabled
              ? 'Saya memahami dan menyetujui pernyataan keselamatan'
              : countdownLabel,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled
                ? () {
                    setState(() {
                      _disclaimerAccepted = !_disclaimerAccepted;
                    });
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44, // WCAG touch target
                    child: Checkbox(
                      value: _disclaimerAccepted,
                      activeColor: theme.colorScheme.primary,
                      onChanged: enabled
                          ? (val) {
                              setState(() {
                                _disclaimerAccepted = val ?? false;
                              });
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Saya memahami dan menyetujui pernyataan keselamatan di atas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!enabled) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined,
                  size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Text(
                countdownLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
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
