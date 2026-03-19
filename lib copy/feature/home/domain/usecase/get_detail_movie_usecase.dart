import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/data/models/detail_movie_model.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetDetailMovieUsecase
    extends UseCaseLegacy<String, DetailMovieModel, String> {
  final MovieRepository repository;

  GetDetailMovieUsecase(this.repository);

  @override
  Future<Either<String, DetailMovieModel>> call(String params) async {
    return await repository.getDetailMovie(params);
  }
}
