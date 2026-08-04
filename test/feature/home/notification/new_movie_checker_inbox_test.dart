import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_checker.dart';
import 'package:movie_app/feature/home/notification/new_movie_inbox.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_navigation.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_storage.dart';

void main() {
  test(
    'stores new movies in inbox when system notifications are disabled',
    () async {
      final oldMovie = _movie('old');
      final newMovie = _movie('new');
      final notificationStore = _FakeNotificationStore()
        ..baselineInitialized = true
        ..knownSlugs.add(oldMovie.slug);
      final inbox = _FakeInboxStore();
      final notifier = _FakeNotifier(enabled: false);
      final checker = NewMovieChecker(
        loadLatestMovies: () async => right([oldMovie, newMovie]),
        store: notificationStore,
        notifier: notifier,
        inboxStore: inbox,
      );

      final result = await checker.check();

      expect(result.outcome, NewMovieCheckOutcome.inboxUpdated);
      expect(result.newMovies.map((movie) => movie.slug), ['new']);
      expect(inbox.movies.map((movie) => movie.slug), ['new']);
      expect(notifier.shownMovies, isEmpty);
      expect(notificationStore.knownSlugs, containsAll(['old', 'new']));
    },
  );

  test('routes grouped notification payload to notification inbox', () {
    expect(
      NewMovieNotificationNavigation.routeFromPayload('{"type":"new_movies"}'),
      AppRoutes.notifications,
    );
    expect(
      NewMovieNotificationNavigation.routeFromPayload('invalid'),
      AppRoutes.home,
    );
  });
}

ItemEntity _movie(String slug) => ItemEntity(
  tmdb: TmDbEntity(voteAverage: 8),
  modified: ModifiedEntity(time: '2026-08-02'),
  id: slug,
  name: 'Movie $slug',
  slug: slug,
  originName: 'Movie $slug',
  type: 'series',
  posterUrl: 'https://example.com/$slug.jpg',
  thumbUrl: '',
  time: '45 phút',
  episodeCurrent: 'Tập 1',
  quality: 'HD',
  lang: 'Vietsub',
  year: 2026,
  category: const [],
  country: const [],
);

class _FakeNotificationStore implements NewMovieNotificationStore {
  bool baselineInitialized = false;
  bool onboardingShown = false;
  final Set<String> knownSlugs = {};

  @override
  Future<Set<String>> getKnownSlugs() async => {...knownSlugs};

  @override
  Future<bool> get isBaselineInitialized async => baselineInitialized;

  @override
  Future<bool> get isOnboardingShown async => onboardingShown;

  @override
  Future<void> markKnown(Iterable<String> slugs) async {
    knownSlugs.addAll(slugs);
  }

  @override
  Future<void> markOnboardingShown() async => onboardingShown = true;

  @override
  Future<void> recordSuccessfulCheck(DateTime checkedAt) async {}

  @override
  Future<bool> seedBaselineIfNeeded(Iterable<String> slugs) async {
    if (baselineInitialized) return false;
    knownSlugs.addAll(slugs);
    baselineInitialized = true;
    return true;
  }
}

class _FakeInboxStore implements NewMovieInboxStore {
  final List<ItemEntity> movies = [];

  @override
  Future<void> addMovies(
    List<ItemEntity> movies, {
    DateTime? detectedAt,
  }) async {
    this.movies.addAll(movies);
  }

  @override
  Future<List<NewMovieInboxItem>> getItems() async => const [];

  @override
  Future<void> markAllRead() async {}

  @override
  Future<void> prune() async {}

  @override
  Stream<void> watch() => const Stream.empty();
}

class _FakeNotifier implements NewMovieNotifier {
  _FakeNotifier({required this.enabled});

  final bool enabled;
  final List<ItemEntity> shownMovies = [];

  @override
  Future<bool> areNotificationsEnabled() async => enabled;

  @override
  Future<void> showNewMovies(List<ItemEntity> movies) async {
    shownMovies.addAll(movies);
  }
}
