import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/home/data/models/new_movie_model.dart';

void main() {
  group('NewMovieModel.fromMap', () {
    test('parses the wrapped v1 movie-list response', () {
      final model = NewMovieModel.fromMap({
        'status': 'success',
        'data': {
          'items': [
            {
              'tmdb': {'vote_average': 6.8},
              'modified': {'time': '2026-07-29T07:09:42.861Z'},
              '_id': 'movie-id',
              'name': 'Kabushikigaisha Magi-Lumière SS2',
              'slug': 'kabushikigaisha-magi-lumiere-ss2',
              'origin_name': 'Magilumiere Magical Girls Inc. Season 2',
              'type': 'hoathinh',
              'thumb_url': 'uploads/movies/movie-thumb.webp',
              'poster_url': 'uploads/movies/movie-poster.webp',
              'sub_docquyen': false,
              'chieurap': false,
              'time': '24 phút/tập',
              'episode_current': 'Tập 4',
              'quality': 'FHD',
              'lang': 'Vietsub',
              'year': 2026,
              'category': [
                {'name': 'Hoạt Hình', 'slug': 'hoat-hinh', 'id': 'category-id'},
              ],
              'country': [
                {'name': 'Nhật Bản', 'slug': 'nhat-ban', 'id': 'country-id'},
              ],
            },
          ],
          'params': {
            'pagination': {
              'totalItems': 29481,
              'totalItemsPerPage': 24,
              'currentPage': 1,
              'totalPages': 1229,
            },
          },
          'APP_DOMAIN_CDN_IMAGE': 'https://phimimg.com',
        },
      });

      expect(model.items, hasLength(1));
      expect(model.items.single.quality, 'FHD');
      expect(model.items.single.episode_current, 'Tập 4');
      expect(
        model.items.single.poster_url,
        'https://phimimg.com/uploads/movies/movie-poster.webp',
      );
      expect(model.pagination.totalItems, 29481);
      expect(model.pagination.totalPages, 1229);
    });

    test('keeps parsing the legacy flat response', () {
      final model = NewMovieModel.fromMap({
        'items': [
          {
            'tmdb': {'vote_average': 7.5},
            'modified': {'time': '2026-07-29T07:09:42.861Z'},
            '_id': 'legacy-id',
            'name': 'Legacy movie',
            'slug': 'legacy-movie',
            'origin_name': 'Legacy Movie',
            'poster_url': 'https://phimimg.com/legacy-poster.webp',
            'thumb_url': 'https://phimimg.com/legacy-thumb.webp',
            'year': 2025,
          },
        ],
        'pagination': {
          'totalItems': 1,
          'totalItemsPerPage': 20,
          'currentPage': 1,
          'totalPages': 1,
        },
      });

      expect(model.items.single.slug, 'legacy-movie');
      expect(model.pagination.totalItems, 1);
    });
  });
}
