import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errol/app_exception.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/home/data/models/new_movie_model.dart';
import 'package:movie_app/feature/home/data/models/genre_movie_model.dart';
import 'package:movie_app/feature/home/data/models/fillter_genre_model.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/data/source/movie_remote_datasource.dart';
import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

/// Implementation của MovieRepository
/// Nằm ở Data layer, chịu trách nhiệm gọi DataSource và xử lý lỗi
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDatasource remoteDatasource;

  MovieRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<String, List<ItemEntity>>> getLatestMovie(int page) async {
    try {
      final result = await remoteDatasource.getLatestMovie(page);
      final entities = result.items.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on NetworkException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, DetailMovieModel>> getDetailMovie(String slug) async {
    try {
      final result = await remoteDatasource.getDetailMovie(slug);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, List<GenreMovieEntity>>> getGenreMovie() async {
    try {
      final result = await remoteDatasource.getGenreMovie();
      return Right(result.map((e) => e.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  @override
  Future<Either<String, List<CountryMovieEntity>>> getCountryMovie() async {
    try {
      final result = await remoteDatasource.getCountryMovie();
      // CountryMovieModel extends CountryMovieEntity nên có thể cast trực tiếp
      return Right(result.cast<CountryMovieEntity>());
    } on NetworkException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Hàm chính để lấy phim theo filter
  /// Thay thế cho tất cả các hàm filter riêng lẻ trước đây
  @override
  Future<Either<String, FillterMovieGenreEntity>> getMoviesByFilter(
    FillterMovieReq filterReq,
  ) async {
    try {
      final result = await remoteDatasource.getMoviesByFilter(filterReq);
      return Right(result.toEntity());
    } on NetworkException catch (e) {
      return Left(e.toString());
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }
}
