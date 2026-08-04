import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_checker.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_storage.dart';

void main() {
  group('NewMovieChecker', () {
    test('creates the first baseline without notifying', () async {
      final store = FakeNewMovieStore();
      final notifier = FakeNewMovieNotifier();
      final checker = buildChecker(
        movies: [movie('first'), movie('second')],
        store: store,
        notifier: notifier,
      );

      final result = await checker.check();

      expect(result.outcome, NewMovieCheckOutcome.baselineCreated);
      expect(store.baselineInitialized, isTrue);
      expect(store.knownSlugs, {'first', 'second'});
      expect(notifier.shownBatches, isEmpty);
    });

    test('does not notify when only episode data changes', () async {
      final store = FakeNewMovieStore(
        baselineInitialized: true,
        knownSlugs: {'same-movie'},
      );
      final notifier = FakeNewMovieNotifier();
      final checker = buildChecker(
        movies: [movie('same-movie', episodeCurrent: 'Tập 12')],
        store: store,
        notifier: notifier,
      );

      final result = await checker.check();

      expect(result.outcome, NewMovieCheckOutcome.noChanges);
      expect(notifier.shownBatches, isEmpty);
    });

    test(
      'notifies once for one unseen slug and marks the page known',
      () async {
        final store = FakeNewMovieStore(
          baselineInitialized: true,
          knownSlugs: {'old-movie'},
        );
        final notifier = FakeNewMovieNotifier();
        final checker = buildChecker(
          movies: [movie('new-movie'), movie('old-movie')],
          store: store,
          notifier: notifier,
        );

        final result = await checker.check();

        expect(result.outcome, NewMovieCheckOutcome.notified);
        expect(result.newMovies.map((item) => item.slug), ['new-movie']);
        expect(notifier.shownBatches, hasLength(1));
        expect(store.knownSlugs, {'new-movie', 'old-movie'});
      },
    );

    test('sends multiple unseen movies as one batch', () async {
      final store = FakeNewMovieStore(
        baselineInitialized: true,
        knownSlugs: {'old-movie'},
      );
      final notifier = FakeNewMovieNotifier();
      final checker = buildChecker(
        movies: [movie('new-one'), movie('new-two'), movie('old-movie')],
        store: store,
        notifier: notifier,
      );

      final result = await checker.check();

      expect(result.outcome, NewMovieCheckOutcome.notified);
      expect(notifier.shownBatches, hasLength(1));
      expect(notifier.shownBatches.single.map((item) => item.slug), [
        'new-one',
        'new-two',
      ]);
    });

    test(
      'does not mutate the snapshot when the API fails or is empty',
      () async {
        final store = FakeNewMovieStore(
          baselineInitialized: true,
          knownSlugs: {'old-movie'},
        );
        final notifier = FakeNewMovieNotifier();
        final failedChecker = NewMovieChecker(
          loadLatestMovies: () async => const Left('network error'),
          store: store,
          notifier: notifier,
        );
        final emptyChecker = buildChecker(
          movies: const [],
          store: store,
          notifier: notifier,
        );

        final failedResult = await failedChecker.check();
        final emptyResult = await emptyChecker.check();

        expect(failedResult.outcome, NewMovieCheckOutcome.failed);
        expect(emptyResult.outcome, NewMovieCheckOutcome.failed);
        expect(store.knownSlugs, {'old-movie'});
        expect(notifier.shownBatches, isEmpty);
      },
    );

    test(
      'does not mark a movie known when showing the notification fails',
      () async {
        final store = FakeNewMovieStore(
          baselineInitialized: true,
          knownSlugs: {'old-movie'},
        );
        final notifier = FakeNewMovieNotifier(throwWhenShowing: true);
        final checker = buildChecker(
          movies: [movie('new-movie'), movie('old-movie')],
          store: store,
          notifier: notifier,
        );

        final result = await checker.check();

        expect(result.outcome, NewMovieCheckOutcome.failed);
        expect(store.knownSlugs, {'old-movie'});
      },
    );

    test('does not notify the same page twice', () async {
      final store = FakeNewMovieStore(
        baselineInitialized: true,
        knownSlugs: {'old-movie'},
      );
      final notifier = FakeNewMovieNotifier();
      final checker = buildChecker(
        movies: [movie('new-movie'), movie('old-movie')],
        store: store,
        notifier: notifier,
      );

      final firstResult = await checker.check();
      final secondResult = await checker.check();

      expect(firstResult.outcome, NewMovieCheckOutcome.notified);
      expect(secondResult.outcome, NewMovieCheckOutcome.noChanges);
      expect(notifier.shownBatches, hasLength(1));
    });

    test(
      'still checks the API when notification permission is disabled',
      () async {
        var loaderCalls = 0;
        final checker = NewMovieChecker(
          loadLatestMovies: () async {
            loaderCalls++;
            return Right([movie('new-movie')]);
          },
          store: FakeNewMovieStore(),
          notifier: FakeNewMovieNotifier(enabled: false),
        );

        final result = await checker.check();

        expect(result.outcome, NewMovieCheckOutcome.baselineCreated);
        expect(loaderCalls, 1);
      },
    );
  });
}

NewMovieChecker buildChecker({
  required List<ItemEntity> movies,
  required FakeNewMovieStore store,
  required FakeNewMovieNotifier notifier,
}) {
  return NewMovieChecker(
    loadLatestMovies: () async => Right(movies),
    store: store,
    notifier: notifier,
  );
}

ItemEntity movie(String slug, {String episodeCurrent = 'Tập 1'}) {
  return ItemEntity(
    tmdb: TmDbEntity(voteAverage: 0),
    modified: ModifiedEntity(time: '2026-01-01T00:00:00Z'),
    id: slug,
    name: 'Movie $slug',
    slug: slug,
    originName: 'Movie $slug',
    type: 'single',
    posterUrl: 'https://example.com/$slug.jpg',
    thumbUrl: 'https://example.com/$slug-thumb.jpg',
    time: '90 phút',
    episodeCurrent: episodeCurrent,
    quality: 'HD',
    lang: 'Vietsub',
    year: 2026,
    category: const [],
    country: const [],
  );
}

class FakeNewMovieStore implements NewMovieNotificationStore {
  FakeNewMovieStore({
    this.baselineInitialized = false,
    Set<String>? knownSlugs,
    this.onboardingShown = false,
  }) : knownSlugs = knownSlugs ?? <String>{};

  bool baselineInitialized;
  bool onboardingShown;
  final Set<String> knownSlugs;
  DateTime? lastSuccessfulCheckAt;

  @override
  Future<bool> get isBaselineInitialized async => baselineInitialized;

  @override
  Future<bool> get isOnboardingShown async => onboardingShown;

  @override
  Future<Set<String>> getKnownSlugs() async => Set.of(knownSlugs);

  @override
  Future<void> markKnown(Iterable<String> slugs) async {
    knownSlugs.addAll(slugs);
  }

  @override
  Future<void> markOnboardingShown() async {
    onboardingShown = true;
  }

  @override
  Future<void> recordSuccessfulCheck(DateTime checkedAt) async {
    lastSuccessfulCheckAt = checkedAt;
  }

  @override
  Future<bool> seedBaselineIfNeeded(Iterable<String> slugs) async {
    if (baselineInitialized) return false;
    final validSlugs = slugs.where((slug) => slug.trim().isNotEmpty);
    if (validSlugs.isEmpty) return false;

    knownSlugs.addAll(validSlugs);
    baselineInitialized = true;
    return true;
  }
}

class FakeNewMovieNotifier implements NewMovieNotifier {
  FakeNewMovieNotifier({this.enabled = true, this.throwWhenShowing = false});

  bool enabled;
  bool throwWhenShowing;
  final List<List<ItemEntity>> shownBatches = [];

  @override
  Future<bool> areNotificationsEnabled() async => enabled;

  @override
  Future<void> showNewMovies(List<ItemEntity> movies) async {
    if (throwWhenShowing) throw StateError('notification failed');
    shownBatches.add(List.of(movies));
  }
}
