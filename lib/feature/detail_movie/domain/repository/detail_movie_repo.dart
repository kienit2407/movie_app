import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

/// Abstract Repository - nằm ở Domain layer
/// Định nghĩa contract cho Data layer implement
abstract class DetailMovieRepository {
  
  Future<Either<String, DetailMovieModel>> getDetailMovie(String slug);
}
