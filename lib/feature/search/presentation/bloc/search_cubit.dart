import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';
import 'package:movie_app/feature/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMoviesUseCase searchUseCase;
  late Box<String> _historyBox;
  static const String _historyBoxName = 'search_history';

  SearchCubit({required this.searchUseCase}) : super( SearchLoading()) {
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
    if (keyword.isEmpty) {
      _loadHistory();
      return;
    }

    int page = 1;
    final int limit = 21;
    
    if (state is SearchLoaded && isLoadMore) {
      final currentState = state as SearchLoaded;
      if (!currentState.hasMore) return;
      page = currentState.page + 1;
    } else {
      emit(SearchLoading());
      addToHistory(keyword);
    }

    final result = await searchUseCase.call(
      keyword: keyword, 
      limit: limit, 
      page: page
    );

    result.fold(
      (error) {
        if (!isLoadMore) emit(SearchError(error));
      },
      (movies) {
        if (isLoadMore && state is SearchLoaded) {
          final currentState = state as SearchLoaded;
          emit(currentState.copyWith(
            movies: [...currentState.movies, ...movies],
            page: page,
            hasMore: movies.length == limit,
          ));
        } else {
          emit(SearchLoaded(
            movies: movies,
            page: page,
            hasMore: movies.length == limit,
            currentKeyword: keyword,
          ));
        }
      },
    );
  }
  
  void clearSearch() {
    _loadHistory();
  }
}
