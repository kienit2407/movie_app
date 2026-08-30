import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/feature/home/presentation/pages/home_page.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/feature/search/presentation/pages/search_page.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/player_overlay_route_bridge.dart';
import 'package:movie_app/core/observability/app_observability.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/pages/sign_in.dart';
import 'package:movie_app/feature/hub/presentation/pages/hub_page.dart';
import 'package:movie_app/feature/home/presentation/pages/notifications_page.dart';
import 'package:movie_app/feature/library/presentation/pages/edit_profile_page.dart';
import 'package:movie_app/feature/library/presentation/pages/favorites_page.dart';
import 'package:movie_app/feature/library/presentation/pages/profile_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String movieDetail = '/movie/:slug';
  static const String player = '/player';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String editProfile = '/profile/edit';
  static const String signIn = '/sign-in';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> homeNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> searchNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> favoritesNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> profileNavigatorKey =
      GlobalKey<NavigatorState>();
}

final goRouter = GoRouter(
  navigatorKey: AppRoutes.navigatorKey, // <<< thêm dòng này
  initialLocation: AppRoutes.home,
  observers: [AppObservability.navigatorObserver()],
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HubPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: AppRoutes.homeNavigatorKey,
          observers: [AppObservability.navigatorObserver()],
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: AppRoutes.searchNavigatorKey,
          observers: [AppObservability.navigatorObserver()],
          routes: [
            GoRoute(
              path: AppRoutes.search,
              name: 'search',
              builder: (context, state) =>
                  const SearchPage(showBackButton: false),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: AppRoutes.favoritesNavigatorKey,
          observers: [AppObservability.navigatorObserver()],
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              name: 'favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: AppRoutes.profileNavigatorKey,
          observers: [AppObservability.navigatorObserver()],
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.signIn,
      name: 'signIn',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      parentNavigatorKey: AppRoutes.navigatorKey,
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      parentNavigatorKey: AppRoutes.navigatorKey,
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.movieDetail,
      name: 'movieDetail',
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return MovieDetailPage(slug: slug);
      },
    ),
    GoRoute(
      path: AppRoutes.player,
      name: 'player',
      pageBuilder: (context, state) {
        final args = state.extra is MoviePlayerArgs
            ? state.extra as MoviePlayerArgs
            : null;
        return CustomTransitionPage<void>(
          child: PlayerOverlayRouteBridge(args: args),
          // Không vẽ transition (đảm bảo không có slide)
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },

          // push: bạn muốn có anim hay không thì tuỳ
          transitionDuration: Duration.zero,

          //  pop: tắt anim => hết “swipe iOS”
          reverseTransitionDuration: Duration.zero,
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Lỗi: ${state.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    ),
  ),
);
