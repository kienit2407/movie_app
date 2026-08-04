import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/repositories/search_repository.dart';

class SearchMoviesUseCase {
  final SearchRepository repository;

  SearchMoviesUseCase(this.repository);

  Future<Either<String, List<MovieModel>>> call({
    required String keyword,
    SearchFilterParams filters = SearchFilterParams.defaults,
    int page = 1,
  }) {
    return repository.searchMovies(keyword, filters, page);
  }
}
