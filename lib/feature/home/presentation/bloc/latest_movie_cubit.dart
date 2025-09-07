import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/domain/usecase/get_latest_usecase.dart';
import 'package:movie_app/feature/home/presentation/bloc/latest_movie_state.dart';

class LatestMovieCubit extends Cubit <LatestMovieState>{
  LatestMovieCubit() : super (LatestMovieInitial());

  Future<void> getLatestMovie () async {
    final data = await sl<GetLatestUsecase>().call(params: 1);
    emit(LatestMovieLoading());

    data.fold(
      (error){
        emit(LatestMovieFalure(message: error));
      }, 
      (latestMovie) {  
        emit(LatestMovieSuccess(latestMovie: latestMovie));
      }
    );
  }

}