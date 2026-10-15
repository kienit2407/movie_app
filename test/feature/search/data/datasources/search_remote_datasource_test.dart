import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/config/network/dio_client.dart';
import 'package:movie_app/feature/search/data/datasources/search_remote_datasource.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';

void main() {
  test(
    'browses the list endpoint with filters and resolves CDN images',
    () async {
      final client = _FakeDioClient();
      final source = SearchRemoteDataSourceImpl(dioClient: client);

      final result = await source.browseMovies(
        'phim-bo',
        const SearchFilterParams(country: 'han-quoc'),
        1,
      );

      expect(client.path, 'v1/api/danh-sach/phim-bo');
      expect(client.query!['page'], 1);
      expect(client.query!['country'], 'han-quoc');
      expect(client.query, isNot(contains('keyword')));
      expect(
        result.movies.single.poster_url,
        'https://cdn.example/uploads/poster.jpg',
      );
      expect(
        result.movies.single.thumb_url,
        'https://images.example/thumb.jpg',
      );
      // Actual API pagination takes precedence over the requested limit.
      expect(result.hasMore, isTrue);

      client.currentPage = 2;
      final last = await source.browseMovies(
        'phim-bo',
        SearchFilterParams.defaults,
        2,
      );
      expect(last.hasMore, isFalse);
    },
  );
}

class _FakeDioClient implements DioClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  String? path;
  Map<String, dynamic>? query;
  int currentPage = 1;

  @override
  Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? option,
    bool retryOnFailure = true,
  }) async {
    this.path = path;
    query = queryParameters;
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'status': 'success',
        'data': {
          'APP_DOMAIN_CDN_IMAGE': 'https://cdn.example',
          'items': [
            {
              'slug': 'example',
              'poster_url': '/uploads/poster.jpg',
              'thumb_url': 'https://images.example/thumb.jpg',
            },
          ],
          'params': {
            'pagination': {'currentPage': currentPage, 'totalPages': 2},
          },
        },
      },
    );
  }
}
