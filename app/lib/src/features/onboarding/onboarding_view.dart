import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/domain/app_constants.dart';
import '../../core/providers/db_provider.dart';
import '../../data/local_db/database.dart';
import '../dashboard/dashboard_provider.dart';
import 'widgets/welcome_step.dart';
import 'widgets/age_step.dart';
import 'widgets/audit_step.dart';
import 'widgets/disclaimer_step.dart';

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

  static const int _readGateSeconds = 5;
  Timer? _readGateTimer;
  int _readSecondsRemaining = _readGateSeconds;
  bool _readGateElapsed = false;
  bool? _comprehensionCorrect;

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

    final profile = UserProfilesCompanion.insert(
      userId: userId,
      ageBand: _selectedAgeBand,
      supportMode: const drift.Value(SupportMode.normal),
      engagementState: const drift.Value(HabitStatus.active),
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

    final audit = LifeAuditsCompanion.insert(
      auditId: const Uuid().v4(),
      userId: userId,
      domainScores: domainScoresJson,
      timestamp: now,
    );

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
                    if (page == 3) {
                      _startReadGate();
                    }
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const WelcomeStep(),
                    AgeStep(
                      selectedAgeBand: _selectedAgeBand,
                      onAgeBandSelected: (band) {
                        setState(() {
                          _selectedAgeBand = band;
                        });
                      },
                    ),
                    AuditStep(
                      devMode: _devMode,
                      bodyScore: _bodyScore,
                      onBodyScoreChanged: (val) {
                        setState(() {
                          _bodyScore = val;
                        });
                      },
                      auditScores: _auditScores,
                      onAuditScoreChanged: (domain, val) {
                        setState(() {
                          _auditScores[domain] = val;
                        });
                      },
                    ),
                    DisclaimerStep(
                      disclaimerAccepted: _disclaimerAccepted,
                      onDisclaimerAcceptedChanged: (val) {
                        setState(() {
                          _disclaimerAccepted = val;
                        });
                      },
                      readSecondsRemaining: _readSecondsRemaining,
                      readGateElapsed: _readGateElapsed,
                      comprehensionCorrect: _comprehensionCorrect,
                      onComprehensionCorrectChanged: (val) {
                        setState(() {
                          _comprehensionCorrect = val;
                        });
                      },
                    ),
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
                        minimumSize: const Size(88, 48),
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
                      minimumSize: const Size(120, 48),
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
}

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(dbProvider);
  final profiles = await db.select(db.userProfiles).get();
  if (profiles.isEmpty) return false;
  return profiles.first.wellnessDisclaimerAcknowledged;
});
