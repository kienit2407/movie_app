import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/player_overlay_controller.dart';
import 'package:movie_app/core/player_overlay_host.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('drag settles to mini without replacing the player session', () {
    final controller = PlayerOverlayController();
    final args = _args('movie-a');

    controller.open(args);
    final sessionId = controller.sessionId;
    controller.beginDrag();
    controller.updateDragDelta(240, 600);
    controller.endDrag(velocityY: 0);

    expect(controller.target, PlayerOverlayTarget.mini);
    expect(controller.sessionId, sessionId);
    expect(controller.args, same(args));

    controller.expand();
    expect(controller.target, PlayerOverlayTarget.expanded);
    expect(controller.sessionId, sessionId);
    controller.dispose();
  });

  test('opening another playback creates one new session', () {
    final controller = PlayerOverlayController();

    controller.open(_args('movie-a'));
    final firstSession = controller.sessionId;
    controller.open(_args('movie-b'));

    expect(controller.sessionId, firstSession + 1);
    expect(controller.args?.slug, 'movie-b');
    controller.dispose();
  });

  test('minimize stays locked until initial playback becomes ready', () {
    final controller = PlayerOverlayController();

    controller.open(_args('movie-a'), minimizeEnabled: false);
    controller.beginDrag();
    controller.updateDragDelta(240, 600);
    controller.endDrag(velocityY: 900);
    controller.minimize();

    expect(controller.target, PlayerOverlayTarget.expanded);
    expect(controller.progress.value, 0);
    expect(controller.isDragging, isFalse);

    controller.setMinimizeEnabled(true);
    controller.beginDrag();
    controller.updateDragDelta(240, 600);
    controller.endDrag(velocityY: 0);

    expect(controller.target, PlayerOverlayTarget.mini);
    controller.dispose();
  });

  test('root back minimizes expanded player then closes mini player', () async {
    final controller = PlayerOverlayController();
    final dispatcher = PlayerOverlayBackButtonDispatcher(controller);
    controller.open(_args('movie-a'));

    final transientOwner = Object();
    var transientDismissed = false;
    controller.attachTransientOverlayDismissHandler(
      owner: transientOwner,
      dismiss: () {
        transientDismissed = true;
        return true;
      },
    );
    expect(await dispatcher.invokeCallback(Future.value(false)), isTrue);
    expect(transientDismissed, isTrue);
    expect(controller.target, PlayerOverlayTarget.expanded);
    controller.detachTransientOverlayDismissHandler(owner: transientOwner);

    expect(await dispatcher.invokeCallback(Future.value(false)), isTrue);
    expect(controller.target, PlayerOverlayTarget.mini);

    controller.progress.value = 1;
    expect(await dispatcher.invokeCallback(Future.value(false)), isTrue);
    expect(controller.isVisible, isFalse);
    controller.dispose();
  });

  test('root back closes a player that cannot be minimized', () async {
    final controller = PlayerOverlayController();
    final dispatcher = PlayerOverlayBackButtonDispatcher(controller);
    controller.open(_args('broken-movie'), minimizeEnabled: false);

    expect(await dispatcher.invokeCallback(Future.value(false)), isTrue);
    expect(controller.isVisible, isFalse);
    controller.dispose();
  });

  testWidgets(
    'host keeps the same mounted player from expanded to mini and back',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final controller = PlayerOverlayController();
      final lifecycle = _FakePlayerLifecycle();
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home content'))),
          ),
        ],
      );
      addTearDown(() {
        router.dispose();
        controller.dispose();
      });

      await tester.pumpWidget(
        MaterialApp.router(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routeInformationProvider: router.routeInformationProvider,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: PlayerOverlayBackButtonDispatcher(controller),
          builder: (context, child) => Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => PlayerOverlayHost(
                  controller: controller,
                  router: router,
                  playerBuilder: (context, args, overlay) =>
                      _FakePlayer(lifecycle: lifecycle),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      );

      controller.open(_args('movie-a'));
      await tester.pump();
      expect(lifecycle.initCount, 1);
      expect(router.routeInformationProvider.value.uri.path, '/home');

      tester.view.physicalSize = const Size(800, 400);
      await tester.pump();
      expect(
        MediaQuery.sizeOf(tester.element(find.text('Home content'))),
        const Size(400, 800),
      );
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(400, 800);
      await tester.pump();

      controller.minimize();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(controller.progress.value, inExclusiveRange(0, 1));
      expect(lifecycle.initCount, 1);
      expect(lifecycle.disposeCount, 0);

      await tester.pump(const Duration(milliseconds: 240));
      expect(controller.progress.value, 1);
      expect(find.byKey(const ValueKey('fake-player')), findsOneWidget);

      final dragSurface = find.byKey(
        const ValueKey('mini-player-drag-surface'),
      );
      final initialMiniRect = tester.getRect(dragSurface);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.drag(dragSurface, const Offset(-100, -160));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getRect(dragSurface), initialMiniRect);
      expect(controller.isMini, isTrue);

      final playback = VideoPlayerController.networkUrl(
        Uri.parse('https://example.com/movie-a.m3u8'),
      );
      addTearDown(playback.dispose);
      playback.value = const VideoPlayerValue(
        duration: Duration(minutes: 10),
        size: Size(1920, 1080),
        isInitialized: true,
      );
      controller.attachPlaybackController(playback, owner: lifecycle);
      await tester.pump();

      final gesture = await tester.startGesture(initialMiniRect.center);
      await gesture.moveBy(const Offset(-20, -40));
      await tester.pump();
      await gesture.moveBy(const Offset(-90, -180));
      await tester.pump();

      final draggedMiniRect = tester.getRect(dragSurface);
      expect(draggedMiniRect.left, lessThan(initialMiniRect.left));
      expect(draggedMiniRect.left, greaterThan(16));
      expect(draggedMiniRect.top, lessThan(initialMiniRect.top));

      await gesture.up();
      await tester.pumpAndSettle();
      final snappedMiniRect = tester.getRect(dragSurface);
      expect(snappedMiniRect.left, closeTo(16, 0.1));
      expect(snappedMiniRect.top, greaterThanOrEqualTo(16));
      expect(snappedMiniRect.bottom, lessThanOrEqualTo(692));
      expect(lifecycle.initCount, 1);
      expect(lifecycle.disposeCount, 0);

      final doubleTapPosition = snappedMiniRect.center;
      await tester.tapAt(doubleTapPosition);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(doubleTapPosition);
      await tester.pumpAndSettle();

      final wideMiniRect = tester.getRect(dragSurface);
      expect(wideMiniRect.width, closeTo(368, 0.1));
      expect(wideMiniRect.left, closeTo(16, 0.1));
      expect(wideMiniRect.right, closeTo(384, 0.1));
      expect(controller.isMini, isTrue);
      expect(lifecycle.initCount, 1);
      expect(lifecycle.disposeCount, 0);

      controller.expand();
      await tester.pumpAndSettle();
      expect(controller.progress.value, 0);
      expect(lifecycle.initCount, 1);
      expect(lifecycle.disposeCount, 0);

      controller.close();
      await tester.pump();
      expect(lifecycle.disposeCount, 1);
    },
  );
}

MoviePlayerArgs _args(String slug) {
  final movie = MovieModel.fromMap({
    'slug': slug,
    'name': 'Movie $slug',
    'origin_name': 'Original $slug',
    'type': 'single',
    'episode_current': 'Full',
    'episode_total': '1',
    'year': 2026,
    'view': 0,
    'category': <dynamic>[],
    'country': <dynamic>[],
  });
  final episodes = [
    EpisodesModel(
      server_name: 'Server 1',
      server_data: [
        ServerData(
          name: 'Full',
          slug: 'full',
          filename: 'full',
          link_embed: '',
          link_m3u8: 'https://example.com/$slug.m3u8',
        ),
      ],
    ),
  ];

  return MoviePlayerArgs(
    slug,
    null,
    episodes.first.server_data.first.link_m3u8,
    0,
    episodes.first.server_name,
    movie.name,
    episodes,
    movie,
  );
}

class _FakePlayerLifecycle {
  int initCount = 0;
  int disposeCount = 0;
}

class _FakePlayer extends StatefulWidget {
  const _FakePlayer({required this.lifecycle});

  final _FakePlayerLifecycle lifecycle;

  @override
  State<_FakePlayer> createState() => _FakePlayerState();
}

class _FakePlayerState extends State<_FakePlayer> {
  @override
  void initState() {
    super.initState();
    widget.lifecycle.initCount++;
  }

  @override
  void dispose() {
    widget.lifecycle.disposeCount++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(key: ValueKey('fake-player'), color: Colors.black);
  }
}
