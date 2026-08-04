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
import 'package:movie_app/feature/comments/domain/entities/comment.dart';
import 'package:movie_app/feature/comments/domain/repositories/comment_repository.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/hive_registrar.g.dart';

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

      expect(initialHeight, 142);
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
}

Future<void> _setPortraitSurface(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1000);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

Future<void> _pumpPlayer(
  WidgetTester tester, {
  required String episodeCurrent,
  int episodeCount = 80,
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

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => BlocProvider(
        create: (_) => PlayerCubit(),
        child: MaterialApp(
          home: MoviePlayerPage(
            slug: movie.slug,
            movieName: movie.name,
            episodes: episodes,
            movie: movie,
            initialEpisodeIndex: 0,
            initialServer: episodes.first.server_name,
            initialServerIndex: 0,
          ),
        ),
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
