import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreathingRitualOverlay extends StatefulWidget {
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
  State<BreathingRitualOverlay> createState() => _BreathingRitualOverlayState();
}

class _BreathingRitualOverlayState extends State<BreathingRitualOverlay>
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
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
        _controller.dispose();
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
    if (_controller.isAnimating || _controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.dismissed) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ritual Penenang Mulai',
                style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Box Breathing (4-4-4-4) • Siklus ${_cycleCount + 1}/4',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: _glowAnimation.value,
                          spreadRadius: _glowAnimation.value / 2,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: const Text('🌳', style: TextStyle(fontSize: 72)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 60),
              Text(
                _currentPhase,
                style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$_secondsRemaining detik',
                style: const TextStyle(color: Colors.white70, fontSize: 24, fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Lewati Ritual'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
