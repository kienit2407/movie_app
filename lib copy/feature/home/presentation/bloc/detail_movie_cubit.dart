import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/home/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/home/presentation/bloc/detail_movie_state.dart';

class DetailMovieCubit extends Cubit<DetailMovieState> {
  final GetDetailMovieUsecase getDetailMovieUsecase;

  DetailMovieCubit(this.getDetailMovieUsecase) : super(DetailMovieInitial());

  Future<void> getDetailMovie(String slug) async {
    emit(DetailMovieLoading());
    final data = await getDetailMovieUsecase(slug);
    data.fold(
      (error) {
        emit(DetailMovieFailure());
      },
      (detailMovieModel) {
        emit(DetailMovieSuccessed(detailMovieModel: detailMovieModel));
      },
    );
  }
}
