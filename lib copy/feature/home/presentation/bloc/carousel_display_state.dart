// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

abstract class CarouselDisplayState extends Equatable {}

class CarouselInitial extends CarouselDisplayState {
  @override
  List<Object?> get props => [];
}

class CarouselLoading extends CarouselDisplayState {
  @override
  List<Object?> get props => [];
}

class CarouselFalure extends CarouselDisplayState {
  final String? message;

  CarouselFalure({this.message});

  @override
  List<Object?> get props => [message];
}

class CarouselSuccess extends
 CarouselDisplayState {
  final List<ItemEntity> latestMovie;

  CarouselSuccess({required this.latestMovie});

  @override
  List<Object?> get props => [latestMovie];
}
