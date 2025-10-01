import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/domain/usecase/get_country_movie.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_state.dart';

class CountryMovieCubit extends Cubit<CountryMovieState> {
  CountryMovieCubit() : super(CountryMovieInitial());

  Future<void> getCountryMovie() async {
    try {
      emit(CountryMovieLoading());
      final data = await sl<GetCountryMovieUsecase>().call();
      data.fold(
        (error) {
          emit(CountryMovieFalure(message: error));
        },
        (countryMovie) {
          emit(CountryMovieSuccess(countryMovie: countryMovie));
        },
      );
    } catch (e, stackTrace) {
      emit(CountryMovieFalure(message: e.toString()));
      print("Lỗi ở phần country $stackTrace");
    }
  }
}
