import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/errol/app_exception.dart';
import 'package:movie_app/feature/home/data/models/detail_movie_model.dart';
import 'package:movie_app/feature/home/data/models/fillter_genre_model.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/data/models/genre_movie_model.dart';
import 'package:movie_app/feature/home/data/models/new_movie_model.dart';
import 'package:movie_app/feature/home/data/source/movie_remote_datasource.dart';
import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  @override
  Future<Either<String, List<ItemEntity>>> getLatestMovie(int page) async {
    try {
      final newMovieModel = await sl<MovieRemoteDatasource>().getLatestMovie(page);
      final latestMovieList = newMovieModel.items.map((model) => model.toEntity()).toList();
      return Right(latestMovieList);
    } on NetworkException catch (e) {
      return Left('$e');
    }
  }

  @override
  Future<Either<String, DetailMovieModel>> getDetailMovie(String slug) async {
    try {
      final newMovieModel = await sl<MovieRemoteDatasource>().getDetailMovie(slug);
      return Right(newMovieModel);

    } on NetworkException catch (e) {
      return Left('$e');
    }
  }
  
  @override
  Future<Either<String, List<GenreMovieEntity>>> getGenreMovie() async {
    try {
      final genreMovie = await sl<MovieRemoteDatasource>().getGenrelMovie();

      return Right(genreMovie.map((e) => e.toEntity()).toList());

    } on NetworkException catch (e) {
      return Left('$e');
    }
  }

  @override
  Future<Either<String, FillterMovieGenreEntity>> getFillterMovieGenre(FillterMovieReq fillterGenreReg) async {
    try {
      final fillterMovieGenre = await sl<MovieRemoteDatasource>().getFillterMovieGenre(fillterGenreReg);
      return Right(fillterMovieGenre.toEntity());
    } on NetworkException catch (e) {
      return Left('$e');
    }
  }

  @override
  Future<Either<String, List<CountryMovieEntity>>> getCountryMovie() async {
    try {
      final countryMovie = await sl<MovieRemoteDatasource>().getMoiveCountry();
      return Right(countryMovie);
    } on NetworkException catch (e) {
      return Left('$e');
    }
  }
  
  @override
  Future<Either<String, FillterMovieGenreEntity>> getFillterMovieCountry(FillterMovieReq fillterGenreReg) async {
    try {
      final fillterMovieGenre = await sl<MovieRemoteDatasource>().getFillterMovieCountry(fillterGenreReg);
      return Right(fillterMovieGenre.toEntity());
    } on NetworkException catch (e) {
      return Left('$e');
    }
  }
  

} 