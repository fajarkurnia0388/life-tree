import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Seasonal / mode overlays for the tree vitality card.
class SnowOverlayWidget extends StatefulWidget {
  const SnowOverlayWidget({super.key});

  @override
  State<SnowOverlayWidget> createState() => _SnowOverlayWidgetState();
}

/// Stable night-sky overlay for Quiet Integration mode.
class QuietIntegrationOverlay extends StatelessWidget {
  const QuietIntegrationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(child: _QuietIntegrationGradient()),
        Positioned(left: 48, top: 56, child: _SoftStar(size: 3.5, alpha: 0.42)),
        Positioned(
          right: 72,
          top: 92,
          child: _SoftStar(size: 2.5, alpha: 0.36),
        ),
        Positioned(
          left: 96,
          bottom: 84,
          child: _SoftStar(size: 2.8, alpha: 0.32),
        ),
        Positioned(
          right: 44,
          bottom: 64,
          child: _SoftStar(size: 3.2, alpha: 0.38),
        ),
      ],
    );
  }
}

class _QuietIntegrationGradient extends StatelessWidget {
  const _QuietIntegrationGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CalmTheme.secondaryBlue.withValues(alpha: 0.12),
            CalmTheme.secondaryBlue.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _SoftStar extends StatelessWidget {
  final double size;
  final double alpha;

  const _SoftStar({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: alpha * 0.55),
            blurRadius: size * 2.8,
            spreadRadius: size * 0.8,
          ),
        ],
      ),
    );
  }
}

/// Stateful widget for subtle pulsing blue aura in Tribulation mode.
class TribulationAuraWidget extends StatefulWidget {
  const TribulationAuraWidget({super.key});

  @override
  State<TribulationAuraWidget> createState() => _TribulationAuraWidgetState();
}

class _TribulationAuraWidgetState extends State<TribulationAuraWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.08,
      end: 0.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Colors.blue.shade700.withValues(alpha: _pulseAnimation.value),
                Colors.blue.shade300.withValues(
                  alpha: _pulseAnimation.value * 0.5,
                ),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SnowOverlayWidgetState extends State<SnowOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Snowflake> _snowflakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize 35 snowflakes with random distributions
    final random = math.Random(42);
    _snowflakes = List.generate(35, (index) {
      return _Snowflake(
        xRatio: random.nextDouble(),
        yRatio: random.nextDouble(),
        speed: 0.05 + random.nextDouble() * 0.1,
        swaySpeed: 0.5 + random.nextDouble() * 1.5,
        swayAmplitude: 0.01 + random.nextDouble() * 0.02,
        radius: 1.5 + random.nextDouble() * 2.5,
        opacity: 0.3 + random.nextDouble() * 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AnimatedSnowPainter(
            snowflakes: _snowflakes,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _Snowflake {
  final double xRatio;
  final double yRatio;
  final double speed;
  final double swaySpeed;
  final double swayAmplitude;
  final double radius;
  final double opacity;

  _Snowflake({
    required this.xRatio,
    required this.yRatio,
    required this.speed,
    required this.swaySpeed,
    required this.swayAmplitude,
    required this.radius,
    required this.opacity,
  });
}

class _AnimatedSnowPainter extends CustomPainter {
  final List<_Snowflake> snowflakes;
  final double progress;

  _AnimatedSnowPainter({required this.snowflakes, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final flake in snowflakes) {
      // Calculate current falling y position
      double y = (flake.yRatio + progress * flake.speed * 10) % 1.0;
      y *= size.height;

      // Calculate horizontal sway using sine wave
      final swayAngle = progress * 2 * math.pi * flake.swaySpeed;
      final sway = math.sin(swayAngle) * flake.swayAmplitude * size.width;
      double x = (flake.xRatio * size.width + sway) % size.width;

      paint.color = Colors.white.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(x, y), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedSnowPainter oldDelegate) => true;
}

