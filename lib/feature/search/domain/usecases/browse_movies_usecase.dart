import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/entities/search_movies_page.dart';
import 'package:movie_app/feature/search/domain/repositories/search_repository.dart';

class BrowseMoviesUseCase {
  final SearchRepository repository;

  BrowseMoviesUseCase(this.repository);

  Future<Either<String, SearchMoviesPage>> call({
    required String movieType,
    SearchFilterParams filters = SearchFilterParams.defaults,
    int page = 1,
  }) => repository.browseMovies(movieType, filters, page);
}
