import 'package:flutter/material.dart';

/// A reusable gentle expand animation — the widget scales up smoothly and
/// evenly from nothing to full size, without any bounce or elastic effect.
///
/// **Replays animation** when the page becomes visible again after a pop.
///
/// Example:
/// ```dart
/// GentleExpandAnimationNoPopWidget(
///   delay: Duration(milliseconds: 200),
///   child: Card(child: Text('Hello')),
/// )
/// ```
class GentleExpandAnimationNoPopWidget extends StatefulWidget {
  const GentleExpandAnimationNoPopWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
    this.beginScale = 0.0,
    this.endScale = 1.0,
    this.curve = Curves.easeOutCubic,
    this.animate = true,
  });

  /// The child widget to animate.
  final Widget child;

  /// Duration of the expand animation.
  final Duration duration;

  /// Optional delay before the animation starts.
  final Duration delay;

  /// Starting scale (0.0 = invisible).
  final double beginScale;

  /// Ending scale (1.0 = full size).
  final double endScale;

  /// Animation curve. Default [Curves.easeOutCubic] gives a smooth, gentle feel.
  final Curve curve;

  /// Whether to animate. Set to false to show the child immediately.
  final bool animate;

  @override
  State<GentleExpandAnimationNoPopWidget> createState() =>
      _GentleExpandAnimationNoPopWidgetState();
}

class _GentleExpandAnimationNoPopWidgetState
    extends State<GentleExpandAnimationNoPopWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(curvedAnimation);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    if (widget.animate) {
      _playAnimation();
    } else {
      _controller.value = 1.0;
    }
  }

  void _playAnimation() {
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}
