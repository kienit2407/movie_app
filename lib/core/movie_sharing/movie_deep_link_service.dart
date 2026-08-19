import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_navigation.dart';

class MovieDeepLinkService {
  MovieDeepLinkService._();

  static final MovieDeepLinkService instance = MovieDeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  void initialize() {
    _subscription ??= _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    final route = routeFromUri(uri);
    if (route == null) return;
    NewMovieNotificationNavigation.openRoute(route);
  }

  @visibleForTesting
  static String? routeFromUri(Uri uri) {
    final isCustomScheme = uri.scheme == 'liquidphim' && uri.host == 'movie';
    final isWebLink =
        uri.scheme == 'https' &&
        uri.host == 'movieapp-c3847.web.app' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'movie';
    if (!isCustomScheme && !isWebLink) return null;

    final slugIndex = isWebLink ? 1 : 0;
    if (uri.pathSegments.length <= slugIndex) return null;
    final slug = uri.pathSegments[slugIndex].trim();
    if (slug.isEmpty) return null;
    return AppRoutes.movieDetail.replaceAll(':slug', Uri.encodeComponent(slug));
  }
}
