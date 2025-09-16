// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';

abstract class FetchFillterState extends Equatable {}

class FetchFillterInitial extends FetchFillterState{
  @override
  List<Object?> get props => [];
}
class FetchFillterLoading extends FetchFillterState{
  @override
  List<Object?> get props => [];
}
class FetchFillterLoadingMore extends FetchFillterState{
  @override
  List<Object?> get props => [];
}
class FetchFillterFailure extends FetchFillterState{

  final String message;

  FetchFillterFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
class FetchFillterSuccess extends FetchFillterState {
  final FillterMovieGenreEntity fillterMovieGenreEntity;
  final bool hasReachedMax;
  

  FetchFillterSuccess({
    required this.fillterMovieGenreEntity,
    this.hasReachedMax = true,
  });
  @override
  List<Object?> get props => [fillterMovieGenreEntity];
}
