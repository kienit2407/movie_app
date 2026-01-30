import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

abstract class DetailMovieState extends Equatable{}

class DetailMovieInitial extends DetailMovieState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
class DetailMovieLoading extends DetailMovieState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
class DetailMovieSuccessed extends DetailMovieState {
  final DetailMovieModel detailMovieModel;

  DetailMovieSuccessed({required this.detailMovieModel});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
class DetailMovieFailure extends DetailMovieState {
  final String? message;

  DetailMovieFailure({this.message});
  @override
  // TODO: implement props
  List<Object?> get props => [message];
}