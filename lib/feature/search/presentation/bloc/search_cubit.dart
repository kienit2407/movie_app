import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/data/repositories/search_history_repository.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/entities/search_movies_page.dart';
import 'package:movie_app/feature/search/domain/usecases/browse_movies_usecase.dart';
import 'package:movie_app/feature/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase searchUseCase;
  final BrowseMoviesUseCase browseUseCase;
  final SearchHistoryRepository historyRepository;
  late final StreamSubscription<String?> _userSubscription;
  List<String> _history = const [];
  int _historyLoadGeneration = 0;
  int _requestGeneration = 0;

  SearchCubit({
    required this.searchUseCase,
    required this.browseUseCase,
    required this.historyRepository,
  }) : super(SearchLoading()) {
    _userSubscription = historyRepository.userChanges.listen((_) {
      clearSearch();
      unawaited(_loadHistory());
    });
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    final generation = ++_historyLoadGeneration;
    final requestGeneration = _requestGeneration;
    try {
      final history = await historyRepository.getHistory();
      if (isClosed || generation != _historyLoadGeneration) return;
      _history = history;
      if (requestGeneration == _requestGeneration &&
          (state is SearchInitial || state is SearchLoading)) {
        emit(SearchInitial(_history));
      }
    } catch (_) {
      if (isClosed || generation != _historyLoadGeneration) return;
      _history = const [];
      if (requestGeneration == _requestGeneration &&
          (state is SearchInitial || state is SearchLoading)) {
        emit(const SearchInitial([]));
      }
    }
  }

  Future<void> addToHistory(String keyword) async {
    final value = keyword.trim();
    if (value.isEmpty || historyRepository.currentUserId == null) return;
    _history = [
      value,
      ..._history.where((item) => item.toLowerCase() != value.toLowerCase()),
    ].take(30).toList(growable: false);
    if (state is SearchInitial) emit(SearchInitial(_history));
    try {
      await historyRepository.saveKeyword(value);
    } catch (_) {
      // Kết quả tìm kiếm vẫn hữu ích khi đồng bộ lịch sử tạm thời thất bại.
    }
  }

  Future<void> deleteHistoryItem(int index) async {
    if (index < 0 || index >= _history.length) return;
    final keyword = _history[index];
    _history = [..._history]..removeAt(index);
    clearSearch();
    try {
      await historyRepository.deleteKeyword(keyword);
    } catch (_) {
      // Không ghi lại local; lần tải kế tiếp sẽ phản ánh dữ liệu trên tài khoản.
    }
  }

  Future<void> search(
    String keyword, {
    bool isLoadMore = false,
    SearchFilterParams? filters,
  }) async {
    final kw = keyword.trim();
    if (kw.isEmpty) {
      clearSearch();
      return;
    }

    await _fetchMovies(kw, isLoadMore: isLoadMore, filters: filters);
  }

  Future<void> browseMovies(
    String movieType, {
    bool isLoadMore = false,
    SearchFilterParams? filters,
  }) async {
    final type = movieType.trim();
    if (type.isEmpty) {
      clearSearch();
      return;
    }
    await _fetchMovies(
      '',
      movieType: type,
      isLoadMore: isLoadMore,
      filters: filters,
    );
  }

  Future<void> _fetchMovies(
    String keyword, {
    String? movieType,
    required bool isLoadMore,
    SearchFilterParams? filters,
  }) async {
    if (isClosed) return;

    int page = 1;
    SearchFilterParams activeFilters = filters ?? SearchFilterParams.defaults;
    SearchLoaded? previous;

    if (isLoadMore) {
      if (state is! SearchLoaded) return;
      final current = state as SearchLoaded;

      if (!current.hasMore ||
          current.isLoadingMore ||
          current.currentKeyword != keyword ||
          current.movieType != movieType ||
          (filters != null && filters.signature != current.filters.signature)) {
        return;
      }

      previous = current;
      page = current.page + 1;
      activeFilters = filters ?? current.filters;
      emit(current.copyWith(isLoadingMore: true));
    } else {
      emit(SearchLoading());
      if (movieType == null) unawaited(addToHistory(keyword));
    }

    final generation = ++_requestGeneration;
    final Either<String, SearchMoviesPage> result;
    if (movieType != null) {
      result = await browseUseCase(
        movieType: movieType,
        filters: activeFilters,
        page: page,
      );
    } else {
      final searchResult = await searchUseCase(
        keyword: keyword,
        filters: activeFilters,
        page: page,
      );
      result = searchResult.map(
        (movies) => SearchMoviesPage(
          movies: movies,
          hasMore: movies.length == activeFilters.limit,
        ),
      );
    }

    // Ignore an earlier chip/search response after the user changes the query.
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (error) {
        if (previous != null) {
          emit(previous.copyWith(isLoadingMore: false));
        } else {
          emit(SearchError(error));
        }
      },
      (resultPage) {
        emit(
          SearchLoaded(
            movies: <MovieModel>[...?previous?.movies, ...resultPage.movies],
            page: page,
            hasMore: resultPage.hasMore,
            currentKeyword: keyword,
            movieType: movieType,
            filters: activeFilters,
          ),
        );
      },
    );
  }

  void clearSearch() {
    ++_requestGeneration;
    if (isClosed) return;
    emit(SearchInitial(_history));
  }

  void prepareForSearch() {
    ++_requestGeneration;
    if (!isClosed) emit(SearchLoading());
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    return super.close();
  }
}
