// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';

abstract class CountryMovieState extends Equatable {}

class CountryMovieInitial extends CountryMovieState {
  @override
  List<Object?> get props => throw UnimplementedError();
}
class CountryMovieLoading extends CountryMovieState {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class CountryMovieFalure extends CountryMovieState {
  final String? message;
  CountryMovieFalure({this.message});
  @override
  List<Object?> get props => [message];
  
}
class CountryMovieSuccess extends CountryMovieState {
  final List<CountryMovieEntity> countryMovie;
  CountryMovieSuccess({
    required this.countryMovie,
  });
  @override
  List<Object?> get props => [countryMovie];
}
