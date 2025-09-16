import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetGenreMovieUsecase implements UseCase <Either<String, List<GenreMovieEntity>>, dynamic>{
  @override
  Future<Either<String, List<GenreMovieEntity>>> call({params}) async {
    return await sl<MovieRepository> ().getGenreMovie();
  }
}