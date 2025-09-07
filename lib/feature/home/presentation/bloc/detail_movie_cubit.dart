import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/home/domain/usecase/get_latest_usecase.dart';
import 'package:movie_app/feature/home/presentation/bloc/detail_movie_state.dart';
import 'package:movie_app/feature/home/presentation/bloc/latest_movie_state.dart';

class DetailMovieCubit extends Cubit <DetailMovieState>{
  DetailMovieCubit() : super (DetailMovieInitial());

  Future<void> getDetailMovie (String slug) async {
    final data = await sl<GetDetailMovieUsecase>().call(params: slug);
    emit(DetailMovieLoading());
    data.fold(
      (error){
        emit(DetailMovieFailure());
      }, 
      (detailMovieModel) {  
        emit(DetailMovieSuccessed(detailMovieModel: detailMovieModel));
      }
    );
  }

}