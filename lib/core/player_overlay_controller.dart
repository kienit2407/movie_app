import 'package:flutter/foundation.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:video_player/video_player.dart';

enum PlayerOverlayTarget { expanded, mini }

/// Owns only the presentation/session state of the app-level player overlay.
/// The actual media controllers remain owned by [MoviePlayerPage].
class PlayerOverlayController extends ChangeNotifier {
  PlayerOverlayController();

  static final PlayerOverlayController instance = PlayerOverlayController();

  static const double minimizeThreshold = 0.35;
  static const double minimizeVelocity = 800;

  final ValueNotifier<double> progress = ValueNotifier<double>(0);
  final ValueNotifier<VideoPlayerController?> playbackController =
      ValueNotifier<VideoPlayerController?>(null);

  MoviePlayerArgs? _args;
  PlayerOverlayTarget _target = PlayerOverlayTarget.expanded;
  bool _isDragging = false;
  int _sessionId = 0;
  Object? _playbackOwner;

  MoviePlayerArgs? get args => _args;
  PlayerOverlayTarget get target => _target;
  bool get isDragging => _isDragging;
  bool get isVisible => _args != null;
  int get sessionId => _sessionId;
  bool get isMini =>
      isVisible &&
      !_isDragging &&
      _target == PlayerOverlayTarget.mini &&
      progress.value >= 0.999;

  void open(MoviePlayerArgs args) {
    final current = _args;
    final sameSession = current != null && _samePlayback(current, args);

    if (!sameSession) {
      _playbackOwner = null;
      playbackController.value = null;
      _args = args;
      _sessionId++;
      progress.value = 0;
    }

    _isDragging = false;
    _target = PlayerOverlayTarget.expanded;
    notifyListeners();
  }

  void beginDrag() {
    if (!isVisible || _isDragging) return;
    _isDragging = true;
    notifyListeners();
  }

  void updateDragDelta(double deltaY, double travelExtent) {
    if (!isVisible || !_isDragging || travelExtent <= 0) return;
    progress.value = (progress.value + deltaY / travelExtent).clamp(0.0, 1.0);
  }

  void endDrag({required double velocityY}) {
    if (!isVisible) return;

    final shouldMinimize =
        velocityY >= minimizeVelocity ||
        (velocityY > -minimizeVelocity && progress.value >= minimizeThreshold);
    _isDragging = false;
    _target = shouldMinimize
        ? PlayerOverlayTarget.mini
        : PlayerOverlayTarget.expanded;
    notifyListeners();
  }

  void cancelDrag() {
    if (!isVisible) return;
    _isDragging = false;
    _target = PlayerOverlayTarget.expanded;
    notifyListeners();
  }

  void minimize() {
    if (!isVisible) return;
    _isDragging = false;
    _target = PlayerOverlayTarget.mini;
    notifyListeners();
  }

  void expand() {
    if (!isVisible) return;
    _isDragging = false;
    _target = PlayerOverlayTarget.expanded;
    notifyListeners();
  }

  void close() {
    if (!isVisible) return;
    _args = null;
    _isDragging = false;
    _target = PlayerOverlayTarget.expanded;
    _playbackOwner = null;
    playbackController.value = null;
    progress.value = 0;
    notifyListeners();
  }

  void updatePlaybackIdentity({
    required String? episodeLink,
    required int episodeIndex,
    required String server,
    required int serverIndex,
  }) {
    final current = _args;
    if (current == null) return;
    _args = MoviePlayerArgs(
      current.slug,
      current.thumbnailUrl,
      episodeLink,
      episodeIndex,
      server,
      current.movieName,
      current.episodes,
      current.movie,
      initialServerIndex: serverIndex,
      initialEpisodeNo: current.initialEpisodeNo,
      initialEpisodeSlug: current.initialEpisodeSlug,
      initialServerName: current.initialServerName,
    );
  }

  void attachPlaybackController(
    VideoPlayerController controller, {
    required Object owner,
  }) {
    if (!isVisible) return;
    _playbackOwner = owner;
    playbackController.value = controller;
  }

  void detachPlaybackController({required Object owner}) {
    if (!identical(_playbackOwner, owner)) return;
    _playbackOwner = null;
    playbackController.value = null;
  }

  Future<void> togglePlayback() async {
    final controller = playbackController.value;
    if (controller == null) return;
    final value = controller.value;
    if (!value.isInitialized || value.isBuffering) return;

    if (value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
  }

  bool _samePlayback(MoviePlayerArgs a, MoviePlayerArgs b) {
    return a.slug == b.slug &&
        a.initialEpisodeLink == b.initialEpisodeLink &&
        a.initialEpisodeIndex == b.initialEpisodeIndex &&
        a.initialServerIndex == b.initialServerIndex;
  }

  @override
  void dispose() {
    progress.dispose();
    playbackController.dispose();
    super.dispose();
  }
}
