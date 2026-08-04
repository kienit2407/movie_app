import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:movie_app/core/ios_now_playing_service.dart';
import 'package:movie_app/core/ios_picture_in_picture_service.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/core/playback_wakelock.dart';

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
  static final ValueNotifier<bool> shouldRestorePlayer = ValueNotifier<bool>(
    false,
  );

  ChewieController? _chewieController;
  MiniPlayerLaunchData? _launch;
  Offset? _currentPos;
  Offset? _initialPos;

  ChewieController? _handoffController;
  MiniPlayerLaunchData? _handoffLaunch;
  Offset? _handoffPos;
  ChewieController? _miniPlaybackChewieController;
  VoidCallback? _miniPlaybackListener;
  DateTime? _lastNowPlayingUpdate;
  bool? _lastNowPlayingIsPlaying;

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

    _attachMiniPlaybackListener(controller);
    shouldRestorePlayer.value = false;
    isVisible.value = true;
    notifyListeners();
  }

  String _miniNowPlayingSubtitle() {
    final data = _launch;
    if (data == null) return '';

    final serverName = data.initialServer.trim();
    if (data.episodes.isEmpty ||
        data.initialServerIndex < 0 ||
        data.initialServerIndex >= data.episodes.length) {
      return serverName;
    }

    final episodes = data.episodes[data.initialServerIndex].server_data;
    if (data.initialEpisodeIndex < 0 ||
        data.initialEpisodeIndex >= episodes.length) {
      return serverName;
    }

    final episodeName = episodes[data.initialEpisodeIndex].name.trim();
    if (episodeName.isEmpty) return serverName;
    if (serverName.isEmpty) return episodeName;
    return '$episodeName - $serverName';
  }

  void _attachMiniPlaybackListener(ChewieController controller) {
    _removeMiniPlaybackListener();

    final videoController = controller.videoPlayerController;
    _miniPlaybackChewieController = controller;
    _miniPlaybackListener = () => _syncMiniPlaybackSideEffects();
    videoController.addListener(_miniPlaybackListener!);
    _syncMiniPlaybackSideEffects(force: true);
  }

  void _removeMiniPlaybackListener() {
    final listener = _miniPlaybackListener;
    final controller = _miniPlaybackChewieController;
    if (listener != null && controller != null) {
      try {
        controller.videoPlayerController.removeListener(listener);
      } catch (_) {}
    }
    _miniPlaybackListener = null;
    _miniPlaybackChewieController = null;
    _lastNowPlayingUpdate = null;
    _lastNowPlayingIsPlaying = null;
  }

  void _syncMiniPlaybackSideEffects({bool force = false}) {
    final controller = _chewieController;
    if (controller == null) return;

    final value = controller.videoPlayerController.value;
    final isPlaying = value.isInitialized && value.isPlaying;
    PlaybackWakelock.unawaitedSetEnabled(isPlaying);

    if (!IosNowPlayingService.isSupportedPlatform || !value.isInitialized) {
      return;
    }

    final now = DateTime.now();
    final shouldUpdate =
        force ||
        _lastNowPlayingIsPlaying != isPlaying ||
        _lastNowPlayingUpdate == null ||
        now.difference(_lastNowPlayingUpdate!) > const Duration(seconds: 1);
    if (!shouldUpdate) return;

    _lastNowPlayingUpdate = now;
    _lastNowPlayingIsPlaying = isPlaying;
    unawaited(
      IosNowPlayingService.update(
        title: _launch?.movieName ?? '',
        subtitle: _miniNowPlayingSubtitle(),
        duration: value.duration,
        position: value.position,
        isPlaying: isPlaying,
        assetUrl: _launch?.initialEpisodeLink,
      ),
    );
  }

  void updateMiniPosition(Offset p) {
    _currentPos = p;
    notifyListeners();
  }

  MiniDetachResult takeHandoff() {
    final res = MiniDetachResult(
      controller: _handoffController,
      launch: _handoffLaunch,
      pos: _handoffPos,
    );

    _handoffController = null;
    _handoffLaunch = null;
    _handoffPos = null;

    return res;
  }

  MiniDetachResult detachForOpen() {
    final c = _chewieController;
    final l = _launch;
    final p = _currentPos;
    _removeMiniPlaybackListener();

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

    return MiniDetachResult(controller: c, launch: l, pos: p);
  }

  void _safeDisposeController(ChewieController? controller) {
    if (controller == null) return;
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
    final oldMain = _chewieController;
    final oldHandoff = _handoffController;
    _removeMiniPlaybackListener();
    PlaybackWakelock.unawaitedSetEnabled(false);
    unawaited(IosNowPlayingService.clear());
    unawaited(IosPictureInPictureService.detach());

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
  }

  void hideMiniPlayer() {
    _removeMiniPlaybackListener();
    PlaybackWakelock.unawaitedSetEnabled(false);
    unawaited(IosNowPlayingService.clear());
    unawaited(IosPictureInPictureService.detach());
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
