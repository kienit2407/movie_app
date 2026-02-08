import 'package:equatable/equatable.dart';

abstract class PlayerState extends Equatable {
  const PlayerState();
  
  @override
  List<Object?> get props => [];
}

class PlayerInitialState extends PlayerState {
  const PlayerInitialState();
}

class PlayerLoadedState extends PlayerState {
  final bool autoPlayNextEpisode;
  final String? currentSlug;
  final int currentEpisodeIndex;
  final int currentServerIndex;

  const PlayerLoadedState({
    this.autoPlayNextEpisode = true,
    this.currentSlug,
    this.currentEpisodeIndex = 0,
    this.currentServerIndex = 0,
  });

  @override
  List<Object?> get props => [
    autoPlayNextEpisode,
    currentSlug,
    currentEpisodeIndex,
    currentServerIndex,
  ];

  PlayerLoadedState copyWith({
    bool? autoPlayNextEpisode,
    String? currentSlug,
    int? currentEpisodeIndex,
    int? currentServerIndex,
  }) {
    return PlayerLoadedState(
      autoPlayNextEpisode: autoPlayNextEpisode ?? this.autoPlayNextEpisode,
      currentSlug: currentSlug ?? this.currentSlug,
      currentEpisodeIndex: currentEpisodeIndex ?? this.currentEpisodeIndex,
      currentServerIndex: currentServerIndex ?? this.currentServerIndex,
    );
  }
}
