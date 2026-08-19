import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/device_orientation_service.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/comments/domain/entities/comment.dart';
import 'package:movie_app/feature/comments/domain/repositories/comment_repository.dart';
import 'package:movie_app/feature/comments/presentation/widgets/comments_tab.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/hive_registrar.g.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory testStorageDirectory;

  setUpAll(() async {
    testStorageDirectory = await Directory.systemTemp.createTemp(
      'movie_player_series_scroll_test.',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          return testStorageDirectory.path;
        });
    await FastCachedImageConfig.init(subDir: 'fast-image-cache');
    Hive.registerAdapters();
  });

  setUp(() async {
    await sl.reset();
    sl.registerSingleton<CommentRepository>(const _EmptyCommentRepository());
    HydratedBloc.storage = _MemoryStorage();
  });

  tearDown(() async {
    await sl.reset();
  });

  tearDownAll(() async {
    await Hive.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (testStorageDirectory.existsSync()) {
      await testStorageDirectory.delete(recursive: true);
    }
  });

  testWidgets(
    'series controls collapse upward and float back on any downward scroll',
    (tester) async {
      await _setPortraitSurface(tester);
      await _pumpPlayer(tester, episodeCurrent: 'Tập 80');

      const floatingControlsKey = ValueKey('series-floating-controls');
      const scrollKey = ValueKey('series-episode-scroll');
      const searchKey = ValueKey('series-episode-search');
      const serverKey = ValueKey('series-server-bar');
      const borderKey = ValueKey('series-list-top-border');

      final controlsFinder = find.byKey(floatingControlsKey);
      final scrollFinder = find.byKey(scrollKey);
      final initialHeight = tester.getSize(controlsFinder).height;

      // The exact sum is an implementation detail; keep this assertion focused
      // on the controls starting fully expanded before the collapse gesture.
      expect(initialHeight, greaterThan(120));
      expect(find.byKey(searchKey).hitTestable(), findsOneWidget);
      expect(find.byKey(serverKey).hitTestable(), findsOneWidget);
      expect(find.byKey(borderKey), findsOneWidget);

      await tester.timedDrag(
        scrollFinder,
        const Offset(0, -110),
        const Duration(seconds: 1),
      );
      await tester.pump();

      final partiallyCollapsedHeight = tester.getSize(controlsFinder).height;
      expect(partiallyCollapsedHeight, greaterThan(0));
      expect(partiallyCollapsedHeight, lessThan(65));
      expect(find.byKey(searchKey).hitTestable(), findsNothing);
      expect(find.byKey(serverKey).hitTestable(), findsOneWidget);

      await tester.timedDrag(
        scrollFinder,
        const Offset(0, -500),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(controlsFinder).height, 1);
      expect(find.byKey(searchKey).hitTestable(), findsNothing);
      expect(find.byKey(serverKey).hitTestable(), findsNothing);
      expect(find.byKey(borderKey), findsOneWidget);

      await tester.timedDrag(
        scrollFinder,
        const Offset(0, 60),
        const Duration(seconds: 1),
      );
      await tester.pump();
      final floatingBackHeight = tester.getSize(controlsFinder).height;
      expect(floatingBackHeight, greaterThan(0));
      expect(floatingBackHeight, lessThan(initialHeight));

      await tester.timedDrag(
        scrollFinder,
        const Offset(0, 220),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(controlsFinder).height, initialHeight);

      await tester.tap(find.text('Lồng Tiếng'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '10');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      final searchField = tester.widget<TextField>(find.byType(TextField));
      expect(searchField.controller?.text, isEmpty);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('single movie keeps the existing server grid', (tester) async {
    await _setPortraitSurface(tester);
    await _pumpPlayer(tester, episodeCurrent: 'Full', episodeCount: 1);

    expect(
      find.byKey(const ValueKey('series-floating-controls')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('series-episode-scroll')), findsNothing);
    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('Phụ Đề'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('episode search stays above the software keyboard', (
    tester,
  ) async {
    await _setPortraitSurface(tester, topPadding: 47);
    await _pumpPlayer(tester, episodeCurrent: 'Tập 80');

    final search = find.byKey(const ValueKey('series-episode-search'));
    final initialTop = tester.getTopLeft(search).dy;
    await tester.tap(find.byType(TextField));
    await tester.pump();

    tester.view.viewInsets = const FakeViewPadding(bottom: 360);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    const keyboardTop = 1000.0 - 360.0;
    expect(
      tester.getBottomLeft(search).dy,
      lessThanOrEqualTo(keyboardTop - 14),
    );
    expect(tester.getTopLeft(search).dy, lessThan(initialTop));
    expect(tester.takeException(), isNull);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.getTopLeft(search).dy, closeTo(initialTop, 0.1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('portrait video expands without a panel layout overflow', (
    tester,
  ) async {
    await _setPortraitSurface(tester, topPadding: 47);
    await _pumpPlayer(tester, episodeCurrent: 'Full', episodeCount: 1);

    final commentsPreview = find.byKey(
      const ValueKey('movie-comments-preview'),
    );
    expect(tester.takeException(), isNull);

    await tester.timedDrag(
      commentsPreview,
      const Offset(0, 900),
      const Duration(milliseconds: 500),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.getTopLeft(commentsPreview).dy, greaterThan(900));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('fullscreen uses a rotated landscape layout without overflow', (
    tester,
  ) async {
    await _setPortraitSurface(tester, topPadding: 47);
    await _pumpPlayer(tester, episodeCurrent: 'Full', episodeCount: 1);

    final dynamic playerState = tester.state(find.byType(MoviePlayerPage));
    final Future<void> enterFullscreen =
        playerState.toggleFullscreenForTest() as Future<void>;
    await tester.pump();
    tester.view.physicalSize = const Size(1000, 430);
    await tester.pump();
    await enterFullscreen;
    await tester.pump();

    expect(
      find.byKey(const ValueKey('rotated-landscape-player')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('landscape-control-bar'))).width,
      closeTo(1000, 0.1),
    );
    final fullscreenLayoutException = tester.takeException();
    expect(fullscreenLayoutException, isNull);

    final Future<void> exitFullscreen =
        playerState.toggleFullscreenForTest() as Future<void>;
    tester.view.physicalSize = const Size(430, 1000);
    await tester.pump();
    await exitFullscreen;
    await tester.pump();

    expect(
      find.byKey(const ValueKey('rotated-landscape-player')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('native rotation restores the portrait video height', (
    tester,
  ) async {
    await _setPortraitSurface(tester, topPadding: 47);
    await _pumpPlayer(tester, episodeCurrent: 'Full', episodeCount: 1);

    final dynamic playerState = tester.state(find.byType(MoviePlayerPage));
    final initialHeight = playerState.portraitVideoHeightForTest as double;

    final Future<void> enterFullscreen =
        playerState.toggleFullscreenForTest() as Future<void>;
    await tester.pump();
    tester.view.physicalSize = const Size(1000, 430);
    await tester.pump();
    await tester.pump();
    await enterFullscreen;

    expect(
      find.byKey(const ValueKey('rotated-landscape-player')),
      findsOneWidget,
    );

    final Future<void> exitFullscreen =
        playerState.toggleFullscreenForTest() as Future<void>;
    await tester.pump();
    tester.view.physicalSize = const Size(430, 1000);
    await tester.pump();
    await tester.pump();
    await exitFullscreen;
    await tester.pump();

    expect(
      playerState.portraitVideoHeightForTest as double,
      closeTo(initialHeight, 0.1),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('virtual fullscreen drawer uses half of its landscape viewport', (
    tester,
  ) async {
    await _setPortraitSurface(tester);
    await _pumpPlayer(tester, episodeCurrent: 'Full', episodeCount: 1);

    final dynamic playerState = tester.state(find.byType(MoviePlayerPage));
    final Future<void> enterFullscreen =
        playerState.toggleFullscreenForTest() as Future<void>;
    await tester.pump();
    tester.view.physicalSize = const Size(1000, 430);
    await tester.pump();
    await enterFullscreen;
    await tester.pump();

    final landscapeScaffold = find.byType(Scaffold).last;
    tester.state<ScaffoldState>(landscapeScaffold).openEndDrawer();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.getSize(find.byType(Drawer)).width, closeTo(500, 1));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('device sensor uses the same virtual fullscreen transition', (
    tester,
  ) async {
    await _setPortraitSurface(tester, topPadding: 47);
    await _pumpPlayer(tester, episodeCurrent: 'Full', episodeCount: 1);

    final dynamic playerState = tester.state(find.byType(MoviePlayerPage));
    expect(
      find.byKey(const ValueKey('rotated-landscape-player')),
      findsNothing,
    );

    playerState.handleDeviceOrientationForTest(
      DevicePhysicalOrientation.landscapeLeft,
    );
    await tester.pump();
    tester.view.physicalSize = const Size(1000, 430);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('rotated-landscape-player')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    playerState.handleDeviceOrientationForTest(
      DevicePhysicalOrientation.portraitUp,
    );
    tester.view.physicalSize = const Size(430, 1000);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('rotated-landscape-player')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('comments open from an app-level player overlay', (tester) async {
    await _setPortraitSurface(tester);
    await _pumpPlayer(
      tester,
      episodeCurrent: 'Full',
      episodeCount: 1,
      appLevelOverlay: true,
    );

    await tester.tap(find.byKey(const ValueKey('movie-comments-preview')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 260));

    expect(find.byType(CommentsTab), findsOneWidget);
    expect(find.byType(CommentsTab).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hủy'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.ancestor(of: find.text('Mới nhất'), matching: find.byType(ListTile)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hủy'), findsNothing);
    expect(find.byType(CommentsTab), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tapAt(const Offset(20, 20));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.byType(CommentsTab), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  });
}

Future<void> _setPortraitSurface(
  WidgetTester tester, {
  double topPadding = 0,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1000);
  tester.view.padding = FakeViewPadding(top: topPadding);
  tester.view.viewPadding = FakeViewPadding(top: topPadding);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
    tester.view.resetViewInsets();
  });
}

Future<void> _pumpPlayer(
  WidgetTester tester, {
  required String episodeCurrent,
  int episodeCount = 80,
  bool appLevelOverlay = false,
}) async {
  final movie = MovieModel.fromMap({
    'slug': 'series-scroll-test',
    'name': 'Phim thử nghiệm',
    'origin_name': 'Series scroll test',
    'type': episodeCurrent == 'Full' ? 'single' : 'series',
    'episode_current': episodeCurrent,
    'episode_total': '$episodeCount',
    'year': 2026,
    'view': 0,
    'category': <dynamic>[],
    'country': <dynamic>[],
  });
  final episodes = [
    _server('Vietsub', episodeCount),
    _server('Lồng Tiếng', episodeCount),
  ];
  final player = MoviePlayerPage(
    slug: movie.slug,
    movieName: movie.name,
    episodes: episodes,
    movie: movie,
    initialEpisodeIndex: 0,
    initialServer: episodes.first.server_name,
    initialServerIndex: 0,
  );

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PlayerCubit()),
          BlocProvider(
            create: (_) => AuthSessionCubit(
              client: SupabaseClient(
                'https://comments-test.supabase.co',
                'comments-test-anon-key',
                authOptions: const AuthClientOptions(autoRefreshToken: false),
              ),
            ),
          ),
        ],
        child: appLevelOverlay
            ? MaterialApp(
                home: const SizedBox.shrink(),
                builder: (context, child) => Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) => Stack(
                        fit: StackFit.expand,
                        children: [child ?? const SizedBox.shrink(), player],
                      ),
                    ),
                  ],
                ),
              )
            : MaterialApp(home: player),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
}

EpisodesModel _server(String name, int episodeCount) {
  return EpisodesModel(
    server_name: name,
    server_data: List.generate(
      episodeCount,
      (index) => ServerData(
        name: 'Tập ${index + 1}',
        slug: 'tap-${index + 1}',
        filename: 'tap-${index + 1}',
        link_embed: '',
        link_m3u8: '',
      ),
    ),
  );
}

class _EmptyCommentRepository implements CommentRepository {
  const _EmptyCommentRepository();

  @override
  String? get currentUserId => null;

  @override
  Future<CommentPage> fetchComments({
    required String movieSlug,
    required CommentSort sort,
    required int offset,
    int limit = 20,
  }) async {
    return const CommentPage(items: [], hasMore: false, totalCount: 0);
  }

  @override
  Future<CommentPage> fetchReplies({
    required String rootCommentId,
    required int offset,
    int limit = 30,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Comment> createComment({
    required String movieSlug,
    required String body,
    String? rootCommentId,
    String? replyToUserId,
    String? replyToCommentId,
    String? replyToName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> editComment({required String commentId, required String body}) {
    throw UnimplementedError();
  }

  @override
  Future<void> reportComment({
    required String commentId,
    required CommentReportReason reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> setReaction({
    required String commentId,
    required CommentReaction? reaction,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> softDeleteComment(String commentId) {
    throw UnimplementedError();
  }
}

class _MemoryStorage implements Storage {
  final Map<String, dynamic> _values = {};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> clear() async {
    _values.clear();
  }

  @override
  Future<void> close() async {}
}
