import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

class MiniPlayerManager extends ChangeNotifier {
  static final MiniPlayerManager _instance = MiniPlayerManager._internal();
  factory MiniPlayerManager() => _instance;
  MiniPlayerManager._internal();

  ChewieController? _chewieController;
  String? _movieName;
  String? _currentEpisode;
  VoidCallback? _onTap;
  Offset? _initialPos;

  ChewieController? get chewieController => _chewieController;
  String? get movieName => _movieName;
  String? get currentEpisode => _currentEpisode;
  VoidCallback? get onTap => _onTap;
  Offset? get initialPos => _initialPos;

  bool get isMiniPlayerActive => _chewieController != null;

  void showMiniPlayer({
    required ChewieController controller,
    required String movieName,
    String? currentEpisode,
    VoidCallback? onTap,
    Offset? initialPosition,
  }) {
    _chewieController = controller;
    _movieName = movieName;
    _currentEpisode = currentEpisode;
    _onTap = onTap;
    _initialPos = initialPosition;
    notifyListeners();
  }

  ChewieController? detachChewieController() {
    final c = _chewieController;
    _chewieController = null;
    _movieName = null;
    _currentEpisode = null;
    _onTap = null;
    _initialPos = null;
    notifyListeners();
    return c;
  }

  void disposeMiniPlayer() {
    final vp = _chewieController?.videoPlayerController;
    _chewieController?.pause();
    _chewieController?.dispose();
    vp?.dispose();

    _chewieController = null;
    _movieName = null;
    _currentEpisode = null;
    _onTap = null;
    _initialPos = null;
    notifyListeners();
  }

  void hideMiniPlayer() {
    _chewieController = null;
    _movieName = null;
    _currentEpisode = null;
    _onTap = null;
    _initialPos = null;
    notifyListeners();
  }
}
