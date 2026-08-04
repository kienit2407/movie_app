import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserLibraryState {
  const UserLibraryState({
    this.user,
    this.favorites = const <UserFavorite>[],
    this.history = const <UserWatchHistory>[],
    this.isLoading = false,
    this.errorMessage,
    this.syncingFavoriteSlugs = const <String>{},
  });

  final User? user;
  final List<UserFavorite> favorites;
  final List<UserWatchHistory> history;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> syncingFavoriteSlugs;

  bool get isAuthenticated => user != null;
  bool isFavorite(String slug) => favorites.any((item) => item.slug == slug);

  UserLibraryState copyWith({
    User? user,
    bool clearUser = false,
    List<UserFavorite>? favorites,
    List<UserWatchHistory>? history,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    Set<String>? syncingFavoriteSlugs,
  }) => UserLibraryState(
    user: clearUser ? null : user ?? this.user,
    favorites: favorites ?? this.favorites,
    history: history ?? this.history,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    syncingFavoriteSlugs: syncingFavoriteSlugs ?? this.syncingFavoriteSlugs,
  );
}

class UserLibraryCubit extends Cubit<UserLibraryState> {
  UserLibraryCubit({
    required UserLibraryRepository repository,
    SupabaseClient? client,
    Stream<AuthState>? authChanges,
  }) : _repository = repository,
       _client = client ?? Supabase.instance.client,
       super(UserLibraryState(user: repository.currentUser)) {
    _authSubscription = (authChanges ?? _client.auth.onAuthStateChange).listen((
      event,
    ) {
      unawaited(_handleAuthChanged(event.session?.user));
    });
    if (state.isAuthenticated) unawaited(refresh());
  }

  final UserLibraryRepository _repository;
  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _authSubscription;
  final Map<String, UserWatchHistory> _pendingHistory = {};
  Timer? _historySyncTimer;

  Future<void> _handleAuthChanged(User? user) async {
    _historySyncTimer?.cancel();
    _pendingHistory.clear();
    if (user == null) {
      emit(const UserLibraryState());
      return;
    }
    emit(UserLibraryState(user: user, isLoading: true));
    await refresh();
  }

  Future<void> refresh() async {
    final user = _repository.currentUser;
    if (user == null) {
      emit(const UserLibraryState());
      return;
    }
    emit(state.copyWith(user: user, isLoading: true, clearError: true));
    try {
      final values = await Future.wait([
        _repository.getFavorites(),
        _repository.getWatchHistory(),
      ]);
      emit(
        state.copyWith(
          user: _repository.currentUser,
          favorites: values[0] as List<UserFavorite>,
          history: values[1] as List<UserWatchHistory>,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tải thư viện. Hãy thử lại.',
        ),
      );
    }
  }

  Future<bool> toggleFavorite(MovieModel movie) async {
    if (!state.isAuthenticated ||
        state.syncingFavoriteSlugs.contains(movie.slug)) {
      return state.isFavorite(movie.slug);
    }
    final wasFavorite = state.isFavorite(movie.slug);
    final previousFavorites = state.favorites;
    final optimistic = [...previousFavorites];
    if (wasFavorite) {
      optimistic.removeWhere((item) => item.slug == movie.slug);
    } else {
      optimistic.insert(0, UserFavorite.fromMovie(movie));
    }
    emit(
      state.copyWith(
        favorites: optimistic,
        syncingFavoriteSlugs: {...state.syncingFavoriteSlugs, movie.slug},
        clearError: true,
      ),
    );
    try {
      if (wasFavorite) {
        await _repository.removeFavorite(movie.slug);
      } else {
        await _repository.addFavorite(UserFavorite.fromMovie(movie));
      }
      return !wasFavorite;
    } catch (_) {
      emit(
        state.copyWith(
          favorites: previousFavorites,
          errorMessage: 'Không thể cập nhật yêu thích. Hãy thử lại.',
        ),
      );
      return wasFavorite;
    } finally {
      emit(
        state.copyWith(
          syncingFavoriteSlugs: {...state.syncingFavoriteSlugs}
            ..remove(movie.slug),
        ),
      );
    }
  }

  Future<void> removeFavorite(String slug) async {
    if (!state.isAuthenticated) return;
    final previous = state.favorites;
    emit(
      state.copyWith(favorites: previous.where((e) => e.slug != slug).toList()),
    );
    try {
      await _repository.removeFavorite(slug);
    } catch (_) {
      emit(
        state.copyWith(
          favorites: previous,
          errorMessage: 'Không thể bỏ yêu thích. Hãy thử lại.',
        ),
      );
    }
  }

  void queueWatchHistory(UserWatchHistory history, {bool flush = false}) {
    if (!state.isAuthenticated) return;
    _pendingHistory[history.slug] = history;
    final visibleHistory = [
      history,
      ...state.history.where((item) => item.slug != history.slug),
    ].take(100).toList(growable: false);
    emit(state.copyWith(history: visibleHistory, clearError: true));
    _historySyncTimer?.cancel();
    if (flush) {
      unawaited(flushWatchHistory());
    } else {
      _historySyncTimer = Timer(
        const Duration(seconds: 30),
        () => unawaited(flushWatchHistory()),
      );
    }
  }

  Future<void> flushWatchHistory() async {
    _historySyncTimer?.cancel();
    if (!state.isAuthenticated || _pendingHistory.isEmpty) return;
    final pending = List<UserWatchHistory>.from(_pendingHistory.values);
    _pendingHistory.clear();
    try {
      for (final item in pending) {
        await _repository.upsertWatchHistory(item);
      }
    } catch (_) {
      for (final item in pending) {
        _pendingHistory[item.slug] = item;
      }
      emit(state.copyWith(errorMessage: 'Lịch sử sẽ được đồng bộ lại sau.'));
      _historySyncTimer = Timer(
        const Duration(seconds: 30),
        () => unawaited(flushWatchHistory()),
      );
    }
  }

  Future<void> removeHistory(String slug) async {
    if (!state.isAuthenticated) return;
    final previous = state.history;
    emit(
      state.copyWith(history: previous.where((e) => e.slug != slug).toList()),
    );
    try {
      await _repository.removeWatchHistory(slug);
    } catch (_) {
      emit(
        state.copyWith(
          history: previous,
          errorMessage: 'Không thể xóa lịch sử. Hãy thử lại.',
        ),
      );
    }
  }

  Future<void> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    await _repository.updateProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
    emit(state.copyWith(user: _repository.currentUser, clearError: true));
  }

  Future<String> uploadAvatar(List<int> bytes, {required String extension}) {
    return _repository.uploadAvatar(
      Uint8List.fromList(bytes),
      extension: extension,
    );
  }

  @override
  Future<void> close() async {
    _historySyncTimer?.cancel();
    await flushWatchHistory();
    await _authSubscription.cancel();
    return super.close();
  }
}
