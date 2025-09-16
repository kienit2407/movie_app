import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/home/data/models/detail_movie_model.dart';
import 'package:movie_app/feature/home/data/models/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

abstract class MovieRepository {
  Future<Either<String, List<ItemEntity>>> getLatestMovie (int page);
  Future<Either<String, DetailMovieModel>> getDetailMovie (String slug);
  Future<Either<String, List<GenreMovieEntity>>> getGenreMovie ();
  Future<Either<String, List<CountryMovieEntity>>> getCountryMovie ();
  Future<Either<String, FillterMovieGenreEntity>> getFillterMovieGenre (FillterGenreMovieReq fillterGenreReg);
}