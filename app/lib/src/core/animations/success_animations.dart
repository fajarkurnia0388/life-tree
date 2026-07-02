import 'package:flutter/material.dart';

/// Success animation helpers untuk memberikan feedback visual positif
/// kepada pengguna setelah menyelesaikan aksi penting
class SuccessAnimations {
  SuccessAnimations._();

  /// Menampilkan success checkmark animation dengan haptic feedback
  static void showSuccessCheckmark(BuildContext context, {String? message}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _SuccessCheckmarkOverlay(message: message),
    );

    overlay.insert(overlayEntry);

    // Auto remove after animation completes
    Future.delayed(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }

  /// Menampilkan success snackbar dengan slide animation
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50), // Material Green 500
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Konfetti animation untuk milestone achievements
  static void showConfetti(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => const _ConfettiOverlay(),
    );

    overlay.insert(overlayEntry);

    // Auto remove after animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      overlayEntry.remove();
    });
  }

  /// Success ripple animation untuk button press
  static Widget successRipple({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return _SuccessRippleButton(onTap: onTap, child: child);
  }
}

/// Success checkmark overlay dengan scale dan fade animation
class _SuccessCheckmarkOverlay extends StatefulWidget {
  final String? message;

  const _SuccessCheckmarkOverlay({this.message});

  @override
  State<_SuccessCheckmarkOverlay> createState() =>
      _SuccessCheckmarkOverlayState();
}

class _SuccessCheckmarkOverlayState extends State<_SuccessCheckmarkOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Start fade out after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 64,
                    ),
                    if (widget.message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.message!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple confetti overlay animation
class _ConfettiOverlay extends StatefulWidget {
  const _ConfettiOverlay();

  @override
  State<_ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<_ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ConfettiPainter(_controller.value),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }
}

/// Painter untuk confetti particles
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors = [
    const Color(0xFF7C9A72), // Primary sage
    const Color(0xFF6B8F9E), // Secondary blue
    const Color(0xFFD4A574), // Accent gold
    const Color(0xFFE57373), // Light red
    const Color(0xFF81C784), // Light green
  ];

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Generate 30 confetti particles
    for (int i = 0; i < 30; i++) {
      final x = (i * 37) % size.width;
      final y = (progress * size.height) - ((i * 23) % (size.height * 0.3));
      final color = colors[i % colors.length];
      final rotation = (i * 0.5 + progress * 6.28) % 6.28;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      paint.color = color.withValues(alpha: 1.0 - progress);
      canvas.drawRect(const Rect.fromLTWH(-5, -5, 10, 10), paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Success ripple button wrapper
class _SuccessRippleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SuccessRippleButton({required this.child, required this.onTap});

  @override
  State<_SuccessRippleButton> createState() => _SuccessRippleButtonState();
}

class _SuccessRippleButtonState extends State<_SuccessRippleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onTap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.05),
            child: widget.child,
          );
        },
      ),
    );
  }
}
