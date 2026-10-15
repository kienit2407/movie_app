import 'package:flutter/foundation.dart';
import 'package:movie_app/core/config/network/dio_client.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/domain/entities/search_movies_page.dart';

abstract class SearchRemoteDataSource {
  Future<SearchMoviesPage> browseMovies(
    String movieType,
    SearchFilterParams filters,
    int page,
  );

  Future<List<MovieModel>> searchMovies(
    String keyword,
    SearchFilterParams filters,
    int page,
  );
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final DioClient dioClient;

  SearchRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<SearchMoviesPage> browseMovies(
    String movieType,
    SearchFilterParams filters,
    int page,
  ) async {
    final query = filters.toQueryParameters(keyword: '', page: page)
      ..remove('keyword');
    final response = await dioClient.get(
      path: 'v1/api/danh-sach/$movieType',
      queryParameters: query,
    );
    final body = response.data;
    if (response.statusCode != 200 ||
        body is! Map ||
        (body['status'] != 'success' && body['status'] != true)) {
      throw Exception('Failed to load movie list');
    }

    final data = Map<String, dynamic>.from(body['data'] as Map);
    final imageDomain = data['APP_DOMAIN_CDN_IMAGE']?.toString();
    final movies = (data['items'] as List).map((item) {
      final movie = Map<String, dynamic>.from(item as Map);
      for (final field in ['poster_url', 'thumb_url']) {
        movie[field] = _resolveImageUrl(
          movie[field]?.toString() ?? '',
          imageDomain,
        );
      }
      return MovieModel.fromMap(movie);
    }).toList();
    final pagination = (data['params'] as Map?)?['pagination'] as Map?;
    final totalPages = int.tryParse('${pagination?['totalPages']}');
    final currentPage = int.tryParse('${pagination?['currentPage']}') ?? page;

    return SearchMoviesPage(
      movies: movies,
      hasMore:
          movies.isNotEmpty && (totalPages == null || currentPage < totalPages),
    );
  }

  String _resolveImageUrl(String rawUrl, String? imageDomain) {
    final url = rawUrl.trim();
    if (url.isEmpty ||
        url.startsWith('http://') ||
        url.startsWith('https://')) {
      return url;
    }
    if (url.startsWith('//')) return 'https:$url';
    final domain = imageDomain?.trim();
    final base = domain == null || domain.isEmpty
        ? 'https://phimimg.com'
        : domain;
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    final path = url.startsWith('/') ? url.substring(1) : url;
    return '$normalizedBase/$path';
  }

  @override
  Future<List<MovieModel>> searchMovies(
    String keyword,
    SearchFilterParams filters,
    int page,
  ) async {
    try {
      final response = await dioClient.get(
        path: 'v1/api/tim-kiem',
        queryParameters: filters.toQueryParameters(
          keyword: keyword,
          page: page,
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        final items = data['items'] as List;

        final List<MovieModel> movies = [];
        for (var item in items) {
          try {
            movies.add(MovieModel.fromMap(item as Map<String, dynamic>));
          } catch (e) {
            debugPrint('Error parsing movie item: $e');
            debugPrint('Item data: $item');
            rethrow;
          }
        }
        return movies;
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      debugPrint('Search API error: $e');
      throw Exception('Search API error: $e');
    }
  }
}
