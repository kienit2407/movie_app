// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/usecase/get_movies_by_filter_usecase.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';

class FetchFillterCubit extends Cubit<FetchFillterState> {
  final GetMoviesByFilterUsecase getMoviesByFilterUsecase;

  FetchFillterCubit({required this.getMoviesByFilterUsecase})
    : super(FetchFillterInitial());

  Future<void> fetchMovies(
    FillterMovieReq fillterGenreMovieReq, {
    bool isLoadMore = false,
  }) async {
    if (state is FetchFillterLoaded) {
      final loadedState = state as FetchFillterLoaded;
      if (isLoadMore &&
          (loadedState.isLoadingMore || loadedState.hasReachedMax)) {
        return;
      }
    }

    if (!isLoadMore) {
      emit(FetchFillterLoading());
    } else {
      final currentState = state as FetchFillterLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    }

    final int pageToFetch = isLoadMore
        ? (state as FetchFillterLoaded).currentPage + 1
        : 1;

    final result = await getMoviesByFilterUsecase(
      fillterGenreMovieReq.copyWith(page: pageToFetch.toString()),
    );

    result.fold(
      (l) {
        if (isLoadMore) {
          final currentState = state as FetchFillterLoaded;
          emit(currentState.copyWith(isLoadingMore: false));
        } else {
          emit(FetchFillterFailure(message: l.toString()));
        }
      },
      (data) {
        final newItems = data.items;
        // Assuming if we get fewer items than limit (default 21 usually), we reached max
        // Or if list is empty
        final isMax = newItems.isEmpty;

        if (isLoadMore) {
          final currentState = state as FetchFillterLoaded;
          emit(
            currentState.copyWith(
              items: List.of(currentState.items)..addAll(newItems),
              hasReachedMax: isMax,
              currentPage: pageToFetch,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(
            FetchFillterLoaded(
              items: newItems,
              hasReachedMax: isMax,
              currentPage: pageToFetch,
              titlePage: data.titlePage,
            ),
          );
        }
      },
    );
  }
}
