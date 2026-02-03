import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/network/dio_client.dart';
import 'package:movie_app/core/errol/app_exception.dart';
import 'package:movie_app/feature/home/data/models/country_movie_model.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/data/models/fillter_genre_model.dart';
import 'package:movie_app/feature/home/data/models/genre_movie_model.dart';
import 'package:movie_app/feature/home/data/models/new_movie_model.dart';

/// Abstract class định nghĩa các phương thức giao tiếp với API
/// Tuân thủ Interface Segregation Principle - chỉ định nghĩa những gì cần thiết
abstract class MovieRemoteDatasource {
  /// Lấy danh sách phim mới cập nhật
  Future<NewMovieModel> getLatestMovie(int page);

  /// Lấy chi tiết phim theo slug
  Future<DetailMovieModel> getDetailMovie(String slug);

  /// Lấy danh sách thể loại phim
  Future<List<GenreMovieModel>> getGenreMovie();

  /// Lấy danh sách quốc gia
  Future<List<CountryMovieModel>> getCountryMovie();

  /// Lấy danh sách phim theo filter (genre, country, list, year)
  /// Đây là hàm chính thay thế cho nhiều hàm riêng lẻ trước đó
  Future<FillterGenreModel> getMoviesByFilter(FillterMovieReq filterReq);
}

class MovieRemoteDatasourceImpl implements MovieRemoteDatasource {
  final DioClient dioClient;

  MovieRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<NewMovieModel> getLatestMovie(int page) async {
    try {
      final response = await dioClient.get(
        path: AppUrl.getLatestMovie,
        queryParameters: {'page': page, 'limit': 20},
      );
      if (response.data['status'] == true && response.data['msg'] == 'done') {
        return NewMovieModel.fromMap(response.data);
      } else {
        throw ServerException('Failed to load latest movies');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DetailMovieModel> getDetailMovie(String slug) async {
    try {
      final response = await dioClient.get(path: AppUrl.getDetailMovie(slug));
      if (response.data['status'] == true && response.data['msg'] == 'done') {
        return DetailMovieModel.fromMap(response.data);
      } else {
        throw ServerException('Failed to load movie detail');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<GenreMovieModel>> getGenreMovie() async {
    try {
      final response = await dioClient.get(path: AppUrl.getGenretMovie);
      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((e) => GenreMovieModel.fromMap(e))
            .toList();
      } else {
        throw ServerException('Failed to load genres');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CountryMovieModel>> getCountryMovie() async {
    try {
      final response = await dioClient.get(path: AppUrl.getCountryMovie);
      return (response.data as List<dynamic>)
          .map((e) => CountryMovieModel.fromMap(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Hàm chính để lấy danh sách phim theo filter
  /// Thay thế cho các hàm: getFillterMovieGenre, getFillterMovieCountry,
  /// getRecommendedMovie, getYearMovie, getKoreaMovie, getChinaMovie, etc.
  @override
  Future<FillterGenreModel> getMoviesByFilter(FillterMovieReq filterReq) async {
    try {
      // Tạo URL dựa trên loại filter
      final path = AppUrl.getFilterUrl(
        filterReq.fillterType,
        filterReq.typeList,
      );

      // Tạo query parameters
      final queryParams = <String, dynamic>{
        'page': filterReq.page,
        'limit': filterReq.limit ?? '21',
      };

      // Thêm sort params nếu có
      if (filterReq.sortField != null) {
        queryParams['sort_field'] = filterReq.sortField;
      }
      if (filterReq.sortType != null) {
        queryParams['sort_type'] = filterReq.sortType;
      }
      if (filterReq.sortLang != null) {
        queryParams['sort_lang'] = filterReq.sortLang;
      }

      final response = await dioClient.get(
        path: path,
        queryParameters: queryParams,
      );

      // Xử lý response - API có thể trả về status khác nhau
      final data = response.data;
      if (_isSuccessResponse(data)) {
        return FillterGenreModel.fromMap(data['data']);
      } else {
        throw ServerException('Failed to load movies');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Kiểm tra response có success hay không
  /// API có thể trả về status: true hoặc status: 'success'
  bool _isSuccessResponse(dynamic data) {
    if (data['status'] == true && data['msg'] == 'done') return true;
    if (data['status'] == 'success') return true;
    if (data['status'] == true) return true;
    return false;
  }
}
