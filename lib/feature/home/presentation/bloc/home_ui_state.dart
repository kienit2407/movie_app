import 'package:equatable/equatable.dart';

class HomeUiState extends Equatable {
  final int currentIndex;
  final double chipOpacity;
  final double chipOffset;
  final bool isSelectedGenre;
  final int carouselKeyCounter;
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  const HomeUiState({
    this.currentIndex = 0,
    this.chipOpacity = 1.0,
    this.chipOffset = 0.0,
    this.isSelectedGenre = false,
    this.carouselKeyCounter = 0,
    this.appName = '',
    this.packageName = '',
    this.version = '',
    this.buildNumber = '',
  });

  HomeUiState copyWith({
    int? currentIndex,
    double? chipOpacity,
    double? chipOffset,
    bool? isSelectedGenre,
    int? carouselKeyCounter,
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
  }) {
    return HomeUiState(
      currentIndex: currentIndex ?? this.currentIndex,
      chipOpacity: chipOpacity ?? this.chipOpacity,
      chipOffset: chipOffset ?? this.chipOffset,
      isSelectedGenre: isSelectedGenre ?? this.isSelectedGenre,
      carouselKeyCounter: carouselKeyCounter ?? this.carouselKeyCounter,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }

  @override
  List<Object?> get props => [
    currentIndex,
    chipOpacity,
    chipOffset,
    isSelectedGenre,
    carouselKeyCounter,
    appName,
    packageName,
    version,
    buildNumber,
  ];
}
