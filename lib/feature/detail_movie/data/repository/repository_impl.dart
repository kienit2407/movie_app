import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errol/app_exception.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/data/source/movie_detail_datasource.dart';
import 'package:movie_app/feature/detail_movie/domain/repository/detail_movie_repo.dart';

class DetailMovieRepositoryImpl implements DetailMovieRepository {
  final MovieDetailDatasource remoteDatasource;

  DetailMovieRepositoryImpl(this.remoteDatasource);

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
}
