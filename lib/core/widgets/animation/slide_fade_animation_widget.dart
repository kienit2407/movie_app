// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';

// /// A reusable entrance animation that slides a widget in from a configurable
// /// direction while simultaneously fading in.
// ///
// /// **Replays animation** when the page becomes visible again after a pop.
// ///
// /// Example:
// /// ```dart
// /// SlideFadeAnimationWidget(
// ///   direction: SlideFadeDirection.fromBottom,
// ///   child: Card(child: Text('Hello!')),
// /// )
// /// ```
// class SlideFadeAnimationWidget extends StatefulWidget {
//   const SlideFadeAnimationWidget({
//     super.key,
//     required this.child,
//     this.direction = SlideFadeDirection.fromBottom,
//     this.offset = 40.0,
//     this.duration = const Duration(milliseconds: 500),
//     this.delay = Duration.zero,
//     this.curve = Curves.easeOutCubic,
//     this.animate = true,
//   });

//   /// The child widget to animate.
//   final Widget child;

//   /// The direction from which the widget slides in.
//   final SlideFadeDirection direction;

//   /// The initial offset distance in pixels.
//   final double offset;

//   /// Duration of the animation.
//   final Duration duration;

//   /// Optional delay before the animation starts.
//   final Duration delay;

//   /// The animation curve.
//   final Curve curve;

//   /// Whether to animate. Set to false to show the child immediately.
//   final bool animate;

//   @override
//   State<SlideFadeAnimationWidget> createState() =>
//       _SlideFadeAnimationWidgetState();
// }

// class _SlideFadeAnimationWidgetState extends State<SlideFadeAnimationWidget>
//     with SingleTickerProviderStateMixin, AutoRouteAwareStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _fadeAnimation;
//   late final Animation<Offset> _slideAnimation;
//   bool _wasHidden = false;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(vsync: this, duration: widget.duration);

//     final curvedAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: widget.curve,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(curvedAnimation);

//     _slideAnimation = Tween<Offset>(
//       begin: _getBeginOffset(),
//       end: Offset.zero,
//     ).animate(curvedAnimation);

//     if (widget.animate) {
//       _playAnimation();
//     } else {
//       _controller.value = 1.0;
//     }
//   }

//   @override
//   void didPopNext() {
//     super.didPopNext();
//     _replayAnimation();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final isVisible = TickerMode.of(context);
//     if (!isVisible) {
//       _wasHidden = true;
//     } else if (_wasHidden) {
//       _wasHidden = false;
//       _replayAnimation();
//     }
//   }

//   void _playAnimation() {
//     if (widget.delay == Duration.zero) {
//       _controller.forward();
//     } else {
//       Future.delayed(widget.delay, () {
//         if (mounted) {
//           _controller.forward();
//         }
//       });
//     }
//   }

//   void _replayAnimation() {
//     _controller.reset();
//     _playAnimation();
//   }

//   Offset _getBeginOffset() {
//     switch (widget.direction) {
//       case SlideFadeDirection.fromTop:
//         return Offset(0, -widget.offset);
//       case SlideFadeDirection.fromBottom:
//         return Offset(0, widget.offset);
//       case SlideFadeDirection.fromLeft:
//         return Offset(-widget.offset, 0);
//       case SlideFadeDirection.fromRight:
//         return Offset(widget.offset, 0);
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: _slideAnimation.value,
//           child: Opacity(opacity: _fadeAnimation.value, child: child),
//         );
//       },
//       child: widget.child,
//     );
//   }
// }

// /// Direction from which the widget slides into view.
// enum SlideFadeDirection {
//   /// Slides from top to bottom.
//   fromTop,

//   /// Slides from bottom to top.
//   fromBottom,

//   /// Slides from left to right.
//   fromLeft,

//   /// Slides from right to left.
//   fromRight,
// }
