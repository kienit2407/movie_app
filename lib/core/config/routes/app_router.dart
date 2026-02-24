import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/feature/home/presentation/pages/home_page.dart';
import 'package:movie_app/feature/intro/presentation/splash/pages/splash.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/feature/search/presentation/pages/search_page.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String movieDetail = '/movie/:slug';
  static const String player = '/player';
  static const String search = '/search';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

final goRouter = GoRouter(
  navigatorKey: AppRoutes.navigatorKey, // <<< thêm dòng này
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
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
        final args = state.extra as MoviePlayerArgs;
        return CustomTransitionPage<void>(
          child: MoviePlayerPage(
            slug: args.slug,
            movieName: args.movieName,
            thumbnailUrl: args.thumbnailUrl,
            episodes: args.episodes,
            movie: args.movie,
            initialEpisodeLink: args.initialEpisodeLink,
            initialEpisodeIndex: args.initialEpisodeIndex,
            initialServer: args.initialServer,
            initialServerIndex: args.initialServerIndex,
          ),
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
    GoRoute(
      path: AppRoutes.search,
      name: 'search',
      builder: (context, state) => const SearchPage(),
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
