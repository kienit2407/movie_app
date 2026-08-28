import 'package:equatable/equatable.dart';

class HomeUiState extends Equatable {
  final int currentIndex;
  final bool isSelectedGenre;
  final int carouselKeyCounter;
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  const HomeUiState({
    this.currentIndex = 0,
    this.isSelectedGenre = false,
    this.carouselKeyCounter = 0,
    this.appName = '',
    this.packageName = '',
    this.version = '',
    this.buildNumber = '',
  });

  HomeUiState copyWith({
    int? currentIndex,
    bool? isSelectedGenre,
    int? carouselKeyCounter,
    String? appName,
    String? packageName,
    String? version,
    String? buildNumber,
  }) {
    return HomeUiState(
      currentIndex: currentIndex ?? this.currentIndex,
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
    isSelectedGenre,
    carouselKeyCounter,
    appName,
    packageName,
    version,
    buildNumber,
  ];
}
