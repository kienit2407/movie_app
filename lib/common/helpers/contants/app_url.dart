
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppUrl {
  AppUrl._();
  static const baseUrl = 'https://phimapi.com/';
  static const baseUrlBe = 'https://localhost:8017';
  static const baseDomainImg = 'https://phimimg.com/';
  static const getLatestMovie = 'danh-sach/phim-moi-cap-nhat-v3';
  static const getGenretMovie = 'the-loai';
  static const getCountryMovie = 'quoc-gia';
  static const postRefreshToken = 'auth/refresh-token';
  
  static String getFillterMovieGenre (String typeList) => 'v1/api/the-loai/$typeList';
  static String getFillterMovieCountry (String typeList) => 'v1/api/quoc-gia/$typeList';
  static String getFillterRecomended (String typeList) => 'v1/api/danh-sach/$typeList';
  static String getDetailMovie (String slug) => 'phim/$slug';
  static String convertImageDirect (String imageUrl) => 'https://phimapi.com/image.php?url=$imageUrl';
  static String convertImageAddition (String imageUrl) => 'https://phimapi.com/image.php?url=$baseDomainImg$imageUrl';

}