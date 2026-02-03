import 'dart:async';
import 'dart:ui';
import 'package:movie_app/core/config/utils/episode_drawer.dart';
import 'package:movie_app/core/config/utils/support_rotate_screen.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lottie/lottie.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/cover_map.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/feature/home/presentation/widgets/polk_effect.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/mini_player_manager.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/common/helpers/watch_progress_storage.dart';

enum SeekDirection { forward, backward }

class MoviePlayerPage extends StatefulWidget {
  final String slug;
  final String movieName;
  final String? thumbnailUrl;
  final List<EpisodesModel> episodes;
  final MovieModel movie;
  final String? initialEpisodeLink;
  final int initialEpisodeIndex;
  final String initialServer;
  final int initialServerIndex;

  const MoviePlayerPage({
    super.key,
    required this.slug,
    required this.movieName,
    this.thumbnailUrl,
    required this.episodes,
    this.initialEpisodeLink,
    this.initialEpisodeIndex = 0,
    this.initialServer = 'Server 1',
    required this.movie,
    required this.initialServerIndex,
  });

  @override
  State<MoviePlayerPage> createState() => _MoviePlayerPageState();
}

class _MoviePlayerPageState extends State<MoviePlayerPage>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _currentEpisodeLink;
  int _currentEpisodeIndex = 0;
  String _currentServer = '';
  bool _isFullscreen = false;
  double _videoHeight = 0;
  double _minVideoHeight = 0;
  double _maxVideoHeight = 0;
  double _initialDragY = 0;
  double _initialHeight = 0;
  bool _isDragging = false;
  bool _showControls = false;
  bool _isScrubbing = false;
  bool _isExpanded = false;
  Duration? _lastPosition;
  int _selectedServerIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollMovie = ScrollController();
  double _scrubValue = 0.0;
  int _seekCount = 0;
  final int _seekStepSeconds = 10;
  static const double _seekbarHitHeight = 24;
  static const double _seekbarVisualHeight = 8;
  static const double _thumbRadius = 6;
  final DraggableScrollableController _panelCtrl =
      DraggableScrollableController();
  static const double _panelMin = 0.18;
  static const double _panelMax = 0.65;
  double _dragDy = 0;
  double _miniDragDy = 0;
  double _miniDragT = 0.0;
  bool _isMinifyAnimating = false;
  late final AnimationController _minifyCtrl;
  static const double _panelAmbientH = 26;
  bool _showSeekOverlay = false;
  SeekDirection? _seekDir;
  Timer? _hideControlsTimer;
  Timer? _seekOverlayTimer;
  Timer? _saveProgressTimer;
  DateTime? _lastSeekTapTime;
  late final AnimationController _arrowCtrl;
  final MiniPlayerManager _miniPlayerManager = MiniPlayerManager();
  final WatchProgressStorage _watchProgressStorage = WatchProgressStorage();
  final TextEditingController _searchController = TextEditingController();
  bool _isExpandInfor = false;
  bool _isInMiniMode = false;
  bool _enteringMiniPlayer = false;
  @override
  void initState() {
    super.initState();

    final handoffController = _miniPlayerManager.handoffController;
    final handoffLaunch = _miniPlayerManager.handoffLaunch;

    final isOpeningFromMiniTap =
        handoffController != null && handoffLaunch != null;

    // Chỉ dispose mini cũ khi KHÔNG phải restore từ mini
    if (!isOpeningFromMiniTap && MiniPlayerManager.isVisible.value) {
      final existingSlug = _miniPlayerManager.launch?.slug;
      if (existingSlug != null && existingSlug != widget.slug) {
        _miniPlayerManager.disposeMiniPlayer(); // KHÔNG notify:false
      }
    }

    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _minifyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _selectedServerIndex = widget.initialServerIndex;
    _currentEpisodeIndex = widget.initialEpisodeIndex;
    _currentServer = widget.initialServer;

    if (handoffController != null && handoffLaunch != null) {
      _miniPlayerManager.takeHandoff();

      if (mounted) {
        setState(() {
          _chewieController = handoffController;
          _videoPlayerController = handoffController.videoPlayerController;
          _currentEpisodeLink = handoffLaunch.initialEpisodeLink;
          _currentEpisodeIndex = handoffLaunch.initialEpisodeIndex;
          _currentServer = handoffLaunch.initialServer;
          _selectedServerIndex = handoffLaunch.initialServerIndex;
        });

        if (!handoffController.isPlaying) {
          handoffController.play();
        }
      }
    } else {
      if (MiniPlayerManager.isVisible.value) {
        MiniPlayerManager.dismissMiniPlayer();
      }

      if (widget.initialEpisodeLink != null &&
          widget.initialEpisodeLink!.isNotEmpty) {
        _currentEpisodeLink = widget.initialEpisodeLink;
        _initializePlayer(widget.initialEpisodeLink!);
      } else if (widget.episodes.isNotEmpty) {
        _playEpisode(widget.initialEpisodeIndex, widget.episodes.first);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        _minVideoHeight = screenWidth * (9 / 16);
        _maxVideoHeight = screenHeight;
        _videoHeight = _minVideoHeight;
      });
    });

    // Cho phép auto-rotate trong player
    SupportRotateScreen.allowAll();
  }

  @override
  void dispose() {
    _saveProgressTimer?.cancel();
    _saveWatchProgress();
    _isInMiniMode = false;
    MiniPlayerManager.shouldRestorePlayer.removeListener(_onRestorePlayer);
    _hideControlsTimer?.cancel();
    _seekOverlayTimer?.cancel();
    _arrowCtrl.dispose();
    _minifyCtrl.dispose();
    _panelCtrl.dispose();
    _searchController.dispose();

    // Dispose controllers to stop background playback
    try {
      _chewieController?.pause();
    } catch (_) {}
    try {
      _chewieController?.dispose();
    } catch (_) {}
    try {
      _videoPlayerController?.dispose();
    } catch (_) {}
    _chewieController = null;
    _videoPlayerController = null;

    // Về lại portrait khi thoát player
    SupportRotateScreen.onlyPotrait();
    super.dispose();
  }

  void _onRestorePlayer() {
    if (MiniPlayerManager.shouldRestorePlayer.value && _isInMiniMode) {
      final controller = _miniPlayerManager.handoffController;
      final launch = _miniPlayerManager.handoffLaunch;

      if (controller != null && launch != null) {
        _miniPlayerManager.takeHandoff();

        if (mounted) {
          setState(() {
            _chewieController = controller;
            _videoPlayerController = controller.videoPlayerController;
            _currentEpisodeLink = launch.initialEpisodeLink;
            _currentEpisodeIndex = launch.initialEpisodeIndex;
            _currentServer = launch.initialServer;
            _selectedServerIndex = launch.initialServerIndex;
            _isInMiniMode = false;
          });

          if (!controller.isPlaying) {
            controller.play();
          }
        }
      }

      _miniPlayerManager.clearRestoreFlag();
    }
  }

  void _showControlsWithAutoHide() {
    _hideControlsTimer?.cancel();
    setState(() => _showControls = true);

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _showControls = false);
    });
  }

  void _hideControlsNow() {
    _hideControlsTimer?.cancel();
    if (!mounted) return;
    setState(() => _showControls = false);
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControlsNow();
    } else {
      _showControlsWithAutoHide();
    }
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    setState(() => _showControls = true);
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  double get _minifyT => _isMinifyAnimating ? _minifyCtrl.value : _miniDragT;

  void _saveWatchProgress() {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized &&
        _currentEpisodeLink != null) {
      final position = _videoPlayerController!.value.position;
      final duration = _videoPlayerController!.value.duration;

      if (position.inSeconds > 5) {
        _watchProgressStorage.saveProgressV2(
          movieId: widget.slug,
          serverIndex: _selectedServerIndex,
          episodeIndex: _currentEpisodeIndex,
          episodeName: 'Episode ${_currentEpisodeIndex + 1}',
          positionMs: position.inMilliseconds,
          durationMs: duration.inMilliseconds,
        );
      }
    }
  }

  void _startSaveProgressTimer() {
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _saveWatchProgress();
    });
  }

  Future<void> _initializePlayer(String videoUrl) async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );
    await _videoPlayerController!.initialize();

    final savedProgress = await _watchProgressStorage.getProgressV2(
      movieId: widget.slug,
      serverIndex: _selectedServerIndex,
      episodeIndex: _currentEpisodeIndex,
    );

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: true,
      showControls: false,
      fullScreenByDefault: false,
    );

    debugPrint('=== Video initialized ===');

    if (savedProgress != null) {
      final savedPosition = Duration(milliseconds: savedProgress.positionMs);
      _videoPlayerController!.seekTo(savedPosition);
      debugPrint(
        'Restored progress: ${savedPosition.inSeconds}s / ${savedProgress.progressPercent * 100}%',
      );
    }

    _startSaveProgressTimer();
    setState(() {});
  }

  Future<void> _disposeAndInitializePlayer(
    String videoUrl, {
    bool restoreLastPosition = false,
  }) async {
    debugPrint(
      '_disposeAndInitializePlayer: START, restoreLastPosition=$restoreLastPosition, _lastPosition=$_lastPosition',
    );

    await _chewieController?.pause();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    debugPrint(
      '_disposeAndInitializePlayer: Creating VideoPlayerController with $videoUrl',
    );
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );
    await _videoPlayerController!.initialize();
    debugPrint('_disposeAndInitializePlayer: Video initialized');

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: true,
      showControls: false,
      fullScreenByDefault: false,
    );
    debugPrint('_disposeAndInitializePlayer: ChewieController created');

    debugPrint(
      '_disposeAndInitializePlayer: Before seek, _lastPosition=$_lastPosition, restoreLastPosition=$restoreLastPosition',
    );

    // Reset scrubbing state to prevent seekbar thumb from staying at old position
    _scrubValue = 0.0;
    if (_isScrubbing) {
      setState(() => _isScrubbing = false);
    }
    // Force rebuild to update seekbar
    setState(() {});

    if (restoreLastPosition && _lastPosition != null) {
      debugPrint('RestorePosition: Seeking to $_lastPosition');
      await _videoPlayerController!.seekTo(_lastPosition!);
      final posAfterSeek = _videoPlayerController!.value.position;
      debugPrint(
        'RestorePosition: Seek completed, position after seek: $posAfterSeek',
      );
      await Future.delayed(const Duration(milliseconds: 200));
      await _chewieController!.play();
      final posAfterPlay = _videoPlayerController!.value.position;
      debugPrint('RestorePosition: After play, position: $posAfterPlay');
    } else {
      debugPrint(
        'RestorePosition: Not restoring, _lastPosition=$_lastPosition, restoreLastPosition=$restoreLastPosition',
      );
      await _chewieController!.play();
    }

    _lastPosition = null;
    debugPrint('_disposeAndInitializePlayer: END, cleared _lastPosition');
    setState(() {});
  }

  void _playEpisode(int index, EpisodesModel episode) {
    if (episode.server_data.isEmpty) return;

    // Lưu vị trí hiện tại trước khi chuyển
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      _lastPosition = _videoPlayerController!.value.position;
    }

    final episodeData = index < episode.server_data.length
        ? episode.server_data[index]
        : episode.server_data.first;

    final link = episodeData.link_m3u8.isNotEmpty
        ? episodeData.link_m3u8
        : episodeData.link_embed;

    setState(() {
      _currentEpisodeIndex = index;
      _currentServer = episode.server_name;
      _currentEpisodeLink = link;
      _videoHeight = _minVideoHeight;
    });

    _lastPosition = null; // <<< quan trọng: không carry qua tập mới
    _disposeAndInitializePlayer(link, restoreLastPosition: false);
  }

  int _findEpisodeIndexByNumber(List<ServerData> list, int targetEp) {
    for (int i = 0; i < list.length; i++) {
      final raw = list[i].name;
      final match = RegExp(r'\d+').firstMatch(raw);
      final num = int.tryParse(match?.group(0) ?? '');
      if (num == targetEp) return i;
    }
    return -1;
  }

  void _submitEpisode() {
    final epNum = int.tryParse(_searchController.text.trim());
    if (epNum == null) return;

    if (widget.episodes.isEmpty) return;

    final server = widget.episodes[_selectedServerIndex];
    final dataList = server.server_data;
    if (dataList.isEmpty) return;

    final episodeIndex = _findEpisodeIndexByNumber(dataList, epNum);

    if (episodeIndex == -1) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(
          title: 'Chú ý',
          content: 'Không tìm thấy tập $epNum trên server hiện tại.',
          buttonTitle: 'Đóng',
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _searchController.clear();

    _playEpisode(episodeIndex, server);
  }

  Future<void> _switchServer(int newServerIndex) async {
    if (newServerIndex == _selectedServerIndex) return;

    final newServer = widget.episodes[newServerIndex];
    if (newServer.server_data.isEmpty) return;

    // Chỉ giữ vị trí khi là phim single (Full)
    final isSingleType = widget.movie.episode_current == 'Full';
    bool shouldRestorePosition = false;

    if (isSingleType) {
      // Hủy timer lưu tiến trình để tránh ghi đè
      _saveProgressTimer?.cancel();

      // Lưu vị trí hiện tại trước khi chuyển server
      final currentPos = _videoPlayerController?.value.position;
      debugPrint('SwitchServer (Single): currentPos = $currentPos');
      if (currentPos != null) {
        _lastPosition = currentPos;
        shouldRestorePosition = true;
        debugPrint(
          'SwitchServer (Single): Saved _lastPosition = $_lastPosition',
        );
      }
    }

    int safeEpisodeIndex = _currentEpisodeIndex;
    safeEpisodeIndex = safeEpisodeIndex.clamp(
      0,
      newServer.server_data.length - 1,
    );

    setState(() {
      _selectedServerIndex = newServerIndex;
      _currentServer = newServer.server_name;
    });

    final episodeData = newServer.server_data[safeEpisodeIndex];
    final link = episodeData.link_m3u8.isNotEmpty
        ? episodeData.link_m3u8
        : episodeData.link_embed;

    setState(() {
      _currentEpisodeIndex = safeEpisodeIndex;
      _currentEpisodeLink = link;
    });

    _disposeAndInitializePlayer(
      link,
      restoreLastPosition: shouldRestorePosition,
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);

    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    _resetHideControlsTimer();
  }

  void _togglePlayPause() {
    if (_chewieController == null) return;

    if (_chewieController!.isPlaying) {
      _chewieController!.pause();
    } else {
      _chewieController!.play();
    }
    _resetHideControlsTimer();
  }

  void _collapseVideo() {
    if (_videoHeight >= _maxVideoHeight - 100) {
      setState(() {
        _videoHeight = _minVideoHeight;
        _isExpanded = false;
      });
    }
  }

  void _enterMiniPlayer() {
    final controller = _chewieController;
    if (controller == null) return;

    final launchData = MiniPlayerLaunchData(
      slug: widget.slug,
      movieName: widget.movieName,
      thumbnailUrl: widget.thumbnailUrl,
      episodes: widget.episodes,
      movie: widget.movie,
      initialEpisodeLink: _currentEpisodeLink,
      initialEpisodeIndex: _currentEpisodeIndex,
      initialServer: _currentServer,
      initialServerIndex: _selectedServerIndex,
    );

    _miniPlayerManager.showMiniPlayer(
      controller: controller,
      launchData: launchData,
    );

    _isInMiniMode = true;
    _chewieController = null;
    _videoPlayerController = null;

    SupportRotateScreen.onlyPotrait();

    Navigator.pop(context);
  }

  void _seekTo(double position) {
    final controller = _chewieController;
    if (controller == null) return;

    final duration = controller.videoPlayerController.value.duration;
    final newPosition = Duration(
      milliseconds: (position * duration.inMilliseconds).round(),
    );
    controller.seekTo(newPosition);
  }

  void _commitSeek() {
    _resetHideControlsTimer();
    if (_isScrubbing) {
      setState(() => _isScrubbing = false);
    }
  }

  void _handleYoutubeSeek(SeekDirection dir) {
    final chewie = _chewieController;
    if (chewie == null) return;

    final vp = chewie.videoPlayerController;
    final now = DateTime.now();

    final withinWindow =
        _lastSeekTapTime != null &&
        now.difference(_lastSeekTapTime!) <= const Duration(milliseconds: 800);

    setState(() {
      if (withinWindow && _seekDir == dir) {
        _seekCount += 1;
      } else {
        _seekDir = dir;
        _seekCount = 1;
      }

      _showSeekOverlay = true;
    });

    _lastSeekTapTime = now;

    final sign = dir == SeekDirection.forward ? 1 : -1;
    final offset = Duration(seconds: sign * _seekCount * _seekStepSeconds);

    final pos = vp.value.position;
    final dur = vp.value.duration;

    final target = pos + offset;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > dur ? dur : target);

    chewie.seekTo(clamped);

    // _arrowCtrl.repeat();
    _arrowCtrl.forward(from: 0);

    _seekOverlayTimer?.cancel();
    _seekOverlayTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _arrowCtrl.stop();
      _arrowCtrl.value = 0;
      setState(() => _showSeekOverlay = false);
    });

    _resetHideControlsTimer();
  }

  void _handleDoubleTap(TapDownDetails details) {
    final controller = _chewieController;
    if (controller == null) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth * 0.4) {
      _handleYoutubeSeek(SeekDirection.backward);
    } else if (tapX > screenWidth * 0.6) {
      _handleYoutubeSeek(SeekDirection.forward);
    } else {
      // Vùng giữa không làm gì - play/pause chỉ từ nút
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  double _bufferedFraction(VideoPlayerValue v) {
    final dur = v.duration.inMilliseconds;
    if (dur <= 0) return 0;

    if (v.buffered.isEmpty) return 0;
    final end = v.buffered.last.end.inMilliseconds;
    return (end / dur).clamp(0.0, 1.0);
  }

  // Getters cho seekbar lift khi expand video
  double get _expandT {
    final denom = (_maxVideoHeight - _minVideoHeight);
    if (denom <= 0) return 0;
    return ((_videoHeight - _minVideoHeight) / denom).clamp(0.0, 1.0);
  }

  double get _seekbarLift {
    final t = Curves.easeOut.transform(_expandT);
    return lerpDouble(0, 12, t)!; // nhích lên tối đa 12px
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgApp,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _buildLandscapePlayer();
          } else {
            return _buildPortraitPlayer();
          }
        },
      ),
    );
  }

  Widget _buildVideoAreaWithoutSeekbar() {
    // Check xem có đang expand không để điều chỉnh hit area
    final isVideoExpanded = _videoHeight >= _maxVideoHeight - 100;
    return GestureDetector(
      // Kéo video để chuyển thành mini player (giống YouTube)
      // Chỉ khi video chưa expand full mới có thể kéo vào mini player
      onVerticalDragStart: (_) {
        if (isVideoExpanded) return;
        _minifyCtrl.stop();
        _isMinifyAnimating = false;
        setState(() {
          _miniDragDy = 0;
          _miniDragT = 0;
        });
      },
      onVerticalDragUpdate: (d) {
        // Chỉ cho phép kéo xuống khi video chưa expand
        if (isVideoExpanded) return;
        _miniDragDy += d.delta.dy;
      },
      onVerticalDragEnd: (d) {
        // Chỉ cho phép vào mini player khi video chưa expand
        if (isVideoExpanded) return;

        final v = d.primaryVelocity ?? 0;
        // Kéo xuống đủ 80px hoặc có velocity lớn sẽ vào mini player
        if (_miniDragDy > 80 || v > 800) {
          _enterMiniPlayer();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (isVideoExpanded) {
            _collapseVideo();
          } else {
            _toggleControls();
          }
        },
        onDoubleTapDown: _handleDoubleTap,
        child: Container(
          height: _videoHeight,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              if (_videoPlayerController != null &&
                  _videoPlayerController!.value.isInitialized)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.5,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 30),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoPlayerController!.value.size.width,
                          height: _videoPlayerController!.value.size.height,
                          child: VideoPlayer(_videoPlayerController!),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_chewieController != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(controller: _chewieController!),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.secondColor,
                    ),
                  ),
                ),

              if (_showControls)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColor.bgApp,
                          AppColor.bgApp.withValues(alpha: .8),
                          AppColor.bgApp.withValues(alpha: .6),
                          AppColor.bgApp.withValues(alpha: .4),
                          AppColor.bgApp.withValues(alpha: .2),
                          AppColor.bgApp.withValues(alpha: .1),
                          AppColor.bgApp.withValues(alpha: .05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              if (_showControls && _chewieController != null)
                _buildPlayPauseOverlay(),
              if (_showSeekOverlay && _seekDir != null) _buildSeekOverlay(50),
              Positioned(
                top: 8,
                left: 8,
                right: 0,
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Iconsax.arrow_down_1_copy,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ambient blur "lụi" xuống đầu panel
  Widget _buildPanelAmbientTop() {
    final vp = _videoPlayerController;
    if (vp == null || !vp.value.isInitialized) return const SizedBox.shrink();

    return SizedBox(
      height: 60,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lớp 1: Video (Chỉ lấy nửa dưới)
            Opacity(
              opacity: .35,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: FittedBox(
                  fit: BoxFit.cover,

                  child: SizedBox(
                    width: vp.value.size.width,
                    height: vp.value.size.height,
                    child: VideoPlayer(vp),
                  ),
                ),
              ),
            ),

            // Lớp 2: Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColor.bgApp, // Đáy đậm nhất
                      AppColor.bgApp.withValues(alpha: 0.6),
                      AppColor.bgApp.withValues(
                        alpha: 0.0,
                      ), // Trong suốt dần lên đỉnh
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitPlayer() {
    // Khi expand video, ẩn SafeArea để video nằm chính giữa
    final isExpanded = _videoHeight >= _maxVideoHeight - 100;
    return SafeArea(
      top: !isExpanded,
      bottom: false,
      left: !isExpanded,
      right: !isExpanded,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              _buildVideoAreaWithoutSeekbar(),
              Flexible(
                child: _videoHeight < _maxVideoHeight - 120
                    ? Material(
                        color: AppColor.bgApp,
                        clipBehavior: Clip.antiAlias, // QUAN TRỌNG
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Ambient blur ở trên cùng
                            if (!isExpanded)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Opacity(
                                  opacity: (1 - _minifyT).clamp(0.0, 1.0),
                                  child: _buildPanelAmbientTop(),
                                ),
                              ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.bounceInOut,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.movie.origin_name,
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis, // Nếu tên quá dài sẽ hiện "..."
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.movie.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor
                                                .secondColor, // Màu nhấn cho tên phụ
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (widget.movie.episode_current != 'Full')
                                    Column(
                                      spacing: 3,
                                      children: [
                                        _buildListServerForSeriesMovie(),
                                        _textFieldEpisode(),
                                      ],
                                    ),

                                  const SizedBox(height: 10),
                                  Expanded(
                                    child:
                                        widget.movie.episode_current == 'Full'
                                        ? _buildEpisodeListForSingle()
                                        : _buidlListEpisodeForSeriesMovie(),
                                  ),
                                  // Expanded(child: _buildEpisodeListForSingle()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          // 1) Info row + fullscreen (only show when _showControls)
          if (_showControls)
            Positioned(
              top:
                  _videoHeight -
                  (_thumbRadius * 2) -
                  44 -
                  _seekbarLift, // có lift khi expand
              left: 0,
              right: 0,
              child: _buildBottomInfoRow(),
            ),
          Positioned(
            top:
                _videoHeight -
                _thumbRadius -
                _seekbarLift, // có lift khi expand
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              elevation: 10,
              child: _buildPinnedSeekbarOnly(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFieldEpisode() {
    // final isSingle = widget.movie.type == 'single';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: const Color(0xff1A1A22), // Dark bg like screenshot
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'Tập 1 - ${widget.episodes[_selectedServerIndex].server_data.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),

            // Vạch ngăn
            Container(
              width: 1,
              height: 24,
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),

            // Ô nhập chiếm 1 phần
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 32,
                child: TextField(
                  onSubmitted: (_) => _submitEpisode(),
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center, // quan trọng
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1.0,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'Nhập tập',
                    hintStyle: const TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                      height: 1.0,
                    ),

                    // bỏ border
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,

                    // ICON: bóp constraints lại để không bị xa + không làm cao field
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 6, right: 6),
                      child: Icon(
                        Iconsax.search_normal_1_copy,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 32,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Iconsax.arrow_right_3_copy,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: _submitEpisode,
                    ),

                    // padding nhỏ để text nằm giữa theo chiều dọc
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),

                    // optional: nếu muốn hint không "bay" lên khi có label
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buidlListEpisodeForSeriesMovie() {
    final serverData = widget.episodes[_selectedServerIndex].server_data;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: GridView.builder(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120, // Một ô rộng tối đa 250px.
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: 16 / 9,
        ),
        itemCount: serverData.length,
        itemBuilder: (context, index) {
          final episode = serverData[index];

          // Kiểm tra đang phát: Đúng tập index VÀ đúng Server name
          // ĐIỂM QUAN TRỌNG:
          // Chỉ cần index của GridView trùng với _currentEpisodeIndex là nó sẽ sáng đèn,
          // bất kể bạn đang nhấn xem ở Server nào.
          final bool isActive = _currentEpisodeIndex == index;
          final currentServer = widget.episodes[_selectedServerIndex];
          return InkWell(
            onTap: () => {_playEpisode(index, currentServer)},
            child: Container(
              padding: const EdgeInsets.all(5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xff272A39),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          Color(0xFFC77DFF), // Tím
                          Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                          Color(0xFFFFD275),
                        ], // Vàng],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Color(0xFFC77DFF),
                          blurRadius: 12,
                          offset: Offset(0, 0),
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                spacing: 3,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isActive) ...[
                    const SizedBox(width: 3),
                    SizedBox(
                      width: 13,
                      height: 13,
                      child: Lottie.asset(
                        'assets/icons/now_playing.json',
                        delegates: LottieDelegates(
                          values: [
                            ValueDelegate.color(const [
                              '**',
                            ], value: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Flexible(
                    child: Text(
                      episode.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListServerForSeriesMovie() {
    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff272A39), Color(0xff191A24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        scrollDirection: Axis.horizontal,
        itemCount: widget.episodes.length,
        itemBuilder: (context, index) {
          // Lấy thông tin server từ Map của bạn
          final serverInfo = CoverMap.getConfigFromServerName(
            widget.episodes[index].server_name,
          );

          // Kiểm tra xem Server này có đang được chọn ĐỂ HIỂN THỊ TẬP PHIM không
          final isSelected = _selectedServerIndex == index;

          return InkWell(
            onTap: () {
              _switchServer(index);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                // Nếu chọn thì sáng màu, không thì mờ
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  serverInfo['title'],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayPauseOverlay() {
    if (_chewieController == null) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: !_showControls, // controls ẩn thì nút không bắt sự kiện
      child: Center(
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: GestureDetector(
            // QUAN TRỌNG: chỉ vùng nút bắt tap
            onTap: _togglePlayPause,
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 80),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: _chewieController!.isPlaying
                    ? const Icon(
                        Iconsax.pause_copy,
                        key: ValueKey('pause'),
                        color: Colors.white,
                        size: 35,
                      )
                    : const Padding(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Icon(
                          Iconsax.play_copy,
                          key: ValueKey('play'),
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _movingArrowIcon(bool isForward) {
    const maxDx = 14.0;

    return AnimatedBuilder(
      animation: _arrowCtrl,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_arrowCtrl.value);
        final dx = (isForward ? 1 : -1) * (t * maxDx);

        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Icon(
        isForward ? Iconsax.arrow_right_3_copy : Iconsax.arrow_left_2_copy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildEpisodeListForSingle() {
    return Scrollbar(
      controller: _scrollController,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250, // Một ô rộng tối đa 250px.
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 16 / 9,
        ),
        itemCount: widget.episodes.length,
        itemBuilder: (context, index) {
          final serverName = CoverMap.getConfigFromServerName(
            widget.episodes[index].server_name,
          );
          final isPlaying = _currentEpisodeIndex == index;
          final isCurrentServer =
              _currentServer == widget.episodes[index].server_name;
          // Giả sử lấy dữ liệu từ CoverMap
          return Material(
            color: Colors.transparent,
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _switchServer(index),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.horizontal(
                            right: Radius.circular(10),
                          ),
                          child: FastCachedImage(
                            url: AppUrl.convertImageDirect(
                              widget.movie.poster_url,
                            ),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, loadingProgress) {
                              return _buildSkeletonForposter();
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildSkeletonForposter();
                            },
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              // Cấu trúc màu: Đậm nhất -> Nhạt dần -> Trong suốt
                              colors: [
                                serverName['color'], // Giữ nguyên 100% màu gốc ở mép trái
                                serverName['color'].withValues(
                                  alpha: 0.98,
                                ), // Giảm xuống 70% ở điểm giữa
                                // Giảm xuống 70% ở điểm giữa
                                serverName['color'].withValues(
                                  alpha: 0.0,
                                ), // 0% ở mép phải (trong suốt hoàn toàn)
                              ],
                              // stops giúp khống chế vị trí màu:
                              // 0.0 là sát mép trái, 1.0 là sát mép phải
                              stops: const [0.0, 0.60, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          // Thêm padding để nội dung không dính sát mép card
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start, // Dóng hàng bên trái
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Căn giữa theo chiều dọc của card
                            children: [
                              // --- Row 1: Icon + Loại bản (Lồng tiếng/Vietsub) ---
                              Row(
                                children: [
                                  Icon(
                                    serverName['icon'],
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    serverName['title'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ), // Khoảng cách giữa các dòng
                              // --- Row 2: Tiêu đề phim ---
                              Text(
                                widget.movieName,
                                maxLines:
                                    2, // Giảm xuống 2 dòng cho gọn giống ảnh mẫu
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // --- Row 3: Nút "Đang phát" ---
                              // Dùng IntrinsicWidth để Container chỉ dài vừa bằng nội dung bên trong
                              AnimatedContainer(
                                duration: Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 5,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize
                                      .min, // Ép Row co lại theo nội dung
                                  children: [
                                    Text(
                                      isPlaying && isCurrentServer
                                          ? 'Đang phát'
                                          : 'Xem bản này',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    isPlaying && isCurrentServer
                                        ? const SizedBox(width: 4)
                                        : const SizedBox.shrink(),
                                    isPlaying && isCurrentServer
                                        ? SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: Lottie.asset(
                                              'assets/icons/now_playing.json',
                                              delegates: LottieDelegates(
                                                values: [
                                                  ValueDelegate.color(const [
                                                    '**',
                                                  ], value: Colors.black),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonForposter() {
    // Bọc AspectRatio để đảm bảo nó luôn có hình dáng poster phim (2:3)
    return AspectRatio(
      aspectRatio: 2 / 3, // Tỉ lệ chuẩn poster phim
      child: Shimmer.fromColors(
        baseColor: Color(0xff272A39),
        highlightColor: Color(0xff4A4E69), // Màu sáng hơn để thấy hiệu ứng
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black, // Bắt buộc phải có màu để Shimmer phủ lên
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSeekOverlay(double? seekPadding) {
    final isForward = _seekDir == SeekDirection.forward;
    final seconds = _seekCount * _seekStepSeconds;
    // Khi hiện: offset = 0 (đứng đúng vị trí)
    // Khi ẩn: forward đẩy ra phải, backward đẩy ra trái
    final hiddenOffset = isForward
        ? const Offset(0.25, 0)
        : const Offset(-0.25, 0);
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: seekPadding ?? 50),
        child: Align(
          alignment: isForward ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedSlide(
            offset: _showSeekOverlay ? Offset.zero : hiddenOffset,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              opacity: _showSeekOverlay ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: isForward
                    ? [
                        Text(
                          '+$seconds',
                          style: const TextStyle(
                            shadows: [
                              BoxShadow(color: Colors.black, blurRadius: 2),
                            ],
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _movingArrowIcon(isForward),
                      ]
                    : [
                        _movingArrowIcon(isForward),
                        const SizedBox(width: 8),
                        Text(
                          '-$seconds',
                          style: const TextStyle(
                            shadows: [
                              BoxShadow(color: Colors.black, blurRadius: 2),
                            ],
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBar(double? trackHeight) {
    final chewie = _chewieController;
    if (chewie == null) return const SizedBox();

    final vp = chewie.videoPlayerController;

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: vp,
      builder: (context, value, _) {
        final durationMs = value.duration.inMilliseconds;
        final positionMs = value.position.inMilliseconds;

        final safeDurationMs = durationMs <= 0 ? 1 : durationMs;
        final safePositionMs = positionMs.clamp(0, safeDurationMs);

        final progress = safePositionMs / safeDurationMs;
        final sliderValue = _isScrubbing ? _scrubValue : progress;

        final showThumb = _isScrubbing;
        final buffered = _bufferedFraction(value);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showControls)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  // vertical: 5,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        spacing: 5,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const SizedBox(width: 6),
                          const Text(
                            '/',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const SizedBox(width: 6),
                          Text(
                            _formatDuration(value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(
                          _isFullscreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: _toggleFullscreen,
                      ),
                    ),
                  ],
                ),
              ),
            SliderTheme(
              data: SliderThemeData(
                padding: EdgeInsets.zero,
                trackHeight: _isScrubbing ? 4 : trackHeight ?? 2,
                trackShape: GradientBufferedSliderTrackShape(
                  buffered: buffered,
                  bufferedColor: Colors.white.withValues(alpha: 0.35),
                  gradientColors: const [
                    Color(0xFFC77DFF), // Tím
                    Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                    Color(0xFFFFD275),
                  ],
                ),
                activeTrackColor: AppColor.secondColor,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                thumbShape: showThumb
                    ? const _LowPositionThumbShape(radius: 6, offsetY: 0)
                    : const _InvisibleThumbShape(radius: 6),
                overlayShape: showThumb
                    ? const _LowPositionOverlayShape(radius: 12, offsetY: 0)
                    : const _InvisibleOverlayShape(radius: 14),
                thumbColor: Colors.white,
                overlayColor: AppColor.secondColor.withValues(alpha: 0.2),
                showValueIndicator: ShowValueIndicator.never,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) {
                  setState(() => _isScrubbing = true);
                  _hideControlsTimer?.cancel();
                  _showControlsWithAutoHide();
                },
                onPanUpdate: (d) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;

                  final local = box.globalToLocal(d.globalPosition);
                  final w = box.size.width;
                  final v = (local.dx / w).clamp(0.0, 1.0);

                  setState(() => _scrubValue = v);
                },
                onPanEnd: (_) {
                  _seekTo(_scrubValue);
                  setState(() => _isScrubbing = false);
                  _showControlsWithAutoHide();
                },
                child: SizedBox(
                  height: 20, // chừa đủ cho thumb/overlay
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Slider(
                      value: sliderValue.clamp(0.0, 1.0),
                      onChanged: (v) {
                        setState(() {
                          _isScrubbing = true;
                          _scrubValue = v;
                        });
                      },
                      onChangeEnd: (_) {
                        _seekTo(_scrubValue);
                        setState(() => _isScrubbing = false);
                        _showControlsWithAutoHide();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomInfoRow() {
    final chewie = _chewieController;
    if (chewie == null) return const SizedBox.shrink();
    final vp = chewie.videoPlayerController;

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: vp,
      builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(value.position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDuration(value.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 25,
                  icon: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFullscreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinnedSeekbarOnly() {
    final chewie = _chewieController;
    if (chewie == null) return const SizedBox();

    final vp = chewie.videoPlayerController;

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: vp,
      builder: (context, value, _) {
        final durationMs = value.duration.inMilliseconds;
        final positionMs = value.position.inMilliseconds;

        final safeDurationMs = durationMs <= 0 ? 1 : durationMs;
        final safePositionMs = positionMs.clamp(0, safeDurationMs);

        final progress = safePositionMs / safeDurationMs;
        final sliderValue = _isScrubbing ? _scrubValue : progress;

        final showThumb = _isScrubbing;
        final buffered = _bufferedFraction(value);

        return SliderTheme(
          data: SliderThemeData(
            padding: EdgeInsets.zero,
            trackHeight: _isScrubbing ? 4 : 2,
            trackShape: GradientBufferedSliderTrackShape(
              buffered: buffered,
              bufferedColor: Colors.white.withValues(alpha: 0.35),
              gradientColors: const [
                Color(0xFFC77DFF), // Tím
                Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                Color(0xFFFFD275),
              ],
            ),
            activeTrackColor: _isScrubbing
                ? AppColor.secondColor
                : Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
            thumbShape: showThumb
                ? const _LowPositionThumbShape(radius: 6, offsetY: 0)
                : const _InvisibleThumbShape(radius: 6),
            overlayShape: showThumb
                ? const _LowPositionOverlayShape(radius: 12, offsetY: 0)
                : const _InvisibleOverlayShape(radius: 14),
            thumbColor: Colors.white,
            overlayColor: AppColor.secondColor.withValues(alpha: 0.2),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              setState(() => _isScrubbing = true);
              _hideControlsTimer?.cancel();
              _showControlsWithAutoHide();
            },
            onPanUpdate: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;

              final local = box.globalToLocal(d.globalPosition);
              final w = box.size.width;
              final v = (local.dx / w).clamp(0.0, 1.0);

              setState(() => _scrubValue = v);
              _seekTo(v);
            },
            onPanEnd: (_) {
              setState(() => _isScrubbing = false);
              _showControlsWithAutoHide();
            },
            child: SizedBox(
              height: lerpDouble(
                _thumbRadius * 2,
                28,
                _expandT,
              )!, // tăng hit area khi expand
              child: Slider(
                value: sliderValue.clamp(0.0, 1.0),
                onChanged: (v) {
                  setState(() {
                    _isScrubbing = true;
                    _scrubValue = v;
                  });
                  _seekTo(v);
                },
                onChangeEnd: (_) {
                  setState(() => _isScrubbing = false);
                  _showControlsWithAutoHide();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandscapePlayer() {
    return Scaffold(
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        backgroundColor: AppColor.bgApp,
        child: EpisodeDrawer(
          movie: widget.movie,
          movieName: widget.movieName,
          episodes: widget.episodes,
          selectedServerIndex: _selectedServerIndex,
          currentEpisodeIndex: _currentEpisodeIndex,
          currentServer: _currentServer,
          searchController: _searchController,
          onPlayEpisode: _playEpisode,
          onSubmitEpisode: _submitEpisode,
          onSwitchServer: _switchServer,
        ),
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoPlayerController!.value.size.width,
                        height: _videoPlayerController!.value.size.height,
                        child: VideoPlayer(_videoPlayerController!),
                      ),
                    ),
                  ),
                ),
              ),
            if (_chewieController != null)
              GestureDetector(
                onTap: _toggleControls,
                onDoubleTapDown: _handleDoubleTap,
                child: Chewie(controller: _chewieController!),
              )
            else
              const Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColor.secondColor,
                  ),
                ),
              ),
            if (_showControls)
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColor.bgApp.withValues(alpha: .8),
                        AppColor.bgApp.withValues(alpha: .7),
                        AppColor.bgApp.withValues(alpha: .6),
                        AppColor.bgApp.withValues(alpha: .4),
                        AppColor.bgApp.withValues(alpha: .2),
                        AppColor.bgApp.withValues(alpha: .1),
                        AppColor.bgApp.withValues(alpha: .05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            if (_showControls && _chewieController != null)
              _buildPlayPauseOverlay(),
            Positioned(
              top: 10,
              // left: 8,
              right: 10,
              child: IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: IconButton(
                          icon: const Icon(
                            Iconsax.menu,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 18,
                          ),
                          onPressed: () => Scaffold.of(
                            context,
                          ).openEndDrawer(), //setting quality
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: _showControls
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: _buildControlBar(3),
                    )
                  : const SizedBox.shrink(),
            ),
            if (_showSeekOverlay && _seekDir != null) _buildSeekOverlay(200),
          ],
        ),
      ),
    );
  }
}

class _InvisibleThumbShape extends SliderComponentShape {
  const _InvisibleThumbShape({this.radius = 6});
  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class _InvisibleOverlayShape extends SliderComponentShape {
  const _InvisibleOverlayShape({this.radius = 14});
  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class BufferedSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const BufferedSliderTrackShape({
    required this.buffered,
    required this.bufferedColor,
    this.radius = 999,
  });

  final double buffered;
  final Color bufferedColor;
  final double radius;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2;

    final left = offset.dx;
    final width = parentBox.size.width;

    final top = offset.dy + (parentBox.size.height - trackHeight) / 2;

    return Rect.fromLTWH(left, top, width, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final canvas = context.canvas;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? const Color(0x55FFFFFF);
    final activePaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? const Color(0xFFFF0000);
    final bufferedPaint = Paint()..color = bufferedColor;

    canvas.drawRRect(rrect, inactivePaint);

    final bufW = rect.width * buffered.clamp(0.0, 1.0);
    if (bufW > 0) {
      final bufRect = Rect.fromLTWH(rect.left, rect.top, bufW, rect.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bufRect, Radius.circular(radius)),
        bufferedPaint,
      );
    }

    final played = ((thumbCenter.dx - rect.left) / rect.width).clamp(0.0, 1.0);
    final playW = rect.width * played;
    if (playW > 0) {
      final playRect = Rect.fromLTWH(rect.left, rect.top, playW, rect.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(playRect, Radius.circular(radius)),
        activePaint,
      );
    }
  }
}

class GradientBufferedSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const GradientBufferedSliderTrackShape({
    required this.buffered,
    required this.bufferedColor,
    required this.gradientColors,
    this.radius = 999,
  });

  final double buffered;
  final Color bufferedColor;
  final List<Color> gradientColors;
  final double radius;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2;
    final left = offset.dx;
    final width = parentBox.size.width;
    final top = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(left, top, width, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final canvas = context.canvas;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? const Color(0x55FFFFFF);
    final bufferedPaint = Paint()..color = bufferedColor;

    canvas.drawRRect(rrect, inactivePaint);

    final bufW = rect.width * buffered.clamp(0.0, 1.0);
    if (bufW > 0) {
      final bufRect = Rect.fromLTWH(rect.left, rect.top, bufW, rect.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bufRect, Radius.circular(radius)),
        bufferedPaint,
      );
    }

    final played = ((thumbCenter.dx - rect.left) / rect.width).clamp(0.0, 1.0);
    final playW = rect.width * played;
    if (playW > 0) {
      final playRect = Rect.fromLTWH(rect.left, rect.top, playW, rect.height);
      final gradient = LinearGradient(colors: gradientColors);
      final activePaint = Paint()..shader = gradient.createShader(playRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(playRect, Radius.circular(radius)),
        activePaint,
      );
    }
  }
}

class _LowPositionThumbShape extends SliderComponentShape {
  const _LowPositionThumbShape({this.radius = 6, this.offsetY = 0});

  final double radius;
  final double offsetY;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.white
      ..style = PaintingStyle.fill;

    final adjustedCenter = Offset(center.dx, center.dy + offsetY);
    canvas.drawCircle(adjustedCenter, radius, paint);
  }
}

class _LowPositionOverlayShape extends SliderComponentShape {
  const _LowPositionOverlayShape({this.radius = 12, this.offsetY = 0});

  final double radius;
  final double offsetY;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final color = sliderTheme.overlayColor ?? Colors.transparent;
    final alpha = (color.a * 255).round() * activationAnimation.value;
    final overlayColor = color.withAlpha(alpha.round());

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final adjustedCenter = Offset(center.dx, center.dy + offsetY);
    canvas.drawCircle(adjustedCenter, radius, paint);
  }
}
