import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/entities/search_movies_page.dart';

abstract class SearchRepository {
  Future<Either<String, SearchMoviesPage>> browseMovies(
    String movieType,
    SearchFilterParams filters,
    int page,
  );

  Future<Either<String, List<MovieModel>>> searchMovies(
    String keyword,
    SearchFilterParams filters,
    int page,
  );
}
