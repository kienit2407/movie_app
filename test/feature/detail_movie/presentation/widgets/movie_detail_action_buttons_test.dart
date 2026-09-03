import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/player_overlay_controller.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/widgets/movie_detail_action_buttons.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../helpers/localized_test_app.dart';

void main() {
  final overlay = PlayerOverlayController.instance;

  setUp(overlay.close);
  tearDown(overlay.close);

  testWidgets('series play asks to continue or restart from episode one', (
    tester,
  ) async {
    final repository = _HistoryRepository();
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient(
        'https://example.supabase.co',
        'anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
      authChanges: const Stream<AuthState>.empty(),
    );
    addTearDown(cubit.close);
    await cubit.refresh();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: localizedTestApp(home: const Scaffold(body: _ActionHarness())),
      ),
    );

    await tester.tap(find.text('Xem phim'));
    await tester.pumpAndSettle();
    expect(find.text('Xem tập mới'), findsOneWidget);
    await tester.tap(find.text('Xem phim').last);
    await tester.pumpAndSettle();
    expect(find.text('Tiếp tục xem?'), findsOneWidget);
    expect(find.text('Xem tiếp'), findsOneWidget);
    expect(find.text('Xem lại từ đầu'), findsOneWidget);

    await tester.tap(find.text('Xem tiếp'));
    await tester.pumpAndSettle();
    expect(overlay.args?.initialEpisodeIndex, 1);
    expect(overlay.args?.initialEpisodeLink, 'episode-2.m3u8');
    expect(overlay.args?.resumeFromHistory, isTrue);

    overlay.close();
    await tester.tap(find.text('Xem phim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem phim').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem lại từ đầu'));
    await tester.pumpAndSettle();
    expect(overlay.args?.initialEpisodeIndex, 0);
    expect(overlay.args?.initialEpisodeLink, 'episode-1.m3u8');
    expect(overlay.args?.resumeFromHistory, isFalse);
  });

  testWidgets('latest episode opens directly without the resume prompt', (
    tester,
  ) async {
    final repository = _HistoryRepository();
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient(
        'https://example.supabase.co',
        'anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
      authChanges: const Stream<AuthState>.empty(),
    );
    addTearDown(cubit.close);
    await cubit.refresh();

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: localizedTestApp(home: const Scaffold(body: _ActionHarness())),
      ),
    );

    await tester.tap(find.text('Xem phim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem tập mới'));
    await tester.pumpAndSettle();

    expect(find.text('Tiếp tục xem?'), findsNothing);
    expect(overlay.args?.initialEpisodeIndex, 1);
    expect(overlay.args?.initialEpisodeLink, 'episode-2.m3u8');
    expect(overlay.args?.bypassSeriesResumePrompt, isTrue);
  });
}

class _ActionHarness extends StatefulWidget {
  const _ActionHarness();

  @override
  State<_ActionHarness> createState() => _ActionHarnessState();
}

class _ActionHarnessState extends State<_ActionHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final ScrollController _scroll = ScrollController();
  final GlobalKey _marker = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MovieDetailActionButtons(
      movie: _movie,
      episodes: _episodes,
      selectedEpisodeLink: 'episode-1.m3u8',
      currentEpisodeIndex: 0,
      tabController: _tabs,
      scrollController: _scroll,
      tabBarMarkerKey: _marker,
      onScrollToTabBar: () {},
    );
  }
}

final _movie = MovieModel.fromMap({
  'slug': 'series-1',
  'name': 'Phim bộ',
  'origin_name': 'Series',
  'type': 'series',
  'episode_current': 'Tập 2',
  'episode_total': '2',
  'year': 2026,
  'view': 0,
  'category': <dynamic>[],
  'country': <dynamic>[],
});

final _episodes = [
  EpisodesModel(
    server_name: 'Vietsub',
    server_data: [
      ServerData(
        name: 'Tập 1',
        slug: 'tap-1',
        filename: 'tap-1',
        link_embed: '',
        link_m3u8: 'episode-1.m3u8',
      ),
      ServerData(
        name: 'Tập 2',
        slug: 'tap-2',
        filename: 'tap-2',
        link_embed: '',
        link_m3u8: 'episode-2.m3u8',
      ),
    ],
  ),
];

class _HistoryRepository implements UserLibraryRepository {
  final User _user = User(
    id: 'user-1',
    appMetadata: const {},
    userMetadata: const {'full_name': 'Liquid User'},
    aud: 'authenticated',
    email: 'user@example.com',
    createdAt: '2026-08-30T00:00:00Z',
  );

  @override
  User get currentUser => _user;

  @override
  Future<UserProfile> getProfile() async => UserProfile.fromUser(_user);

  @override
  Future<List<UserWatchHistory>> getWatchHistory() async => [
    UserWatchHistory(
      slug: 'series-1',
      name: 'Phim bộ',
      originName: 'Series',
      posterUrl: '',
      thumbUrl: '',
      episodeCurrent: 'Tập 2',
      quality: 'HD',
      lang: 'Vietsub',
      year: 2026,
      rating: 8,
      positionMs: 120000,
      durationMs: 1200000,
      lastServerIndex: 0,
      lastEpisodeIndex: 1,
      lastEpisodeName: 'Tập 2',
      lastEpisodeLink: 'episode-2.m3u8',
      lastServerName: 'Vietsub',
      watchedAt: DateTime(2026, 8, 30),
    ),
  ];

  @override
  Future<List<UserFavorite>> getFavorites() async => const [];

  @override
  Future<void> addFavorite(UserFavorite favorite) async {}

  @override
  Future<void> removeFavorite(String slug) async {}

  @override
  Future<void> removeFavorites(Iterable<String> slugs) async {}

  @override
  Future<void> removeWatchHistory(String slug) async {}

  @override
  Future<void> removeWatchHistoryItems(Iterable<String> slugs) async {}

  @override
  Future<void> upsertWatchHistory(UserWatchHistory history) async {}

  @override
  Future<String> uploadAvatar(
    Uint8List bytes, {
    required String extension,
  }) async => '';

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async => UserProfile(displayName: displayName, avatarUrl: avatarUrl ?? '');
}
