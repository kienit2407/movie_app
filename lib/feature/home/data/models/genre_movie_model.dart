import 'dart:convert';

import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GenreMovieModel {
  final String name;
  final String slug;

  GenreMovieModel({
    required this.name,
    required this.slug,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'slug': slug,
    };
  }

  factory GenreMovieModel.fromMap(Map<String, dynamic> map) {
    return GenreMovieModel(
      name: map['name'] as String,
      slug: map['slug'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GenreMovieModel.fromJson(String source) => GenreMovieModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
extension GenreMovieModelConvert on GenreMovieModel {
  GenreMovieEntity toEntity () => GenreMovieEntity(name: name, slug: slug);
}