import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetFillterGenreUsecase extends UseCase <Either<String, FillterMovieGenreEntity>, FillterMovieReq> {
  @override
  Future<Either<String, FillterMovieGenreEntity>> call({required FillterMovieReq params}) async {
    switch(params.fillterType) {
      case Filltertype.genre:
        return await sl<MovieRepository>().getFillterMovieGenre(params);

      case Filltertype.country: 
        return await sl<MovieRepository>().getFillterMovieCountry(params);

      case Filltertype.recomendation:
        return await sl<MovieRepository>().getRecomendedMovie(params);

      case Filltertype.koreaMovie:
        return await sl<MovieRepository>().getKoreaMovie();

      case Filltertype.chinaMovie:
        return await sl<MovieRepository>().getChinaMovie();

      case Filltertype.all:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
} 