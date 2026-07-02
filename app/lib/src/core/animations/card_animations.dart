import 'package:flutter/material.dart';

/// Widget untuk animasi highlight saat card dipilih
class AnimatedHighlightCard extends StatefulWidget {
  final Widget child;
  final bool isHighlighted;
  final Color? highlightColor;
  final Duration duration;

  const AnimatedHighlightCard({
    super.key,
    required this.child,
    required this.isHighlighted,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedHighlightCard> createState() => _AnimatedHighlightCardState();
}

class _AnimatedHighlightCardState extends State<AnimatedHighlightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.isHighlighted) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedHighlightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = widget.highlightColor ?? 
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.transparent,
              highlightColor,
              _animation.value,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Widget untuk animasi pulse pada tree growth atau achievement
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 1.0,
    this.maxScale = 1.05,
    this.repeat = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// Widget untuk animasi toggle habit (scale + fade)
class HabitToggleAnimation extends StatefulWidget {
  final Widget child;
  final bool isDone;
  final VoidCallback? onAnimationComplete;

  const HabitToggleAnimation({
    super.key,
    required this.child,
    required this.isDone,
    this.onAnimationComplete,
  });

  @override
  State<HabitToggleAnimation> createState() => _HabitToggleAnimationState();
}

class _HabitToggleAnimationState extends State<HabitToggleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(HabitToggleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDone != oldWidget.isDone) {
      if (widget.isDone) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget untuk animasi slide + fade untuk page transitions
class SlideAndFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset begin;
  final Offset end;

  const SlideAndFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.begin = const Offset(1.0, 0.0),
    this.end = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ),
        child: child,
      ),
    );
  }
}
