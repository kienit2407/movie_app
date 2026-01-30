import 'package:movie_app/core/config/network/dio_client.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<MovieModel>> searchMovies(String keyword, int limit, int page);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient dioClient;

  SearchRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MovieModel>> searchMovies(String keyword, int limit, int page) async {
    try {
      final response = await dioClient.get(
        path: '/v1/api/tim-kiem',
        queryParameters: {
          'keyword': keyword,
          'limit': limit,
          'page': page,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        final items = data['items'] as List;
        
        final List<MovieModel> movies = [];
        for (var item in items) {
          try {
            movies.add(MovieModel.fromMap(item as Map<String, dynamic>));
          } catch (e) {
            print('Error parsing movie item: $e');
            print('Item data: $item');
            rethrow;
          }
        }
        return movies;
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print('Search API error: $e');
      throw Exception('Search API error: $e');
    }
  }
}
