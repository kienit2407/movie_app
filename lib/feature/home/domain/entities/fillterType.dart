/// Enum để phân biệt loại filter khi gọi API
/// Mỗi loại tương ứng với 1 endpoint khác nhau trên server
enum Filltertype {
  /// Filter theo thể loại: /v1/api/the-loai/{slug}
  genre,

  /// Filter theo quốc gia: /v1/api/quoc-gia/{slug}
  country,

  /// Filter theo danh sách đề xuất: /v1/api/danh-sach/{slug}
  list,

  /// Filter theo năm: /v1/api/nam/{slug}
  year, chinaMovie,
}
