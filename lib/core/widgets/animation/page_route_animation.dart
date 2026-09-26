import 'package:flutter/material.dart';

/// A reusable page route transition builder that provides smooth
/// slide + fade animations for both push and pop navigation.
///
/// Use with auto_route's `CustomRoute`:
/// ```dart
/// CustomRoute(
///   page: MyRoute.page,
///   transitionsBuilder: PageRouteAnimation.slideUpFade,
/// )
/// ```
///
/// Or apply globally in your AppRouter:
/// ```dart
/// @override
/// RouteType get defaultRouteType => const RouteType.custom(
///   transitionsBuilder: PageRouteAnimation.slideUpFade,
///   durationInMilliseconds: 350,
///   reverseDurationInMilliseconds: 300,
/// );
/// ```
class PageRouteAnimation {
  PageRouteAnimation._();

  // ─────────────────────────────────────────────
  // Slide Up + Fade  (default push feel)
  // ─────────────────────────────────────────────

  /// Slides new page up from bottom while fading in.
  /// On pop, slides current page down while fading out.
  static Widget slideUpFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.15),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Slide Right + Fade  (iOS-like)
  // ─────────────────────────────────────────────

  /// Slides new page from right while fading in (like iOS).
  /// On pop, slides current page to right while fading out.
  static Widget slideRightFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.25, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Fade Only  (subtle)
  // ─────────────────────────────────────────────

  /// Simple fade transition for both push and pop.
  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
      child: child,
    );
  }

  // ─────────────────────────────────────────────
  // Scale + Fade  (zoom feel)
  // ─────────────────────────────────────────────

  /// Scales new page up from 90% while fading in.
  /// On pop, scales current page down while fading out.
  static Widget scaleFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Shared Axis (Material 3 style)
  // ─────────────────────────────────────────────

  /// Push: Current page fades + slides left, new page fades + slides from right.
  /// Pop: Reverse of push.
  static Widget sharedAxisHorizontal(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Incoming page
    final slideIn = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    final fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    // Outgoing page (the page behind)
    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    final fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOut,
    ));

    return SlideTransition(
      position: slideOut,
      child: FadeTransition(
        opacity: fadeOut,
        child: SlideTransition(
          position: slideIn,
          child: FadeTransition(
            opacity: fadeIn,
            child: child,
          ),
        ),
      ),
    );
  }
}
