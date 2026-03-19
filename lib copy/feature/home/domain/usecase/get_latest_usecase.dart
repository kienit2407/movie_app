import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetLatestUsecase extends UseCaseLegacy<String, List<ItemEntity>, int> {
  final MovieRepository repository;

  GetLatestUsecase(this.repository);

  @override
  Future<Either<String, List<ItemEntity>>> call(int params) async {
    final movies = await repository.getLatestMovie(params);
    return movies;
  }
}
