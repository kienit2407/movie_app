import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/home/data/models/detail_movie_model.dart';
import 'package:movie_app/feature/home/data/models/new_movie_model.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

abstract class MovieRepository {
  Future<Either<String, List<ItemEntity>>> getLatestMovie (int page);
  Future<Either<String, DetailMovieModel>> getDetailMovie (String slug);
}