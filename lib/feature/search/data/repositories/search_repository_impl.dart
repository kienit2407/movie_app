import 'package:dartz/dartz.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/data/datasources/search_remote_datasource.dart';
import 'package:movie_app/feature/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<MovieModel>>> searchMovies(String keyword, int limit, int page) async {
    try {
      final result = await remoteDataSource.searchMovies(keyword, limit, page);
      return Right(result);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
