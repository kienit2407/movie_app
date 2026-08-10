import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_inbox.dart';

void main() {
  group('NewMovieInboxCubit', () {
    test('marks loaded items read without an extra explicit refresh', () async {
      final store = _FakeInboxStore(items: [_inboxItem('movie-1')]);
      final cubit = NewMovieInboxCubit(store);
      addTearDown(() async {
        await cubit.close();
        await store.close();
      });

      await cubit.refresh();
      expect(cubit.state.unreadCount, 1);

      await cubit.markAllRead();

      expect(cubit.state.unreadCount, 0);
      expect(store.markAllReadCalls, 1);
      expect(store.getItemsCalls, 1);
    });

    test('coalesces a burst of store changes into one refresh', () async {
      final store = _FakeInboxStore();
      final cubit = NewMovieInboxCubit(store);
      addTearDown(() async {
        await cubit.close();
        await store.close();
      });

      store.notifyChanges(6);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(store.getItemsCalls, 1);
    });
  });
}

NewMovieInboxItem _inboxItem(String slug) => NewMovieInboxItem(
  slug: slug,
  name: 'Movie $slug',
  originName: 'Movie $slug',
  posterUrl: 'https://example.com/$slug.jpg',
  thumbUrl: '',
  episodeCurrent: 'Tập 1',
  quality: 'FHD',
  lang: 'Vietsub',
  year: 2026,
  detectedAt: DateTime(2026, 8, 11, 10),
);

class _FakeInboxStore implements NewMovieInboxStore {
  _FakeInboxStore({List<NewMovieInboxItem> items = const []})
    : items = List<NewMovieInboxItem>.of(items);

  final StreamController<void> _changes = StreamController<void>.broadcast();
  final List<NewMovieInboxItem> items;

  int getItemsCalls = 0;
  int markAllReadCalls = 0;

  void notifyChanges(int count) {
    for (var index = 0; index < count; index++) {
      _changes.add(null);
    }
  }

  Future<void> close() => _changes.close();

  @override
  Stream<void> watch() => _changes.stream;

  @override
  Future<List<NewMovieInboxItem>> getItems() async {
    getItemsCalls++;
    return List<NewMovieInboxItem>.of(items);
  }

  @override
  Future<void> markAllRead() async {
    markAllReadCalls++;
    final readAt = DateTime(2026, 8, 11, 11);
    for (var index = 0; index < items.length; index++) {
      if (!items[index].isRead) items[index] = items[index].markRead(readAt);
    }
  }

  @override
  Future<void> addMovies(
    List<ItemEntity> movies, {
    DateTime? detectedAt,
  }) async {}

  @override
  Future<void> prune() async {}
}
