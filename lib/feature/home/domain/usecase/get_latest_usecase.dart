import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetLatestUsecase implements UseCase <Either<String, List<ItemEntity>>, int>{
  @override
  Future<Either<String, List<ItemEntity>>> call({required int params}) async {
    final movies = await sl<MovieRepository> ().getLatestMovie(params);
    return movies;
    // return movies.map(
    //   (list) => list.where((e) => e.episodeCurrent == 'Full').toList()
    // );
  }
  
}