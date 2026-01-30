import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetGenreMovieUsecase
    extends UseCaseLegacy<String, List<GenreMovieEntity>, NoParams> {
  final MovieRepository repository;

  GetGenreMovieUsecase(this.repository);

  @override
  Future<Either<String, List<GenreMovieEntity>>> call(NoParams params) async {
    return await repository.getGenreMovie();
  }
}
