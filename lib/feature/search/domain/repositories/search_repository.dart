import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

abstract class SearchRepository {
  Future<Either<String, List<MovieModel>>> searchMovies(String keyword, int limit, int page);
}
