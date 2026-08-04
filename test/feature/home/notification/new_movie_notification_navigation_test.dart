import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_navigation.dart';

void main() {
  group('NewMovieNotificationNavigation.routeFromPayload', () {
    test('routes a single movie to its detail page', () {
      final payload = jsonEncode({'type': 'new_movie', 'slug': 'phim-moi'});

      expect(
        NewMovieNotificationNavigation.routeFromPayload(payload),
        '/movie/phim-moi',
      );
    });

    test('routes a summary notification to the inbox', () {
      final payload = jsonEncode({'type': 'new_movies'});

      expect(
        NewMovieNotificationNavigation.routeFromPayload(payload),
        AppRoutes.notifications,
      );
    });

    test('routes malformed payloads to Home', () {
      expect(
        NewMovieNotificationNavigation.routeFromPayload('not-json'),
        AppRoutes.home,
      );
    });
  });
}
