import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> history;
  const SearchInitial(this.history);

  @override
  List<Object?> get props => [history];
}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<MovieModel> movies;
  final bool hasMore;
  final int page;
  final String currentKeyword;

  // ✅ NEW
  final bool isLoadingMore;

  const SearchLoaded({
    required this.movies,
    this.hasMore = true,
    required this.page,
    required this.currentKeyword,
    this.isLoadingMore = false,
  });

  SearchLoaded copyWith({
    List<MovieModel>? movies,
    bool? hasMore,
    int? page,
    String? currentKeyword,
    bool? isLoadingMore,
  }) {
    return SearchLoaded(
      movies: movies ?? this.movies,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      currentKeyword: currentKeyword ?? this.currentKeyword,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [movies, hasMore, page, currentKeyword, isLoadingMore];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
