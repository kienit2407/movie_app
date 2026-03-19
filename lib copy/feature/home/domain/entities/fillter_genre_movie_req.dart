import 'package:movie_app/feature/home/domain/entities/fillterType.dart';

class FillterMovieReq {
  final String typeList;
  final String page;
  final String? sortField;
  final String? sortType;
  final String? sortLang;
  final String? year;
  final String? category;
  final String? country;
  final String? limit;
  final Filltertype fillterType;

  FillterMovieReq({
    required this.typeList,
    this.page = '1',
    this.sortField = '_id',
    this.sortType = 'desc',
    this.sortLang,
    this.year,
    this.country,
    this.category,
    this.limit = '21',
    required this.fillterType,
  });

  FillterMovieReq copyWith({
    String? typeList,
    String? page,
    String? sortField,
    String? sortType,
    String? sortLang,
    String? year,
    String? category,
    String? country,
    String? limit,
    Filltertype? fillterType,
  }) {
    return FillterMovieReq(
      typeList: typeList ?? this.typeList,
      page: page ?? this.page,
      sortField: sortField ?? this.sortField,
      sortType: sortType ?? this.sortType,
      sortLang: sortLang ?? this.sortLang,
      year: year ?? this.year,
      category: category ?? this.category,
      country: country ?? this.country,
      limit: limit ?? this.limit,
      fillterType: fillterType ?? this.fillterType,
    );
  }
}
