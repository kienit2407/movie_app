import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

/// Abstract Repository - nằm ở Domain layer
/// Định nghĩa contract cho Data layer implement
abstract class MovieRepository {
  /// Lấy danh sách phim mới cập nhật
  Future<Either<String, List<ItemEntity>>> getLatestMovie(int page);

  /// Lấy chi tiết phim
  Future<Either<String, DetailMovieModel>> getDetailMovie(String slug);

  /// Lấy danh sách thể loại phim
  Future<Either<String, List<GenreMovieEntity>>> getGenreMovie();

  /// Lấy danh sách quốc gia
  Future<Either<String, List<CountryMovieEntity>>> getCountryMovie();

  /// Lấy danh sách phim theo filter (genre, country, list, year)
  /// Đây là hàm chính thay thế cho nhiều hàm riêng lẻ
  Future<Either<String, FillterMovieGenreEntity>> getMoviesByFilter(
    FillterMovieReq filterReq,
  );
}
