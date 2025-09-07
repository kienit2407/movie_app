import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/data/models/detail_movie_model.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetDetailMovieUsecase implements UseCase <Either<String, DetailMovieModel>, String>{
  @override
  Future<Either<String, DetailMovieModel>> call({required String params}) async {
    return await sl<MovieRepository> ().getDetailMovie(params);
  }
}