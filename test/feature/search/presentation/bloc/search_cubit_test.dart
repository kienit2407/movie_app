import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/data/repositories/search_history_repository.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/entities/search_movies_page.dart';
import 'package:movie_app/feature/search/domain/repositories/search_repository.dart';
import 'package:movie_app/feature/search/domain/usecases/browse_movies_usecase.dart';
import 'package:movie_app/feature/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';

void main() {
  test(
    'browses and paginates the selected type without saving history',
    () async {
      final history = _FakeSearchHistoryRepository()..userId = 'user-1';
      final repository = _FakeSearchRepository();
      final cubit = _buildCubit(history, repository: repository);
      addTearDown(cubit.close);
      addTearDown(history.close);
      await _waitForAsyncWork();
      final filters = SearchFilterParams(country: 'han-quoc');

      final firstRequest = cubit.browseMovies('phim-bo', filters: filters);
      repository.browseRequests[0].complete(
        Right(SearchMoviesPage(movies: [_movie('first')], hasMore: true)),
      );
      await firstRequest;
      final secondRequest = cubit.browseMovies('phim-bo', isLoadMore: true);
      expect((cubit.state as SearchLoaded).isLoadingMore, isTrue);
      await cubit.browseMovies('phim-bo', isLoadMore: true);
      expect(repository.browseRequests, hasLength(2));
      repository.browseRequests[1].complete(
        Right(SearchMoviesPage(movies: [_movie('second')], hasMore: false)),
      );
      await secondRequest;

      final loaded = cubit.state as SearchLoaded;
      expect(loaded.movies.map((movie) => movie.slug), ['first', 'second']);
      expect(loaded.movieType, 'phim-bo');
      expect(loaded.currentKeyword, isEmpty);
      expect(loaded.page, 2);
      expect(repository.browseCalls, [
        ('phim-bo', 1, filters),
        ('phim-bo', 2, filters),
      ]);
      expect(history.savedKeywords, isEmpty);
      await cubit.browseMovies('phim-bo', isLoadMore: true);
      expect(repository.browseRequests, hasLength(2));
    },
  );

  test('ignores a slow response from a previously selected chip', () async {
    final history = _FakeSearchHistoryRepository();
    final repository = _FakeSearchRepository();
    final cubit = _buildCubit(history, repository: repository);
    addTearDown(cubit.close);
    addTearDown(history.close);
    await _waitForAsyncWork();

    final oldRequest = cubit.browseMovies('phim-bo');
    final newRequest = cubit.browseMovies('phim-le');
    repository.browseRequests[1].complete(
      Right(SearchMoviesPage(movies: [_movie('new')], hasMore: false)),
    );
    await newRequest;
    repository.browseRequests[0].complete(
      Right(SearchMoviesPage(movies: [_movie('old')], hasMore: false)),
    );
    await oldRequest;

    expect((cubit.state as SearchLoaded).movieType, 'phim-le');
    expect((cubit.state as SearchLoaded).movies.single.slug, 'new');
  });

  test(
    'typing invalidates chip results before the debounce finishes',
    () async {
      final history = _FakeSearchHistoryRepository();
      final repository = _FakeSearchRepository();
      final cubit = _buildCubit(history, repository: repository);
      addTearDown(cubit.close);
      addTearDown(history.close);
      await _waitForAsyncWork();

      final request = cubit.browseMovies('phim-bo');
      cubit.prepareForSearch();
      repository.browseRequests.single.complete(
        Right(SearchMoviesPage(movies: [_movie('old')], hasMore: false)),
      );
      await request;
      expect(cubit.state, isA<SearchLoading>());

      await cubit.search('Batman');
      expect((cubit.state as SearchLoaded).movieType, isNull);
      expect((cubit.state as SearchLoaded).currentKeyword, 'Batman');
    },
  );

  test(
    'clearing prevents an in-flight chip request from restoring results',
    () async {
      final history = _FakeSearchHistoryRepository();
      final repository = _FakeSearchRepository();
      final cubit = _buildCubit(history, repository: repository);
      addTearDown(cubit.close);
      addTearDown(history.close);
      await _waitForAsyncWork();
      final request = cubit.browseMovies('phim-bo');
      cubit.clearSearch();
      repository.browseRequests.single.complete(
        Right(SearchMoviesPage(movies: [_movie('old')], hasMore: false)),
      );
      await request;
      expect(cubit.state, isA<SearchInitial>());
    },
  );

  test('keeps the list when loading another page fails', () async {
    final history = _FakeSearchHistoryRepository();
    final repository = _FakeSearchRepository();
    final cubit = _buildCubit(history, repository: repository);
    addTearDown(cubit.close);
    addTearDown(history.close);
    await _waitForAsyncWork();
    final first = cubit.browseMovies('phim-bo');
    repository.browseRequests.single.complete(
      Right(SearchMoviesPage(movies: [_movie('first')], hasMore: true)),
    );
    await first;
    final next = cubit.browseMovies('phim-bo', isLoadMore: true);
    repository.browseRequests.last.complete(const Left('offline'));
    await next;
    expect((cubit.state as SearchLoaded).movies.single.slug, 'first');
    expect((cubit.state as SearchLoaded).page, 1);
    expect((cubit.state as SearchLoaded).isLoadingMore, isFalse);
  });

  test('loads search history from the current account', () async {
    final historyRepository = _FakeSearchHistoryRepository()
      ..userId = 'user-1'
      ..historyByUser['user-1'] = ['Dune', 'Batman'];
    final cubit = _buildCubit(historyRepository);
    addTearDown(cubit.close);
    addTearDown(historyRepository.close);

    await _waitForAsyncWork();

    expect((cubit.state as SearchInitial).history, ['Dune', 'Batman']);
  });

  test(
    'reloads a different history after the signed-in account changes',
    () async {
      final historyRepository = _FakeSearchHistoryRepository()
        ..userId = 'user-1'
        ..historyByUser['user-1'] = ['Dune']
        ..historyByUser['user-2'] = ['Avatar'];
      final cubit = _buildCubit(historyRepository);
      addTearDown(cubit.close);
      addTearDown(historyRepository.close);
      await _waitForAsyncWork();

      historyRepository.changeUser('user-2');
      await _waitForAsyncWork();

      expect((cubit.state as SearchInitial).history, ['Avatar']);
    },
  );

  test('saves a keyword through the account repository only', () async {
    final historyRepository = _FakeSearchHistoryRepository()..userId = 'user-1';
    final cubit = _buildCubit(historyRepository);
    addTearDown(cubit.close);
    addTearDown(historyRepository.close);
    await _waitForAsyncWork();

    await cubit.addToHistory('  Dune  ');

    expect((cubit.state as SearchInitial).history, ['Dune']);
    expect(historyRepository.savedKeywords, ['Dune']);
  });

  test('does not retain search history while signed out', () async {
    final historyRepository = _FakeSearchHistoryRepository();
    final cubit = _buildCubit(historyRepository);
    addTearDown(cubit.close);
    addTearDown(historyRepository.close);
    await _waitForAsyncWork();

    await cubit.addToHistory('Dune');

    expect((cubit.state as SearchInitial).history, isEmpty);
    expect(historyRepository.savedKeywords, isEmpty);
  });
}

SearchCubit _buildCubit(
  SearchHistoryRepository historyRepository, {
  _FakeSearchRepository? repository,
}) {
  final searchRepository = repository ?? _FakeSearchRepository();
  return SearchCubit(
    searchUseCase: SearchMoviesUseCase(searchRepository),
    browseUseCase: BrowseMoviesUseCase(searchRepository),
    historyRepository: historyRepository,
  );
}

MovieModel _movie(String slug) => MovieModel.fromMap({'slug': slug});

Future<void> _waitForAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

class _FakeSearchRepository implements SearchRepository {
  final browseCalls = <(String, int, SearchFilterParams)>[];
  final browseRequests = <Completer<Either<String, SearchMoviesPage>>>[];

  @override
  Future<Either<String, SearchMoviesPage>> browseMovies(
    String movieType,
    SearchFilterParams filters,
    int page,
  ) {
    browseCalls.add((movieType, page, filters));
    final request = Completer<Either<String, SearchMoviesPage>>();
    browseRequests.add(request);
    return request.future;
  }

  @override
  Future<Either<String, List<MovieModel>>> searchMovies(
    String keyword,
    SearchFilterParams filters,
    int page,
  ) async => const Right([]);
}

class _FakeSearchHistoryRepository implements SearchHistoryRepository {
  final StreamController<String?> _userChanges =
      StreamController<String?>.broadcast();
  final Map<String, List<String>> historyByUser = {};
  final List<String> savedKeywords = [];
  String? userId;

  @override
  String? get currentUserId => userId;

  @override
  Stream<String?> get userChanges => _userChanges.stream;

  void changeUser(String? nextUserId) {
    userId = nextUserId;
    _userChanges.add(nextUserId);
  }

  Future<void> close() => _userChanges.close();

  @override
  Future<List<String>> getHistory() async =>
      List<String>.from(historyByUser[userId] ?? const []);

  @override
  Future<void> saveKeyword(String keyword) async {
    savedKeywords.add(keyword);
  }

  @override
  Future<void> deleteKeyword(String keyword) async {}
}
