// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

abstract class LatestMovieState extends Equatable {}

class LatestMovieInitial implements LatestMovieState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool? get stringify => throw UnimplementedError();
}
class LatestMovieLoading implements LatestMovieState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();

  @override
  // TODO: implement stringify
  bool? get stringify => throw UnimplementedError();
}
class LatestMovieFalure implements LatestMovieState {
  final String? message;

  LatestMovieFalure({this.message});
  
  @override
  // TODO: implement props
  List<Object?> get props => [message];
  
  @override
  // TODO: implement stringify
  bool? get stringify => throw UnimplementedError();
}
class LatestMovieSuccess implements LatestMovieState {
  final List<ItemEntity> latestMovie;

  LatestMovieSuccess({
    required this.latestMovie});
    
      @override
      // TODO: implement props
      List<Object?> get props => [latestMovie];
    
      @override
      // TODO: implement stringify
      bool? get stringify => throw UnimplementedError();
}
