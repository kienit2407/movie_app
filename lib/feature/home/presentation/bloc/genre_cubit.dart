import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/domain/usecase/get_genre_movie.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_state.dart';

class GenreCubit extends Cubit <GenreState>{
  GenreCubit() : super (GenreMovieInitial());

  Future<void> getGenreMovie () async {
    emit(GenreMovieLoading());
    final data = await sl<GetGenreMovieUsecase>().call();
    data.fold(
      (error){
        emit(GenreMovieFalure(message: error));
      }, 
      (genreMovie) {  
        emit(GenreMovieSuccess(genreMovie: genreMovie));
      }
    );
  }

}