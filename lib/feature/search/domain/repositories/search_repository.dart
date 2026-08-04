import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';

abstract class SearchRepository {
  Future<Either<String, List<MovieModel>>> searchMovies(
    String keyword,
    SearchFilterParams filters,
    int page,
  );
}
