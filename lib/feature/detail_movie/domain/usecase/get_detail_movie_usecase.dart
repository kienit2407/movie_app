import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/domain/repository/detail_movie_repo.dart';

class GetDetailMovieUsecase
    extends UseCaseLegacy<String, DetailMovieModel, String> {
  final DetailMovieRepository repository;

  GetDetailMovieUsecase(this.repository);

  @override
  Future<Either<String, DetailMovieModel>> call(String params) async {
    return await repository.getDetailMovie(params);
  }
}
