class AppUrl {
  AppUrl._();
  static const baseUrl = 'https://phimapi.com/';

  static const getLatestMovie = 'danh-sach/phim-moi-cap-nhat-v3';
  static String getDetailMovie (String slug) => 'phim/$slug';
  
  static String convertImageDirect (String imageUrl) => 'https://phimapi.com/image.php?url=$imageUrl';

}