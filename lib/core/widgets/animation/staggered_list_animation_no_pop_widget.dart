import 'package:flutter/material.dart';

class StaggeredListAnimationNoPopWidget extends StatefulWidget {
  const StaggeredListAnimationNoPopWidget({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.slideOffset = 30.0,
    this.curve = Curves.easeOutCubic,
    this.direction = AxisDirection.up,
    this.shouldAnimate = true,
  });

  /// The index of this item in the list (used to calculate stagger delay).
  final int index;

  /// The child widget to animate.
  final Widget child;

  /// Base duration of the animation.
  final Duration baseDelay;

  /// Additional delay per index for the stagger effect.
  final Duration staggerDelay;

  /// The initial offset in pixels for the slide effect.
  final double slideOffset;

  /// The animation curve.
  final Curve curve;

  /// The direction the item slides in from.
  final AxisDirection direction;

  /// Whether the entrance animation should run when this widget is mounted.
  ///
  /// When false, the child is shown immediately in its completed state.
  final bool shouldAnimate;

  @override
  State<StaggeredListAnimationNoPopWidget> createState() =>
      _StaggeredListAnimationNoPopWidgetState();
}

class _StaggeredListAnimationNoPopWidgetState
    extends State<StaggeredListAnimationNoPopWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    final totalDuration = Duration(
      milliseconds:
          widget.baseDelay.inMilliseconds +
          (widget.index * widget.staggerDelay.inMilliseconds),
    );

    _controller = AnimationController(vsync: this, duration: totalDuration);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    if (widget.shouldAnimate) {
      _controller.forward();
    } else {
      _controller.value = 1;
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
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final offset = _calculateOffset(value);

        return Transform.translate(
          offset: offset,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: widget.child,
    );
  }

  Offset _calculateOffset(double value) {
    final remaining = widget.slideOffset * (1 - value);

    switch (widget.direction) {
      case AxisDirection.up:
        return Offset(0, remaining);
      case AxisDirection.down:
        return Offset(0, -remaining);
      case AxisDirection.left:
        return Offset(remaining, 0);
      case AxisDirection.right:
        return Offset(-remaining, 0);
    }
  }
}
