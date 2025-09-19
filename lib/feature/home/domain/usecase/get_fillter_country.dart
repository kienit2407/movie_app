import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetFillterCountryUsecase extends UseCase <Either<String, FillterMovieGenreEntity>, FillterMovieReq> {
  @override
  Future<Either<String, FillterMovieGenreEntity>> call({required FillterMovieReq params}) async {
    if(params.typeList.isEmpty) {
      return Left('U not pick anything. Pls pick least one !');
    }
    return await sl<MovieRepository>().getFillterMovieCountry(params);
  }
  
} 