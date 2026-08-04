import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/network/dio_client.dart';
import 'package:movie_app/core/errol/app_exception.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

/// Abstract class định nghĩa các phương thức giao tiếp với API
abstract class MovieDetailDatasource {
  /// Lấy chi tiết phim theo slug
  Future<DetailMovieModel> getDetailMovie(String slug);
}

class MovieDetailDatasourceImpl implements MovieDetailDatasource {
  final DioClient dioClient;

  MovieDetailDatasourceImpl({required this.dioClient});

  @override
  Future<DetailMovieModel> getDetailMovie(String slug) async {
    try {
      final response = await dioClient.get(path: AppUrl.getDetailMovie(slug));
      if (_isSuccessResponse(response.data)) {
        try {
          return DetailMovieModel.fromMap(response.data);
        } catch (e) {
          print('Error parsing movie detail: $e');
          print('Response data: ${response.data}');
          rethrow;
        }
      } else {
        throw ServerException('Failed to load movie detail');
      }
    } catch (e) {
      rethrow;
    }
  }

  bool _isSuccessResponse(dynamic data) {
    if (data is! Map) return false;
    if (data['status'] == true) return true;
    if (data['status'] == 'success') return true;
    return false;
  }
}
