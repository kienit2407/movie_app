import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/search/data/repositories/search_history_repository.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase searchUseCase;
  final SearchHistoryRepository historyRepository;
  late final StreamSubscription<String?> _userSubscription;
  List<String> _history = const [];
  int _historyLoadGeneration = 0;

  SearchCubit({required this.searchUseCase, required this.historyRepository})
    : super(SearchLoading()) {
    _userSubscription = historyRepository.userChanges.listen((_) {
      unawaited(_loadHistory());
    });
    unawaited(_loadHistory());
  }

  Future<void> _loadHistory() async {
    final generation = ++_historyLoadGeneration;
    try {
      final history = await historyRepository.getHistory();
      if (isClosed || generation != _historyLoadGeneration) return;
      _history = history;
      emit(SearchInitial(_history));
    } catch (_) {
      if (isClosed || generation != _historyLoadGeneration) return;
      _history = const [];
      emit(const SearchInitial([]));
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
    emit(SearchInitial(_history));
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
      emit(SearchInitial(_history));
      return;
    }

    int page = 1;
    SearchFilterParams activeFilters = filters ?? SearchFilterParams.defaults;

    // ✅ LOAD MORE FLOW
    if (isLoadMore && state is SearchLoaded) {
      final current = state as SearchLoaded;

      // chặn gọi trùng / hết trang
      if (!current.hasMore || current.isLoadingMore) return;

      page = current.page + 1;
      activeFilters = filters ?? current.filters;

      // ✅ bật indicator load more (giữ list hiện tại)
      emit(current.copyWith(isLoadingMore: true));
    } else {
      // ✅ SEARCH MỚI
      emit(SearchLoading());
      unawaited(addToHistory(kw));
    }

    final result = await searchUseCase.call(
      keyword: kw,
      filters: activeFilters,
      page: page,
    );

    result.fold(
      (error) {
        if (isLoadMore && state is SearchLoaded) {
          // ✅ lỗi load more: giữ list, tắt indicator
          final current = state as SearchLoaded;
          emit(current.copyWith(isLoadingMore: false));
        } else {
          emit(SearchError(error));
        }
      },
      (movies) {
        if (isLoadMore && state is SearchLoaded) {
          final current = state as SearchLoaded;

          emit(
            current.copyWith(
              movies: [...current.movies, ...movies],
              page: page,
              hasMore: movies.length == activeFilters.limit,
              filters: activeFilters,
              isLoadingMore: false, // ✅ tắt indicator
            ),
          );
        } else {
          emit(
            SearchLoaded(
              movies: movies,
              page: page,
              hasMore: movies.length == activeFilters.limit,
              currentKeyword: kw,
              filters: activeFilters,
              isLoadingMore: false,
            ),
          );
        }
      },
    );
  }

  void clearSearch() {
    emit(SearchInitial(_history));
  }

  @override
  Future<void> close() async {
    await _userSubscription.cancel();
    return super.close();
  }
}
