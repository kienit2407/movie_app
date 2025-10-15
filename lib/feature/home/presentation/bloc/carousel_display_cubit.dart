import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/domain/usecase/get_latest_usecase.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_state.dart';

class CarouselDisplayCubit extends Cubit <CarouselDisplayState>{
  CarouselDisplayCubit() : super (CarouselInitial());

  Future<void> getLatestMovie () async {
    emit(CarouselLoading());
    final data = await sl<GetLatestUsecase>().call(params: 1);
    data.fold(
      (error){
        emit(CarouselFalure(message: error));
      }, 
      (latestMovie) {  
        emit(CarouselSuccess(latestMovie: latestMovie));
      }
    );
  }

}