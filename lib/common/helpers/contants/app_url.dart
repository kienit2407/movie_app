import 'package:flutter/foundation.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';

class AppUrl {
  AppUrl._();

  // ✅ Web: gọi qua Vercel proxy để né CORS
  // ✅ Mobile: gọi thẳng phimapi (không dính CORS)
  static final String baseUrl = kIsWeb ? '/api/' : 'https://phimapi.com/';

  static const baseUrlBe = 'https://localhost:8017';
  static const getLatestMovie = '/v1/api/danh-sach';
  static const getGenretMovie = 'the-loai';
  static const getCountryMovie = 'quoc-gia';
  static const postRefreshToken = 'auth/refresh-token';

  static String getFilterUrl(Filltertype filterType, String slug) {
    switch (filterType) {
      case Filltertype.genre:
        return 'v1/api/the-loai/$slug';
      case Filltertype.country:
        return 'v1/api/quoc-gia/$slug';
      case Filltertype.list:
        return 'v1/api/danh-sach/$slug';
      case Filltertype.year:
        return 'v1/api/nam/$slug';
      case Filltertype.chinaMovie:
        return 'v1/api/quoc-gia/$slug';
    }
  }

  static String getDetailMovie(String slug) => 'phim/$slug';

  static String convertVideoPlayerDirect(String videoUrl) =>
      'https://player.phimapi.com/player/?url=$videoUrl';
}
