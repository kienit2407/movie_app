import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/movie_sharing/movie_deep_link_service.dart';

void main() {
  test('maps a Liquid Phim movie link to its detail route', () {
    expect(
      MovieDeepLinkService.routeFromUri(
        Uri.parse('liquidphim://movie/phim-moi'),
      ),
      '/movie/phim-moi',
    );
  });

  test('maps the Liquid Phim HTTPS universal link to its detail route', () {
    expect(
      MovieDeepLinkService.routeFromUri(
        Uri.parse('https://movieapp-c3847.web.app/movie/phim-moi'),
      ),
      '/movie/phim-moi',
    );
  });

  test('ignores unrelated links', () {
    expect(
      MovieDeepLinkService.routeFromUri(Uri.parse('https://example.com/movie')),
      isNull,
    );
  });
}
