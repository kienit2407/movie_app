import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('keeps only 100 most recent history items in visible state', () async {
    final repository = _FakeLibraryRepository(user: _user);
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient('https://example.supabase.co', 'anon-key'),
    );
    await cubit.refresh();

    for (var index = 0; index < 105; index++) {
      cubit.queueWatchHistory(_history(index));
    }

    expect(cubit.state.history, hasLength(100));
    expect(cubit.state.history.first.slug, 'movie-104');
    expect(cubit.state.history.last.slug, 'movie-5');
    await cubit.flushWatchHistory();
    expect(repository.writtenHistory, hasLength(105));
    await cubit.close();
  });

  test('does not save history while signed out', () async {
    final repository = _FakeLibraryRepository();
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient('https://example.supabase.co', 'anon-key'),
    );

    cubit.queueWatchHistory(_history(1), flush: true);

    expect(cubit.state.history, isEmpty);
    expect(repository.writtenHistory, isEmpty);
    await cubit.close();
  });

  test('rolls back an optimistic favorite when Supabase write fails', () async {
    final repository = _FakeLibraryRepository(user: _user, failFavorite: true);
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient('https://example.supabase.co', 'anon-key'),
    );
    await cubit.refresh();

    final result = await cubit.toggleFavorite(_movie);

    expect(result, isFalse);
    expect(cubit.state.favorites, isEmpty);
    expect(cubit.state.errorMessage, isNotNull);
    await cubit.close();
  });

  test('removes several history items in one cubit action', () async {
    final repository = _FakeLibraryRepository(user: _user)
      ..history.addAll([_history(1), _history(2), _history(3)]);
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient('https://example.supabase.co', 'anon-key'),
    );
    await cubit.refresh();

    await cubit.removeHistoryItems({'movie-1', 'movie-3'});

    expect(cubit.state.history.map((item) => item.slug), ['movie-2']);
    expect(repository.history.map((item) => item.slug), ['movie-2']);
    await cubit.close();
  });

  test('publishes the durable profile returned after an update', () async {
    final repository = _FakeLibraryRepository(
      user: _user,
      profileUpdateResult: _updatedProfile,
    );
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient('https://example.supabase.co', 'anon-key'),
    );

    await cubit.updateProfile(
      displayName: 'Liquid User mới',
      avatarUrl: 'https://example.com/new-avatar.jpg',
    );

    expect(cubit.state.profile, same(_updatedProfile));
    expect(cubit.state.displayName, 'Liquid User mới');
    expect(cubit.state.avatarUrl, 'https://example.com/new-avatar.jpg');
    await cubit.close();
  });

  test('loads the stored profile instead of provider metadata', () async {
    final repository = _FakeLibraryRepository(
      user: _user,
      profile: _updatedProfile,
    );
    final cubit = UserLibraryCubit(
      repository: repository,
      client: SupabaseClient('https://example.supabase.co', 'anon-key'),
      authChanges: const Stream<AuthState>.empty(),
    );

    await cubit.refresh();

    expect(cubit.state.displayName, 'Liquid User mới');
    expect(cubit.state.avatarUrl, 'https://example.com/new-avatar.jpg');
    await cubit.close();
  });

  test('uses newer auth metadata while public profile sync is delayed', () {
    final updatedUser = User(
      id: 'user-1',
      appMetadata: const {},
      userMetadata: const {
        'full_name': 'Tên vừa cập nhật',
        'avatar_url': 'https://example.com/new.jpg',
        'profile_updated_at': '2026-08-30T12:00:00.000Z',
      },
      aud: 'authenticated',
      email: 'user@example.com',
      createdAt: '2026-08-02T00:00:00Z',
    );

    final profile = UserProfile.fromMap({
      'display_name': 'Tên cũ',
      'avatar_url': 'https://example.com/old.jpg',
      'updated_at': '2026-08-30T11:00:00.000Z',
    }, fallbackUser: updatedUser);

    expect(profile.displayName, 'Tên vừa cập nhật');
    expect(profile.avatarUrl, 'https://example.com/new.jpg');
  });
}

final _user = User(
  id: 'user-1',
  appMetadata: const {},
  userMetadata: const {'full_name': 'Liquid User'},
  aud: 'authenticated',
  email: 'user@example.com',
  createdAt: '2026-08-02T00:00:00Z',
);

const _updatedProfile = UserProfile(
  displayName: 'Liquid User mới',
  avatarUrl: 'https://example.com/new-avatar.jpg',
);

UserWatchHistory _history(int index) => UserWatchHistory(
  slug: 'movie-$index',
  name: 'Movie $index',
  originName: '',
  posterUrl: '',
  thumbUrl: '',
  episodeCurrent: 'Tập $index',
  quality: 'HD',
  lang: 'Vietsub',
  year: 2026,
  rating: 8,
  positionMs: index * 1000,
  durationMs: 100000,
  watchedAt: DateTime(2026, 8, 2, 0, index),
);

final _movie = MovieModel(
  tmdb: null,
  imdb: null,
  created: null,
  modified: null,
  id: 'movie-favorite',
  name: 'Movie Favorite',
  slug: 'movie-favorite',
  origin_name: '',
  content: '',
  type: 'series',
  status: '',
  poster_url: '',
  thumb_url: '',
  is_copyright: false,
  sub_docquyen: false,
  chieurap: false,
  trailer_url: '',
  time: '',
  episode_current: 'Tập 1',
  eposode_total: '',
  quality: 'HD',
  lang: 'Vietsub',
  notify: '',
  showtimes: '',
  year: 2026,
  view: 0,
  actor: const [],
  director: const [],
  category: const [],
  country: const [],
);

class _FakeLibraryRepository implements UserLibraryRepository {
  _FakeLibraryRepository({
    this.user,
    this.failFavorite = false,
    this.profile,
    this.profileUpdateResult,
  });

  User? user;
  final bool failFavorite;
  final UserProfile? profile;
  final UserProfile? profileUpdateResult;
  final List<UserFavorite> favorites = [];
  final List<UserWatchHistory> history = [];
  final List<UserWatchHistory> writtenHistory = [];

  @override
  User? get currentUser => user;

  @override
  Future<UserProfile> getProfile() async =>
      profile ?? UserProfile.fromUser(user);

  @override
  Future<void> addFavorite(UserFavorite favorite) async {
    if (failFavorite) throw Exception('write failed');
    favorites.add(favorite);
  }

  @override
  Future<List<UserFavorite>> getFavorites() async => [...favorites];

  @override
  Future<List<UserWatchHistory>> getWatchHistory() async => [...history];

  @override
  Future<void> removeFavorite(String slug) async {
    favorites.removeWhere((item) => item.slug == slug);
  }

  @override
  Future<void> removeFavorites(Iterable<String> slugs) async {
    final targets = slugs.toSet();
    favorites.removeWhere((item) => targets.contains(item.slug));
  }

  @override
  Future<void> removeWatchHistory(String slug) async {
    history.removeWhere((item) => item.slug == slug);
  }

  @override
  Future<void> removeWatchHistoryItems(Iterable<String> slugs) async {
    final targets = slugs.toSet();
    history.removeWhere((item) => targets.contains(item.slug));
  }

  @override
  Future<UserProfile> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async =>
      profileUpdateResult ??
      UserProfile(
        displayName: displayName,
        avatarUrl: avatarUrl ?? profile?.avatarUrl ?? '',
      );

  @override
  Future<String> uploadAvatar(
    Uint8List bytes, {
    required String extension,
  }) async => 'https://example.com/avatar.$extension';

  @override
  Future<void> upsertWatchHistory(UserWatchHistory history) async {
    writtenHistory.add(history);
  }
}
