import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/home/presentation/bloc/home_ui_state.dart';

class HomeUiCubit extends Cubit<HomeUiState> {
  HomeUiCubit() : super(const HomeUiState());

  void setPackageInfo({
    required String appName,
    required String packageName,
    required String version,
    required String buildNumber,
  }) {
    emit(
      state.copyWith(
        appName: appName,
        packageName: packageName,
        version: version,
        buildNumber: buildNumber,
      ),
    );
  }

  void bumpCarouselKeyCounter() {
    emit(state.copyWith(carouselKeyCounter: state.carouselKeyCounter + 1));
  }

  void setCurrentIndex(int index) {
    if (state.currentIndex == index) return;
    emit(state.copyWith(currentIndex: index));
  }

  void setSelectedGenre(bool isSelected) {
    if (state.isSelectedGenre == isSelected) return;
    emit(state.copyWith(isSelectedGenre: isSelected));
  }
}
