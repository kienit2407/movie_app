import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:movie_app/core/config/routes/app_router.dart';

class NewMovieNotificationNavigation {
  const NewMovieNotificationNavigation._();

  static String? _pendingRoute;
  static bool _splashFinished = false;

  static String routeFromPayload(String payload) {
    try {
      final data = jsonDecode(payload);
      if (data is Map && data['type'] == 'new_movie') {
        final slug = data['slug']?.toString().trim();
        if (slug != null && slug.isNotEmpty) {
          return '/movie/${Uri.encodeComponent(slug)}';
        }
      }
      if (data is Map && data['type'] == 'new_movies') {
        return AppRoutes.notifications;
      }
      if (data is Map &&
          (data['type'] == 'comment_reply' ||
              data['type'] == 'comment_reaction')) {
        final slug = data['movie_slug']?.toString().trim();
        if (slug != null && slug.isNotEmpty) {
          return '/movie/${Uri.encodeComponent(slug)}';
        }
        return AppRoutes.notifications;
      }
    } catch (_) {
      // Invalid payloads safely fall back to Home.
    }
    return AppRoutes.home;
  }

  static void handlePayload(String payload) {
    openRoute(routeFromPayload(payload));
  }

  static void openRoute(String route) {
    _pendingRoute = route;
    _flushIfReady();
  }

  static String takeRouteAfterSplash() {
    _splashFinished = true;
    final route = _pendingRoute ?? AppRoutes.home;
    _pendingRoute = null;
    return route;
  }

  static void _flushIfReady() {
    if (!_splashFinished || _pendingRoute == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = _pendingRoute;
      if (route == null) return;
      if (AppRoutes.navigatorKey.currentContext == null) {
        _flushIfReady();
        return;
      }

      _pendingRoute = null;
      _openAboveHome(route);
    });
  }

  static void _openAboveHome(String route) {
    if (route == AppRoutes.home) {
      goRouter.go(AppRoutes.home);
      return;
    }
    goRouter.push(route);
  }
}
