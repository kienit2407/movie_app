// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';

// /// A reusable widget that provides smooth animated transitions between
// /// different child states using combined fade + scale effects.
// ///
// /// **Replays entrance animation** when the page becomes visible again after a pop.
// ///
// /// **Important**: The [child] must have a unique [Key] for each state
// /// so [AnimatedSwitcher] knows when to trigger the transition.
// ///
// /// Example:
// /// ```dart
// /// StateSwitcherAnimationWidget(
// ///   child: isLoading
// ///     ? CircularProgressIndicator(key: ValueKey('loading'))
// ///     : Text('Content', key: ValueKey('content')),
// /// )
// /// ```
// class StateSwitcherAnimationWidget extends StatefulWidget {
//   const StateSwitcherAnimationWidget({
//     super.key,
//     required this.child,
//     this.duration = const Duration(milliseconds: 400),
//     this.delay = Duration.zero,
//     this.switchInCurve = Curves.easeOutBack,
//     this.switchOutCurve = Curves.easeIn,
//     this.transitionType = SwitcherTransitionType.fadeScale,
//   });

//   /// The widget to display. Provide a unique [Key] for each state.
//   final Widget child;

//   /// Duration of the switch animation.
//   final Duration duration;

//   /// Optional delay before the entrance animation starts.
//   final Duration delay;

//   /// Curve for the incoming widget.
//   final Curve switchInCurve;

//   /// Curve for the outgoing widget.
//   final Curve switchOutCurve;

//   /// Type of transition to use.
//   final SwitcherTransitionType transitionType;

//   @override
//   State<StateSwitcherAnimationWidget> createState() =>
//       _StateSwitcherAnimationWidgetState();
// }

// class _StateSwitcherAnimationWidgetState
//     extends State<StateSwitcherAnimationWidget>
//     with SingleTickerProviderStateMixin, AutoRouteAwareStateMixin {
//   late final AnimationController _entranceController;
//   late final Animation<double> _entranceAnimation;
//   bool _wasHidden = false;

//   @override
//   void initState() {
//     super.initState();

//     _entranceController = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );

//     _entranceAnimation = CurvedAnimation(
//       parent: _entranceController,
//       curve: widget.switchInCurve,
//     );

//     _playAnimation();
//   }

//   @override
//   void didPopNext() {
//     super.didPopNext();
//     _entranceController.reset();
//     _playAnimation();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final isVisible = TickerMode.of(context);
//     if (!isVisible) {
//       _wasHidden = true;
//     } else if (_wasHidden) {
//       _wasHidden = false;
//       _entranceController.reset();
//       _playAnimation();
//     }
//   }

//   void _playAnimation() {
//     if (widget.delay == Duration.zero) {
//       _entranceController.forward();
//     } else {
//       Future.delayed(widget.delay, () {
//         if (mounted) {
//           _entranceController.forward();
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _entranceController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _entranceAnimation,
//       builder: (context, child) {
//         return _buildEntranceTransition(child!, _entranceAnimation);
//       },
//       child: AnimatedSwitcher(
//         duration: widget.duration,
//         switchInCurve: widget.switchInCurve,
//         switchOutCurve: widget.switchOutCurve,
//         transitionBuilder: _buildSwitchTransition,
//         child: widget.child,
//       ),
//     );
//   }

//   Widget _buildEntranceTransition(Widget child, Animation<double> animation) {
//     switch (widget.transitionType) {
//       case SwitcherTransitionType.fade:
//         return FadeTransition(opacity: animation, child: child);

//       case SwitcherTransitionType.scale:
//         return ScaleTransition(scale: animation, child: child);

//       case SwitcherTransitionType.fadeScale:
//         return FadeTransition(
//           opacity: animation,
//           child: ScaleTransition(scale: animation, child: child),
//         );

//       case SwitcherTransitionType.fadeSlideUp:
//         return FadeTransition(
//           opacity: animation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.3),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           ),
//         );

//       case SwitcherTransitionType.fadeSlideDown:
//         return FadeTransition(
//           opacity: animation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, -0.3),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           ),
//         );
//     }
//   }

//   Widget _buildSwitchTransition(Widget child, Animation<double> animation) {
//     switch (widget.transitionType) {
//       case SwitcherTransitionType.fade:
//         return FadeTransition(opacity: animation, child: child);

//       case SwitcherTransitionType.scale:
//         return ScaleTransition(scale: animation, child: child);

//       case SwitcherTransitionType.fadeScale:
//         return FadeTransition(
//           opacity: animation,
//           child: ScaleTransition(scale: animation, child: child),
//         );

//       case SwitcherTransitionType.fadeSlideUp:
//         return FadeTransition(
//           opacity: animation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, 0.3),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           ),
//         );

//       case SwitcherTransitionType.fadeSlideDown:
//         return FadeTransition(
//           opacity: animation,
//           child: SlideTransition(
//             position: Tween<Offset>(
//               begin: const Offset(0, -0.3),
//               end: Offset.zero,
//             ).animate(animation),
//             child: child,
//           ),
//         );
//     }
//   }
// }

// /// Supported transition types for [StateSwitcherAnimationWidget].
// enum SwitcherTransitionType {
//   /// Fade only.
//   fade,

//   /// Scale only.
//   scale,

//   /// Combined fade + scale (default).
//   fadeScale,

//   /// Combined fade + slide up.
//   fadeSlideUp,

//   /// Combined fade + slide down.
//   fadeSlideDown,
// }
