import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class MiniPlayerManager {
  static final MiniPlayerManager _instance = MiniPlayerManager._internal();
  factory MiniPlayerManager() => _instance;
  MiniPlayerManager._internal();

  ChewieController? _chewieController;
  String? _movieName;
  String? _currentEpisode;
  VoidCallback? _onTap;

  ChewieController? get chewieController => _chewieController;
  String? get movieName => _movieName;
  String? get currentEpisode => _currentEpisode;
  VoidCallback? get onTap => _onTap;

  void showMiniPlayer({
    required ChewieController controller,
    required String movieName,
    String? currentEpisode,
    VoidCallback? onTap,
  }) {
    _chewieController = controller;
    _movieName = movieName;
    _currentEpisode = currentEpisode;
    _onTap = onTap;
  }

  void hideMiniPlayer() {
    _chewieController = null;
    _movieName = null;
    _currentEpisode = null;
    _onTap = null;
  }

  bool get isMiniPlayerActive => _chewieController != null;
}
