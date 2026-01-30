// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:movie_app/feature/home/data/models/new_movie_model.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';

class FillterGenreModel {
  final List<ItemModel>? items;
  final String titlePage;
  final ParamsModel params;

  FillterGenreModel({required this.items, required this.titlePage, required this.params});

  

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': (items ?? []).map((x) => x.toMap()).toList(),
      'titlePage': titlePage,
      'params': params.toMap(),
    };
  }

  factory FillterGenreModel.fromMap(Map<String, dynamic> map) {
    return FillterGenreModel(
      items: map['items'] != null ? List<ItemModel>.from((map['items'] as List<dynamic>).map<ItemModel?>((x) => ItemModel.fromMap(x as Map<String,dynamic>),),) : null,
      titlePage: map['titlePage'] as String,
      params: ParamsModel.fromMap(map['params'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory FillterGenreModel.fromJson(String source) => FillterGenreModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
extension FliterGenreModelConvert on FillterGenreModel {
  FillterMovieGenreEntity toEntity () {
    return FillterMovieGenreEntity(items: (items ?? []).map((e) => e.toEntity()).toList(), titlePage: titlePage, params: params.toEntity());
  }
}
class ParamsModel {
  final PaginationModel pagination;

  ParamsModel({required this.pagination});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pagination': pagination.toMap(),
    };
  }

  factory ParamsModel.fromMap(Map<String, dynamic> map) {
    return ParamsModel(
      pagination: PaginationModel.fromMap(map['pagination'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory ParamsModel.fromJson(String source) => ParamsModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
extension ParamsModelConvert on ParamsModel {
  ParamsEntity toEntity () {
    return ParamsEntity(pagination: pagination.toEntity());
  }
}
