// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';

abstract class GenreState extends Equatable {}

class GenreMovieInitial extends GenreState {
  @override
  List<Object?> get props => throw UnimplementedError();
}
class GenreMovieLoading extends GenreState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class GenreMovieFalure extends GenreState {
  final String? message;
  GenreMovieFalure({this.message});
  @override
  List<Object?> get props => [message];
  
}
class GenreMovieSuccess extends GenreState {
  final List<GenreMovieEntity> genreMovie;
  GenreMovieSuccess({
    required this.genreMovie,
  });
  @override
  List<Object?> get props => [genreMovie];
}
