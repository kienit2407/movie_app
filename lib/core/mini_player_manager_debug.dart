import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

class MiniPlayerLaunchData {
  final String slug;
  final String movieName;
  final String? thumbnailUrl;
  final List<EpisodesModel> episodes;
  final MovieModel movie;
  final String? initialEpisodeLink;
  final int initialEpisodeIndex;
  final String initialServer;
  final int initialServerIndex;

  const MiniPlayerLaunchData({
    required this.slug,
    required this.movieName,
    this.thumbnailUrl,
    required this.episodes,
    required this.movie,
    required this.initialEpisodeLink,
    required this.initialEpisodeIndex,
    required this.initialServer,
    required this.initialServerIndex,
  });
}

class MiniDetachResult {
  final ChewieController? controller;
  final MiniPlayerLaunchData? launch;
  final Offset? pos;

  const MiniDetachResult({
    required this.controller,
    required this.launch,
    required this.pos,
  });
}

class MiniPlayerManager extends ChangeNotifier {
  VoidCallback? navigateToPlayerCallback;

  void triggerNavigateToPlayer() {
    navigateToPlayerCallback?.call();
  }
  static final MiniPlayerManager _instance = MiniPlayerManager._internal();
  factory MiniPlayerManager() => _instance;
  MiniPlayerManager._internal();

  static final ValueNotifier<bool> isVisible = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> shouldRestorePlayer = ValueNotifier<bool>(false);

  ChewieController? _chewieController;
  MiniPlayerLaunchData? _launch;
  Offset? _currentPos;
  Offset? _initialPos;

  ChewieController? _handoffController;
  MiniPlayerLaunchData? _handoffLaunch;
  Offset? _handoffPos;

  ChewieController? get chewieController => _chewieController;
  MiniPlayerLaunchData? get launch => _launch;
  Offset? get currentPos => _currentPos;
  Offset? get initialPos => _initialPos;

  ChewieController? get handoffController => _handoffController;
  MiniPlayerLaunchData? get handoffLaunch => _handoffLaunch;

  bool get shouldShowMini =>
      isVisible.value && _chewieController != null && _launch != null;

  bool get isMiniPlayerActive =>
      isVisible.value &&
      (_chewieController != null || _handoffController != null);

  void showMiniPlayer({
    required ChewieController controller,
    required MiniPlayerLaunchData launchData,
    Offset? initialPosition,
  }) {
    print('[MiniPlayerManager] showMiniPlayer called');
    print('[MiniPlayerManager] isVisible before: ${isVisible.value}');
    print('[MiniPlayerManager] _chewieController before: ${_chewieController != null}');
    
    _handoffController = null;
    _handoffLaunch = null;
    _handoffPos = null;

    _chewieController = controller;
    _launch = launchData;

    _initialPos = initialPosition;
    _currentPos = initialPosition;

    if (!controller.isPlaying) {
      controller.play();
    }

    shouldRestorePlayer.value = false;
    isVisible.value = true;
    notifyListeners();
    
    print('[MiniPlayerManager] isVisible after: ${isVisible.value}');
    print('[MiniPlayerManager] _chewieController after: ${_chewieController != null}');
  }

  void updateMiniPosition(Offset p) {
    _currentPos = p;
    notifyListeners();
  }

  MiniDetachResult takeHandoff() {
    print('[MiniPlayerManager] takeHandoff called');
    print('[MiniPlayerManager] _handoffController before: ${_handoffController != null}');
    
    final res = MiniDetachResult(
      controller: _handoffController,
      launch: _handoffLaunch,
      pos: _handoffPos,
    );

    _handoffController = null;
    _handoffLaunch = null;
    _handoffPos = null;

    print('[MiniPlayerManager] _handoffController after: ${_handoffController != null}');
    print('[MiniPlayerManager] returning controller: ${res.controller != null}');

    return res;
  }

  MiniDetachResult detachForOpen() {
    print('[MiniPlayerManager] detachForOpen called');
    print('[MiniPlayerManager] _chewieController before: ${_chewieController != null}');
    print('[MiniPlayerManager] _launch before: ${_launch != null}');
    
    final c = _chewieController;
    final l = _launch;
    final p = _currentPos;

    _handoffController = c;
    _handoffLaunch = l;
    _handoffPos = p;

    _chewieController = null;
    _launch = null;
    _initialPos = null;
    _currentPos = null;

    isVisible.value = false;
    shouldRestorePlayer.value = true;
    notifyListeners();
    
    print('[MiniPlayerManager] _handoffController after: ${_handoffController != null}');
    print('[MiniPlayerManager] isVisible after: ${isVisible.value}');

    return MiniDetachResult(controller: c, launch: l, pos: p);
  }

  void _safeDisposeController(ChewieController? controller) {
    if (controller == null) return;
    print('[MiniPlayerManager] _safeDisposeController called');
    try {
      controller.pause();
    } catch (_) {}
    try {
      controller.videoPlayerController.pause();
    } catch (_) {}
    try {
      controller.dispose();
    } catch (_) {}
  }

  void disposeMiniPlayer({bool notify = true}) {
    print('[MiniPlayerManager] disposeMiniPlayer called');
    print('[MiniPlayerManager] isVisible before: ${isVisible.value}');
    
    final oldMain = _chewieController;
    final oldHandoff = _handoffController;

    _chewieController = null;
    _launch = null;
    _initialPos = null;
    _currentPos = null;

    _handoffController = null;
    _handoffLaunch = null;
    _handoffPos = null;

    isVisible.value = false;
    shouldRestorePlayer.value = false;
    
    if (notify) {
      Future.microtask(notifyListeners);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeDisposeController(oldMain);
      _safeDisposeController(oldHandoff);
    });
    
    print('[MiniPlayerManager] isVisible after: ${isVisible.value}');
  }

  void hideMiniPlayer() {
    _chewieController = null;
    _launch = null;
    _initialPos = null;
    _currentPos = null;

    _handoffController = null;
    _handoffLaunch = null;
    _handoffPos = null;

    isVisible.value = false;
    shouldRestorePlayer.value = false;
    
    Future.microtask(notifyListeners);
  }

  void clearRestoreFlag() {
    shouldRestorePlayer.value = false;
  }

  static void dismissMiniPlayer() {
    _instance.disposeMiniPlayer(notify: true);
  }
}
