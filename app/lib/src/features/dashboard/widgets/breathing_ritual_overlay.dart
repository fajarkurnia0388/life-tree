import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/i18n/daoji_text_key.dart';
import '../../../core/i18n/daoji_text_resolver.dart';
import '../../../core/i18n/daoji_vocabulary_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BreathingRitualOverlay extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const BreathingRitualOverlay({super.key, required this.onComplete});

  static void show(BuildContext context, {required VoidCallback onComplete}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BreathingRitualOverlay(onComplete: onComplete),
    );
  }

  @override
  ConsumerState<BreathingRitualOverlay> createState() =>
      _BreathingRitualOverlayState();
}

class _BreathingRitualOverlayState extends ConsumerState<BreathingRitualOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  int _cycleCount = 0;
  String _currentPhase = 'Tarik Napas'; // Tarik, Tahan, Hembuskan, Tahan
  int _secondsRemaining = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 4.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    _controller.forward();
    HapticFeedback.mediumImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _secondsRemaining = 4;
          _transitionPhase();
        }
      });
    });
  }

  void _transitionPhase() {
    if (_currentPhase == 'Tarik Napas') {
      _currentPhase = 'Tahan Napas';
      _controller.stop(); // Hold scale at max
      HapticFeedback.lightImpact();
    } else if (_currentPhase == 'Tahan Napas') {
      _currentPhase = 'Hembuskan';
      _controller.reverse();
      HapticFeedback.mediumImpact();
    } else if (_currentPhase == 'Hembuskan') {
      _currentPhase = 'Tenang';
      _controller.stop(); // Hold scale at min
      HapticFeedback.lightImpact();
    } else {
      _currentPhase = 'Tarik Napas';
      _cycleCount++;
      if (_cycleCount >= 4) {
        _timer?.cancel();
        // REMOVED manual _controller.dispose() to prevent double-dispose crash
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop();
        widget.onComplete();
        return;
      }
      _controller.forward();
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose(); // Handled safely here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vocabularyLevel = ref.watch(daojiVocabularyLevelValueProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DaojiText.resolve(DaojiTextKey.breathingTitle, vocabularyLevel),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Box Breathing (4-4-4-4) • Siklus ${_cycleCount + 1}/4',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 60),
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 220,
                          height: 220,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 150 * _scaleAnimation.value,
                            height: 150 * _scaleAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    theme.colorScheme.primary.withValues(alpha: 0.85),
                                    theme.colorScheme.primary.withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.4, 0.85, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: _glowAnimation.value + 12,
                                    spreadRadius: _glowAnimation.value / 3,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.spa_rounded,
                                  size: 46 * _scaleAnimation.value,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                    Text(
                      _currentPhase,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_secondsRemaining detik',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 80),
                    OutlinedButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Lewati Ritual'),
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
}
