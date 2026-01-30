import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/domain/repositories/search_repository.dart';

class SearchMoviesUseCase {
  final SearchRepository repository;

  SearchMoviesUseCase(this.repository);

  Future<Either<String, List<MovieModel>>> call({
    required String keyword,
    int limit = 21,
    int page = 1,
  }) {
    return repository.searchMovies(keyword, limit, page);
  }
}
