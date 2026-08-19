import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/movie_sharing/movie_share_service.dart';

void main() {
  test('creates a public HTTPS movie share URL', () {
    expect(
      MovieShareService.movieLink('phim-moi').toString(),
      'https://movieapp-c3847.web.app/movie/phim-moi',
    );
  });
}
