import 'package:movie_app/feature/home/domain/entities/fillterType.dart';

class AppUrl {
  AppUrl._();

  static const baseUrl = 'https://phimapi.com/';
  static const baseUrlBe = 'https://localhost:8017';
  static const baseDomainImg = 'https://phimimg.com/';
  static const getLatestMovie = 'danh-sach/phim-moi-cap-nhat-v3';
  static const getGenretMovie = 'the-loai';
  static const getCountryMovie = 'quoc-gia';
  static const postRefreshToken = 'auth/refresh-token';

  /// Tạo URL filter dựa trên loại filter
  /// Thay vì có nhiều hàm riêng lẻ, chỉ cần 1 hàm này
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
      'https://phimapi.com/image.php?url=$imageUrl';
  static String convertImageAddition(String imageUrl) =>
      'https://phimapi.com/image.php?url=$baseDomainImg$imageUrl';
}
