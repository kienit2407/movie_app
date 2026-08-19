import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:movie_app/feature/home/notification/comment_notification.dart';
import 'package:movie_app/feature/home/notification/isolated_hive_bootstrap.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_constants.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';

class NewMovieInboxItem {
  const NewMovieInboxItem({
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    required this.thumbUrl,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    required this.detectedAt,
    this.readAt,
  });

  final String slug;
  final String name;
  final String originName;
  final String posterUrl;
  final String thumbUrl;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final int year;
  final DateTime detectedAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  NewMovieInboxItem markRead(DateTime time) => NewMovieInboxItem(
    slug: slug,
    name: name,
    originName: originName,
    posterUrl: posterUrl,
    thumbUrl: thumbUrl,
    episodeCurrent: episodeCurrent,
    quality: quality,
    lang: lang,
    year: year,
    detectedAt: detectedAt,
    readAt: time,
  );

  Map<String, dynamic> toMap() => {
    'slug': slug,
    'name': name,
    'originName': originName,
    'posterUrl': posterUrl,
    'thumbUrl': thumbUrl,
    'episodeCurrent': episodeCurrent,
    'quality': quality,
    'lang': lang,
    'year': year,
    'detectedAt': detectedAt.toUtc().toIso8601String(),
    'readAt': readAt?.toUtc().toIso8601String(),
  };

  factory NewMovieInboxItem.fromMap(Map<dynamic, dynamic> map) =>
      NewMovieInboxItem(
        slug: map['slug']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        originName: map['originName']?.toString() ?? '',
        posterUrl: map['posterUrl']?.toString() ?? '',
        thumbUrl: map['thumbUrl']?.toString() ?? '',
        episodeCurrent: map['episodeCurrent']?.toString() ?? '',
        quality: map['quality']?.toString() ?? '',
        lang: map['lang']?.toString() ?? '',
        year: int.tryParse(map['year']?.toString() ?? '') ?? 0,
        detectedAt:
            DateTime.tryParse(map['detectedAt']?.toString() ?? '')?.toLocal() ??
            DateTime.now(),
        readAt: DateTime.tryParse(map['readAt']?.toString() ?? '')?.toLocal(),
      );

  static NewMovieInboxItem fromMovie(ItemEntity movie, DateTime detectedAt) =>
      NewMovieInboxItem(
        slug: movie.slug,
        name: movie.name,
        originName: movie.originName,
        posterUrl: movie.posterUrl,
        thumbUrl: movie.thumbUrl,
        episodeCurrent: movie.episodeCurrent,
        quality: movie.quality,
        lang: movie.lang,
        year: movie.year,
        detectedAt: detectedAt,
      );
}

abstract interface class NewMovieInboxStore {
  Stream<void> watch();
  Future<List<NewMovieInboxItem>> getItems();
  Future<void> addMovies(List<ItemEntity> movies, {DateTime? detectedAt});
  Future<void> markAllRead();
  Future<void> prune();
}

class HiveNewMovieInboxStore implements NewMovieInboxStore {
  HiveNewMovieInboxStore({IsolatedHiveBootstrap? hiveBootstrap})
    : _hiveBootstrap = hiveBootstrap ?? IsolatedHiveBootstrap.shared;

  final IsolatedHiveBootstrap _hiveBootstrap;
  Future<IsolatedBox<dynamic>>? _box;

  Future<IsolatedBox<dynamic>> _openBox() async {
    await _hiveBootstrap.ensureInitialized();
    return _box ??= IsolatedHive.openBox<dynamic>(
      NewMovieNotificationConstants.inboxBox,
    );
  }

  @override
  Stream<void> watch() async* {
    final box = await _openBox();
    yield null;
    yield* box.watch().map((_) {});
  }

  @override
  Future<List<NewMovieInboxItem>> getItems() async {
    await prune();
    final box = await _openBox();
    final values = await box.values;
    final items =
        values
            .whereType<Map>()
            .map(NewMovieInboxItem.fromMap)
            .where((item) => item.slug.isNotEmpty)
            .toList()
          ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return items;
  }

  @override
  Future<void> addMovies(
    List<ItemEntity> movies, {
    DateTime? detectedAt,
  }) async {
    if (movies.isEmpty) return;
    await prune();
    final box = await _openBox();
    final time = detectedAt ?? DateTime.now();
    final values = <String, dynamic>{};
    for (final movie in movies) {
      final slug = movie.slug.trim();
      if (slug.isEmpty || await box.containsKey(slug)) continue;
      values[slug] = NewMovieInboxItem.fromMovie(movie, time).toMap();
    }
    if (values.isNotEmpty) await box.putAll(values);
  }

  @override
  Future<void> markAllRead() async {
    await prune();
    final box = await _openBox();
    final values = await box.toMap();
    final now = DateTime.now();
    final updated = <dynamic, dynamic>{};
    for (final entry in values.entries) {
      final raw = entry.value;
      if (raw is! Map) continue;
      final item = NewMovieInboxItem.fromMap(raw);
      if (item.isRead) continue;
      updated[entry.key] = item.markRead(now).toMap();
    }
    if (updated.isNotEmpty) await box.putAll(updated);
  }

  @override
  Future<void> prune() async {
    final box = await _openBox();
    final values = await box.toMap();
    final cutoff = DateTime.now().subtract(
      NewMovieNotificationConstants.inboxRetention,
    );
    final expiredKeys = <dynamic>[];
    for (final entry in values.entries) {
      final raw = entry.value;
      if (raw is! Map) {
        expiredKeys.add(entry.key);
        continue;
      }
      final item = NewMovieInboxItem.fromMap(raw);
      if (item.detectedAt.isBefore(cutoff)) expiredKeys.add(entry.key);
    }
    if (expiredKeys.isNotEmpty) await box.deleteAll(expiredKeys);
  }
}

class NewMovieInboxState {
  const NewMovieInboxState({
    this.items = const <NewMovieInboxItem>[],
    this.commentItems = const <CommentNotificationItem>[],
    this.isLoading = true,
  });

  final List<NewMovieInboxItem> items;
  final List<CommentNotificationItem> commentItems;
  final bool isLoading;
  int get unreadCount =>
      items.where((item) => !item.isRead).length +
      commentItems.where((item) => !item.isRead).length;
}

class NewMovieInboxCubit extends Cubit<NewMovieInboxState> {
  NewMovieInboxCubit(
    this._store, {
    CommentNotificationRepository? commentRepository,
    ApplicationBadgeUpdater? badgeUpdater,
  }) : _commentRepository = commentRepository,
       _badgeUpdater = badgeUpdater,
       super(const NewMovieInboxState()) {
    _subscription = _store.watch().listen((_) => _scheduleRefresh());
    _commentSubscription = _commentRepository?.watch().listen(
      (_) => _scheduleRefresh(),
    );
  }

  static const _refreshDebounceDuration = Duration(milliseconds: 50);

  final NewMovieInboxStore _store;
  final CommentNotificationRepository? _commentRepository;
  final ApplicationBadgeUpdater? _badgeUpdater;
  late final StreamSubscription<void> _subscription;
  StreamSubscription<void>? _commentSubscription;
  Timer? _refreshDebounce;

  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(
      _refreshDebounceDuration,
      () => unawaited(refresh()),
    );
  }

  Future<void> refresh() async {
    final items = await _store.getItems();
    final commentItems = await _getCommentItems();
    if (isClosed) return;
    final nextState = NewMovieInboxState(
      items: items,
      commentItems: commentItems,
      isLoading: false,
    );
    emit(nextState);
    unawaited(_setBadgeCount(nextState.unreadCount));
  }

  Future<void> markAllRead() async {
    if (state.isLoading) await refresh();
    if (state.unreadCount == 0 || isClosed) return;

    final previousState = state;
    final readAt = DateTime.now();
    final readItems = previousState.items
        .map((item) => item.isRead ? item : item.markRead(readAt))
        .toList(growable: false);
    final readCommentItems = previousState.commentItems
        .map((item) => item.isRead ? item : item.markRead(readAt))
        .toList(growable: false);

    emit(
      NewMovieInboxState(
        items: readItems,
        commentItems: readCommentItems,
        isLoading: false,
      ),
    );

    try {
      await _store.markAllRead();
      await _markCommentItemsRead();
      await _setBadgeCount(0);
    } catch (_) {
      if (!isClosed) emit(previousState);
      unawaited(_setBadgeCount(previousState.unreadCount));
      rethrow;
    }
  }

  Future<List<CommentNotificationItem>> _getCommentItems() async {
    final repository = _commentRepository;
    if (repository == null) return const [];
    try {
      return await repository.getItems();
    } catch (_) {
      // Keep the local movie inbox usable before the Supabase migration is
      // deployed or while the social inbox is temporarily unavailable.
      return state.commentItems;
    }
  }

  Future<void> _markCommentItemsRead() async {
    final repository = _commentRepository;
    if (repository == null) return;
    try {
      await repository.markAllRead();
    } catch (_) {
      // The Hive inbox and app badge should still be cleared if the optional
      // server-backed comment inbox is temporarily unavailable.
    }
  }

  Future<void> _setBadgeCount(int count) async {
    try {
      await _badgeUpdater?.setBadgeCount(count);
    } catch (_) {
      // Badge support depends on OS permission and launcher capabilities.
    }
  }

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _subscription.cancel();
    await _commentSubscription?.cancel();
    return super.close();
  }
}
