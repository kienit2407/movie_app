import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_storage.dart';
import 'package:movie_app/feature/home/notification/new_movie_inbox.dart';

typedef LatestMoviesLoader =
    Future<Either<String, List<ItemEntity>>> Function();

enum NewMovieCheckOutcome {
  baselineCreated,
  noChanges,
  notified,
  permissionDenied,
  inboxUpdated,
  failed,
}

class NewMovieCheckResult {
  const NewMovieCheckResult(
    this.outcome, {
    this.newMovies = const <ItemEntity>[],
    this.error,
  });

  final NewMovieCheckOutcome outcome;
  final List<ItemEntity> newMovies;
  final String? error;

  bool get shouldRetry => outcome == NewMovieCheckOutcome.failed;
}

class NewMovieChecker {
  NewMovieChecker({
    required LatestMoviesLoader loadLatestMovies,
    required NewMovieNotificationStore store,
    required NewMovieNotifier notifier,
    NewMovieInboxStore? inboxStore,
  }) : _loadLatestMovies = loadLatestMovies,
       _store = store,
       _notifier = notifier,
       _inboxStore = inboxStore ?? const _NoopNewMovieInboxStore();

  final LatestMoviesLoader _loadLatestMovies;
  final NewMovieNotificationStore _store;
  final NewMovieNotifier _notifier;
  final NewMovieInboxStore _inboxStore;

  Future<bool> seedBaselineIfNeeded(List<ItemEntity> movies) {
    return _store.seedBaselineIfNeeded(movies.map((movie) => movie.slug));
  }

  Future<NewMovieCheckResult> check() async {
    try {
      final response = await _loadLatestMovies();
      return await response.fold(
        (error) async =>
            NewMovieCheckResult(NewMovieCheckOutcome.failed, error: error),
        _processMovies,
      );
    } catch (error) {
      return NewMovieCheckResult(
        NewMovieCheckOutcome.failed,
        error: error.toString(),
      );
    }
  }

  Future<NewMovieCheckResult> _processMovies(List<ItemEntity> movies) async {
    final moviesBySlug = <String, ItemEntity>{};
    for (final movie in movies) {
      final slug = movie.slug.trim();
      if (slug.isNotEmpty) moviesBySlug.putIfAbsent(slug, () => movie);
    }

    if (moviesBySlug.isEmpty) {
      return const NewMovieCheckResult(
        NewMovieCheckOutcome.failed,
        error: 'Latest movie API returned no usable slugs.',
      );
    }

    if (!await _store.isBaselineInitialized) {
      await _store.seedBaselineIfNeeded(moviesBySlug.keys);
      return const NewMovieCheckResult(NewMovieCheckOutcome.baselineCreated);
    }

    final knownSlugs = await _store.getKnownSlugs();
    final newMovies = moviesBySlug.entries
        .where((entry) => !knownSlugs.contains(entry.key))
        .map((entry) => entry.value)
        .toList(growable: false);

    if (newMovies.isEmpty) {
      await _store.recordSuccessfulCheck(DateTime.now());
      return const NewMovieCheckResult(NewMovieCheckOutcome.noChanges);
    }

    await _inboxStore.addMovies(newMovies);
    final notificationsEnabled = await _notifier.areNotificationsEnabled();
    if (notificationsEnabled) {
      final inboxItems = await _inboxStore.getItems();
      final unreadCount = inboxItems.where((item) => !item.isRead).length;
      await _notifier.showNewMovies(newMovies, badgeCount: unreadCount);
    }
    await _store.markKnown(moviesBySlug.keys);
    await _store.recordSuccessfulCheck(DateTime.now());
    return NewMovieCheckResult(
      notificationsEnabled
          ? NewMovieCheckOutcome.notified
          : NewMovieCheckOutcome.inboxUpdated,
      newMovies: newMovies,
    );
  }

  Future<NewMovieCheckResult> processForeground(List<ItemEntity> movies) {
    return _processMovies(movies);
  }
}

/// Keeps the existing checker constructor source-compatible for isolated tests
/// and custom callers. Production always injects [HiveNewMovieInboxStore].
class _NoopNewMovieInboxStore implements NewMovieInboxStore {
  const _NoopNewMovieInboxStore();

  @override
  Future<void> addMovies(
    List<ItemEntity> movies, {
    DateTime? detectedAt,
  }) async {}

  @override
  Future<List<NewMovieInboxItem>> getItems() async => const [];

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> prune() async {}

  @override
  Stream<void> watch() => const Stream<void>.empty();
}
