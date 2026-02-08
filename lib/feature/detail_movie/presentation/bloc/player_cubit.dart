import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_state.dart';

class PlayerCubit extends HydratedCubit<PlayerState> {
  PlayerCubit() : super(const PlayerInitialState());

  void setAutoPlayNextEpisode(bool value) {
    if (state is PlayerLoadedState) {
      emit(
        (state as PlayerLoadedState).copyWith(
          autoPlayNextEpisode: value,
        ),
      );
    }
  }

  void updateCurrentEpisode(String slug, int episodeIndex, int serverIndex) {
    emit(
      PlayerLoadedState(
        autoPlayNextEpisode: state is PlayerLoadedState 
            ? (state as PlayerLoadedState).autoPlayNextEpisode 
            : true,
        currentSlug: slug,
        currentEpisodeIndex: episodeIndex,
        currentServerIndex: serverIndex,
      ),
    );
  }

  @override
  PlayerState? fromJson(Map<String, dynamic> json) {
    if (json['autoPlayNextEpisode'] != null) {
      return PlayerLoadedState(
        autoPlayNextEpisode: json['autoPlayNextEpisode'] as bool,
        currentSlug: json['currentSlug'] as String?,
        currentEpisodeIndex: json['currentEpisodeIndex'] as int? ?? 0,
        currentServerIndex: json['currentServerIndex'] as int? ?? 0,
      );
    }
    return const PlayerInitialState();
  }

  @override
  Map<String, dynamic>? toJson(PlayerState state) {
    if (state is PlayerLoadedState) {
      return {
        'autoPlayNextEpisode': state.autoPlayNextEpisode,
        'currentSlug': state.currentSlug,
        'currentEpisodeIndex': state.currentEpisodeIndex,
        'currentServerIndex': state.currentServerIndex,
      };
    }
    return null;
  }
}
