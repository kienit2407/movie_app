import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/usecase/use_case.dart';
import 'package:movie_app/feature/home/domain/usecase/get_genre_movie.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_state.dart';

class GenreCubit extends Cubit<GenreState> {
  final GetGenreMovieUsecase getGenreMovieUsecase;

  GenreCubit(this.getGenreMovieUsecase) : super(GenreMovieInitial());

  Future<void> getGenreMovie() async {
    emit(GenreMovieLoading());
    final data = await getGenreMovieUsecase(const NoParams());
    data.fold(
      (error) {
        emit(GenreMovieFalure(message: error));
      },
      (genreMovie) {
        emit(GenreMovieSuccess(genreMovie: genreMovie));
      },
    );
  }
}
