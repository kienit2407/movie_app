import 'package:flutter/foundation.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';

class AppUrl {
  AppUrl._();

  // ✅ Web: gọi qua Vercel proxy để né CORS
  // ✅ Mobile: gọi thẳng phimapi (không dính CORS)
  static final String baseUrl = kIsWeb ? '/api/' : 'https://phimapi.com/';

  static const baseUrlBe = 'https://localhost:8017';
  static const baseDomainImg = 'https://phimimg.com/';
  static const getLatestMovie = 'danh-sach/phim-moi-cap-nhat-v3';
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

  static String convertImageDirect(String imageUrl) =>
      '${kIsWeb ? "" : ""}https://phimapi.com/image.php?url=$imageUrl';

  static String convertVideoPlayerDirect(String videoUrl) =>
      'https://player.phimapi.com/player/?url=$videoUrl';

  static String convertImageAddition(String imageUrl) {
    if (imageUrl.startsWith('https://phimimg.com/') ||
        imageUrl.startsWith('http://phimimg.com/')) {
      return 'https://phimapi.com/image.php?url=$imageUrl';
    }
    return 'https://phimapi.com/image.php?url=$baseDomainImg$imageUrl';
  }
}
