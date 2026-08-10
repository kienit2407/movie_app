import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_constants.dart';

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
  Future<void>? _initialization;
  Future<IsolatedBox<dynamic>>? _box;

  Future<void> _ensureInitialized() =>
      _initialization ??= IsolatedHive.initFlutter();

  Future<IsolatedBox<dynamic>> _openBox() async {
    await _ensureInitialized();
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
    this.isLoading = true,
  });

  final List<NewMovieInboxItem> items;
  final bool isLoading;
  int get unreadCount => items.where((item) => !item.isRead).length;
}

class NewMovieInboxCubit extends Cubit<NewMovieInboxState> {
  NewMovieInboxCubit(this._store) : super(const NewMovieInboxState()) {
    _subscription = _store.watch().listen((_) => _scheduleRefresh());
  }

  static const _refreshDebounceDuration = Duration(milliseconds: 50);

  final NewMovieInboxStore _store;
  late final StreamSubscription<void> _subscription;
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
    if (isClosed) return;
    emit(NewMovieInboxState(items: items, isLoading: false));
  }

  Future<void> markAllRead() async {
    if (state.isLoading) await refresh();
    if (state.unreadCount == 0 || isClosed) return;

    final previousState = state;
    final readAt = DateTime.now();
    final readItems = previousState.items
        .map((item) => item.isRead ? item : item.markRead(readAt))
        .toList(growable: false);

    emit(NewMovieInboxState(items: readItems, isLoading: false));

    try {
      await _store.markAllRead();
    } catch (_) {
      if (!isClosed) emit(previousState);
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    _refreshDebounce?.cancel();
    await _subscription.cancel();
    return super.close();
  }
}
