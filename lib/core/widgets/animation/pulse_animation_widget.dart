// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';

// /// A reusable widget that applies a repeating pulse (scale oscillation)
// /// to draw attention to important UI elements.
// ///
// /// **Restarts animation** when the page becomes visible again after a pop.
// ///
// /// Example:
// /// ```dart
// /// PulseAnimationWidget(
// ///   child: Icon(Icons.notifications, color: Colors.red, size: 32),
// /// )
// /// ```
// class PulseAnimationWidget extends StatefulWidget {
//   const PulseAnimationWidget({
//     super.key,
//     required this.child,
//     this.minScale = 0.95,
//     this.maxScale = 1.05,
//     this.duration = const Duration(milliseconds: 1200),
//     this.curve = Curves.easeInOut,
//     this.enabled = true,
//     this.glowColor,
//     this.glowRadius = 8.0,
//   });

//   /// The child widget to pulse.
//   final Widget child;

//   /// Minimum scale during the pulse.
//   final double minScale;

//   /// Maximum scale during the pulse.
//   final double maxScale;

//   /// Duration of one full pulse cycle (in + out).
//   final Duration duration;

//   /// The animation curve.
//   final Curve curve;

//   /// Whether the pulse animation is active.
//   final bool enabled;

//   /// Optional: color for a glow effect around the child. Set to null to disable.
//   final Color? glowColor;

//   /// Radius of the glow effect.
//   final double glowRadius;

//   @override
//   State<PulseAnimationWidget> createState() => _PulseAnimationWidgetState();
// }

// class _PulseAnimationWidgetState extends State<PulseAnimationWidget>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scaleAnimation;
//   bool _wasHidden = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: widget.minScale,
//       end: widget.maxScale,
//     ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

//     if (widget.enabled) {
//       _controller.repeat(reverse: true);
//     }
//   }

//   // @override
//   // void didPopNext() {
//   //   super.didPopNext();
//   //   if (widget.enabled && !_controller.isAnimating) {
//   //     _controller.repeat(reverse: true);
//   //   }
//   // }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final isVisible = TickerMode.of(context);
//     if (!isVisible) {
//       _wasHidden = true;
//     } else if (_wasHidden) {
//       _wasHidden = false;
//       if (widget.enabled && !_controller.isAnimating) {
//         _controller.repeat(reverse: true);
//       }
//     }
//   }

//   @override
//   void didUpdateWidget(covariant PulseAnimationWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.enabled && !_controller.isAnimating) {
//       _controller.repeat(reverse: true);
//     } else if (!widget.enabled && _controller.isAnimating) {
//       _controller.stop();
//       _controller.value = 0.0;
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
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         final scale = _scaleAnimation.value;

//         Widget result = Transform.scale(scale: scale, child: child);

//         if (widget.glowColor != null) {
//           result = Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: widget.glowColor!.withValues(
//                     alpha:
//                         0.3 *
//                         (scale - widget.minScale) /
//                         (widget.maxScale - widget.minScale),
//                   ),
//                   blurRadius: widget.glowRadius * scale,
//                   spreadRadius: widget.glowRadius * 0.5 * scale,
//                 ),
//               ],
//             ),
//             child: result,
//           );
//         }

//         return result;
//       },
//       child: widget.child,
//     );
//   }
// }
