import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/snackbar_service.dart';
import 'services/onboarding_service.dart';
import '../../core/theme/button_theme.dart';
import '../dashboard/dashboard_provider.dart';
import 'widgets/welcome_step.dart';
import 'widgets/cultivation_theme_step.dart';
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
  bool _cultivationThemeEnabled = true;
  String _selectedAgeBand = '18-24';
  double _bodyScore = 5.0;
  bool _disclaimerAccepted = false;

  static const int _readGateSeconds = 15;
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
    if (_currentPage < 4) {
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

  void _startReadGateIfNeeded() {
    if (_currentPage == 4) {
      _readGateElapsed = false;
      _comprehensionCorrect = null;
      _readSecondsRemaining = _readGateSeconds;
      _readGateTimer?.cancel();
      _readGateTimer = null;
      _startReadGate();
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

  @override
  void dispose() {
    _readGateTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!_disclaimerAccepted) {
      SnackBarService.showError(
        context,
        'Anda harus menyetujui pernyataan persetujuan keselamatan sebelum melanjutkan.',
      );
      return;
    }

    final userId = const Uuid().v4();

    try {
      await ref.read(onboardingServiceProvider).completeOnboarding(
            userId: userId,
            ageBand: _selectedAgeBand,
            domainScores: _auditScores,
            cultivationThemeEnabled: _cultivationThemeEnabled,
          );

      ref.invalidate(onboardingCompletedProvider);
      ref.invalidate(dashboardDataProvider);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'Gagal menyelesaikan onboarding: $e');
      }
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
                children: List.generate(5, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.2),
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
                    _startReadGateIfNeeded();
                  },
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const WelcomeStep(),
                    CultivationThemeStep(
                      cultivationThemeEnabled: _cultivationThemeEnabled,
                      onChanged: (enabled) {
                        setState(() {
                          _cultivationThemeEnabled = enabled;
                        });
                      },
                    ),
                    AgeStep(
                      selectedAgeBand: _selectedAgeBand,
                      onAgeBandSelected: (band) {
                        setState(() {
                          _selectedAgeBand = band;
                        });
                      },
                    ),
                    AuditStep(
                      devMode: true,
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
                      child: Text(
                        'Kembali',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 88),
                  ElevatedButton(
                    style: AppButtonStyles.primary(context).copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(120, 48)),
                    ),
                    onPressed: _currentPage == 4
                        ? (_disclaimerComplete ? _completeOnboarding : null)
                        : _nextPage,
                    child: Text(_currentPage == 4 ? 'Mulai' : 'Lanjut'),
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
  return await ref.watch(onboardingServiceProvider).isOnboardingCompleted();
});
