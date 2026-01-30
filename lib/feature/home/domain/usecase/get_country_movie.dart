import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

class GetCountryMovieUsecase
    extends UseCaseLegacy<String, List<CountryMovieEntity>, NoParams> {
  final MovieRepository repository;

  GetCountryMovieUsecase(this.repository);

  @override
  Future<Either<String, List<CountryMovieEntity>>> call(NoParams params) async {
    return await repository.getCountryMovie();
  }
}
