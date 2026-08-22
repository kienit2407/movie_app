import 'package:flutter/widgets.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/player_overlay_controller.dart';

extension PlayerOverlayLauncher on BuildContext {
  void openMoviePlayer(MoviePlayerArgs args) {
    PlayerOverlayController.instance.open(args, minimizeEnabled: false);
  }
}
