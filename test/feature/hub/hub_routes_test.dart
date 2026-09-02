import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/feature/hub/presentation/pages/hub_page.dart';

void main() {
  test(
    'Hub router has four state-preserving branches in the expected order',
    () {
      final shell = goRouter.configuration.routes
          .whereType<StatefulShellRoute>()
          .single;
      final paths = shell.branches
          .map((branch) => (branch.routes.single as GoRoute).path)
          .toList(growable: false);

      expect(paths, [
        AppRoutes.home,
        AppRoutes.search,
        AppRoutes.favorites,
        AppRoutes.profile,
      ]);
      expect(shell.navigatorContainerBuilder, isNotNull);
    },
  );

  test('full-screen Hub destinations live outside the shell', () {
    final rootPaths = goRouter.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toSet();

    expect(rootPaths, contains(AppRoutes.movieDetail));
    expect(rootPaths, contains(AppRoutes.player));
    expect(rootPaths, contains(AppRoutes.notifications));
    expect(rootPaths, contains(AppRoutes.editProfile));
    expect(rootPaths, contains(AppRoutes.editDisplayName));
  });

  test(
    'reselect events are emitted even when the same tab is tapped again',
    () {
      var calls = 0;
      void listener() => calls++;
      HubTabReselectNotifier.instance.addListener(listener);

      HubTabReselectNotifier.instance
        ..notifyTab(2)
        ..notifyTab(2);

      expect(HubTabReselectNotifier.instance.index, 2);
      expect(calls, 2);
      HubTabReselectNotifier.instance.removeListener(listener);
    },
  );
}
