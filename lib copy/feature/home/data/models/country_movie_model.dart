// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';

class CountryMovieModel extends CountryMovieEntity {
  CountryMovieModel({
    required slug,
    required name,
  }) : super(slug: slug, name: name);
  

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'slug': slug,
      'name': name,
    };
  }

  factory CountryMovieModel.fromMap(Map<String, dynamic> map) {
    return CountryMovieModel(
      slug: map['slug'] as String,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CountryMovieModel.fromJson(String source) => CountryMovieModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
