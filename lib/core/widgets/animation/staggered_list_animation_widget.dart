import 'dart:async';

import 'package:flutter/material.dart';

/// A reusable widget that animates a list item sliding up and fading in
/// with a staggered delay based on its index.
///
/// **Replays animation** when the page becomes visible again after a pop.
///
/// Example:
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     return StaggeredListAnimationWidget(
///       index: index,
///       child: ListTile(title: Text(items[index])),
///     );
///   },
/// )
/// ```
class StaggeredListAnimationWidget extends StatefulWidget {
  const StaggeredListAnimationWidget({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.slideOffset = 30.0,
    this.curve = Curves.easeOutCubic,
    this.direction = AxisDirection.up,
  });

  /// The index of this item in the list (used to calculate stagger delay).
  final int index;

  /// The child widget to animate.
  final Widget child;

  /// Duration of the fade and slide animation after its stagger delay.
  final Duration baseDelay;

  /// Additional delay per index for the stagger effect.
  final Duration staggerDelay;

  /// The initial offset in pixels for the slide effect.
  final double slideOffset;

  /// The animation curve.
  final Curve curve;

  /// The direction the item slides in from.
  final AxisDirection direction;

  @override
  State<StaggeredListAnimationWidget> createState() =>
      _StaggeredListAnimationWidgetState();
}

class _StaggeredListAnimationWidgetState
    extends State<StaggeredListAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  Timer? _startTimer;
  bool? _reduceMotion;
  bool _wasHidden = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.baseDelay);

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isVisible = TickerMode.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (_reduceMotion != reduceMotion) {
      _reduceMotion = reduceMotion;
      if (reduceMotion) {
        _startTimer?.cancel();
        _controller.value = 1;
      } else if (isVisible) {
        _scheduleAnimation();
      } else {
        _wasHidden = true;
      }
      return;
    }

    if (!isVisible) {
      _startTimer?.cancel();
      _wasHidden = true;
    } else if (_wasHidden) {
      _wasHidden = false;
      _replayAnimation();
    }
  }

  void _scheduleAnimation() {
    _startTimer?.cancel();
    _controller.reset();

    final safeIndex = widget.index < 0 ? 0 : widget.index;
    final delay = Duration(
      milliseconds: safeIndex * widget.staggerDelay.inMilliseconds,
    );

    if (delay == Duration.zero) {
      _controller.forward();
      return;
    }

    _startTimer = Timer(delay, () {
      if (mounted) _controller.forward();
    });
  }

  void _replayAnimation() {
    if (_reduceMotion ?? false) {
      _controller.value = 1;
      return;
    }
    _scheduleAnimation();
  }

  @override
  void dispose() {
    _startTimer?.cancel();
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
