// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

abstract class FetchFillterState extends Equatable {
  const FetchFillterState();
  @override
  List<Object?> get props => [];
}

class FetchFillterInitial extends FetchFillterState {}

class FetchFillterLoading extends FetchFillterState {}

class FetchFillterLoaded extends FetchFillterState {
  final List<ItemEntity> items;
  final bool hasReachedMax;
  final int currentPage;
  final String titlePage;
  final bool isLoadingMore;

  const FetchFillterLoaded({
    this.items = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    required this.titlePage,
    this.isLoadingMore = false,
  });

  FetchFillterLoaded copyWith({
    List<ItemEntity>? items,
    bool? hasReachedMax,
    int? currentPage,
    String? titlePage,
    bool? isLoadingMore,
  }) {
    return FetchFillterLoaded(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      titlePage: titlePage ?? this.titlePage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    items,
    hasReachedMax,
    currentPage,
    titlePage,
    isLoadingMore,
  ];
}

class FetchFillterFailure extends FetchFillterState {
  final String message;

  const FetchFillterFailure({required this.message});
  @override
  List<Object?> get props => [message];
}
