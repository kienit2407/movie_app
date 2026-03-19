import 'package:dartz/dartz.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';

/// UseCase duy nhất để lấy phim theo filter
/// Thay thế cho GetFillterGenreUsecase, GetFillterCountryUsecase, etc.
///
/// Theo Clean Architecture:
/// - UseCase chỉ nên làm 1 việc duy nhất
/// - Nhưng nếu API cùng pattern, cùng response -> nên gộp thành 1 UseCase
/// - Phân biệt bằng params (FillterMovieReq.fillterType)
class GetMoviesByFilterUsecase
    extends UseCaseLegacy<String, FillterMovieGenreEntity, FillterMovieReq> {
  final MovieRepository repository;

  GetMoviesByFilterUsecase(this.repository);

  @override
  Future<Either<String, FillterMovieGenreEntity>> call(
    FillterMovieReq params,
  ) async {
    return await repository.getMoviesByFilter(params);
  }
}
