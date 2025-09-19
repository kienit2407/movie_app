// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:movie_app/feature/home/domain/entities/fillterType.dart';

class FillterMovieReq {
  final String typeList;
  final String page;
  final String? sortField;
  final String? sortType;
  final String? sortLang;
  final String? year;
  final String? category;
  final String? limit;
  final Filltertype fillterType;

  FillterMovieReq({
    required this.typeList,
    this.page = '1',
    this.sortField = '_id',
    this.sortType = 'desc', // giảm dần
    this.sortLang,
    this.year,
    this.category,
    this.limit = '21',
    this.fillterType = Filltertype.all,
  });

  // factory FillterMovieReq.forCountry({
  //   required String typeList,
  //   String page = '1',
  //   String? sortField = '_id',
  //   String? sortType = 'desc', // giảm dần
  //   String? limit = '21',
  //   String? sortLang,

  // }) {
  //   return FillterMovieReq(
  //     typeList: typeList,
  //     page: page,
  //     sortField: sortField,
  //     sortType: sortType,
  //     limit: limit,
  //   );
  // }
  // factory FillterMovieReq.forGenre({
  //   required String typeList,
  //   String page = '1',
  //   String? sortField = '_id',
  //   String? sortType = 'desc', // giảm dần
  //   String? limit = '21',
  // }) {
  //   return FillterMovieReq(
  //     typeList: typeList,
  //     page: page,
  //     sortField: sortField,
  //     sortType: sortType,
  //     limit: limit,
  //   );
  // }
  FillterMovieReq copyWith({
    String? typeList,
    String? page,
    String? sortField,
    String? sortType,
    String? sortLang,
    String? year,
    String? category,
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
      limit: limit ?? this.limit,
      fillterType: fillterType ?? this.fillterType,
    );
  }
}
