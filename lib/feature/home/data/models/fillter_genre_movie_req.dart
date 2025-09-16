// ignore_for_file: public_member_api_docs, sort_constructors_first
class FillterGenreMovieReq {
  final String typeList;
  final String page;
  final String? sortField;
  final String? sortType;
  final String? sortLang;
  final String? country;
  final String? year;
  final String? limit;

  FillterGenreMovieReq({
    required this.typeList,
    this.page = '1',
    this.sortField = '_id',
    this.sortType = 'desc', // giảm dần
    this.sortLang,
    this.country,
    this.year,
    this.limit = '21',
  });

  FillterGenreMovieReq copyWith({
    String? typeList,
    String? page,
    String? sortField,
    String? sortType,
    String? sortLang,
    String? country,
    String? year,
    String? limit,
  }) {
    return FillterGenreMovieReq(
      typeList: typeList ?? this.typeList,
      page: page ?? this.page,
      sortField: sortField ?? this.sortField,
      sortType: sortType ?? this.sortType,
      sortLang: sortLang ?? this.sortLang,
      country: country ?? this.country,
      year: year ?? this.year,
      limit: limit ?? this.limit,
    );
  }
}
