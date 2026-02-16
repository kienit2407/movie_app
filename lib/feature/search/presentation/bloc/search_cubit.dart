import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:movie_app/feature/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase searchUseCase;
  late Box<String> _historyBox;
  static const String _historyBoxName = 'search_history';

  SearchCubit({required this.searchUseCase}) : super(SearchLoading()) {
    _initHive();
  }

  Future<void> _initHive() async {
    _historyBox = await Hive.openBox<String>(_historyBoxName);
    _loadHistory();
  }

  void _loadHistory() {
    final history = _historyBox.values.toList().reversed.take(30).toList();
    emit(SearchInitial(history));
  }

  Future<void> addToHistory(String keyword) async {
    if (keyword.trim().isEmpty) return;

    final map = _historyBox.toMap();
    final duplicateKeys = map.entries
        .where((e) => e.value.toLowerCase() == keyword.toLowerCase())
        .map((e) => e.key)
        .toList();

    for (var key in duplicateKeys) {
      await _historyBox.delete(key);
    }

    await _historyBox.add(keyword);
  }

  Future<void> deleteHistoryItem(int index) async {
    final realIndex = _historyBox.length - 1 - index;
    await _historyBox.deleteAt(realIndex);

    if (state is SearchInitial) {
      _loadHistory();
    }
  }

  Future<void> search(String keyword, {bool isLoadMore = false}) async {
    final kw = keyword.trim();
    if (kw.isEmpty) {
      _loadHistory();
      return;
    }

    int page = 1;
    const int limit = 21;

    // ✅ LOAD MORE FLOW
    if (isLoadMore && state is SearchLoaded) {
      final current = state as SearchLoaded;

      // chặn gọi trùng / hết trang
      if (!current.hasMore || current.isLoadingMore) return;

      page = current.page + 1;

      // ✅ bật indicator load more (giữ list hiện tại)
      emit(current.copyWith(isLoadingMore: true));
    } else {
      // ✅ SEARCH MỚI
      emit(SearchLoading());
      addToHistory(kw);
    }

    final result = await searchUseCase.call(
      keyword: kw,
      limit: limit,
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

          emit(current.copyWith(
            movies: [...current.movies, ...movies],
            page: page,
            hasMore: movies.length == limit,
            isLoadingMore: false, // ✅ tắt indicator
          ));
        } else {
          emit(SearchLoaded(
            movies: movies,
            page: page,
            hasMore: movies.length == limit,
            currentKeyword: kw,
            isLoadingMore: false,
          ));
        }
      },
    );
  }

  void clearSearch() {
    _loadHistory();
  }
}
