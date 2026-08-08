import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/comments/domain/repositories/comment_repository.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_cubit.dart';
import 'package:movie_app/feature/comments/presentation/bloc/comments_state.dart';
import 'package:movie_app/feature/comments/presentation/widgets/comments_tab.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_state.dart';
import 'package:movie_app/core/config/utils/episode_drawer.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/support_rotate_screen.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lottie/lottie.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/cover_map.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';
import 'package:video_player/video_player.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/ios_now_playing_service.dart';
import 'package:movie_app/core/ios_picture_in_picture_service.dart';
import 'package:movie_app/core/player_overlay_controller.dart';
import 'package:movie_app/core/playback_wakelock.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';

enum SeekDirection { forward, backward }

enum _VideoDragMode { resize, mini }

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
  final PlayerOverlayController? overlayController;
  final ValueListenable<double>? overlayProgress;

  MoviePlayerPage({
    super.key,
    required this.slug,
    required this.movieName,
    this.thumbnailUrl,
    required List<EpisodesModel> episodes,
    this.initialEpisodeLink,
    this.initialEpisodeIndex = 0,
    this.initialServer = 'Server 1',
    required this.movie,
    required this.initialServerIndex,
    this.overlayController,
    this.overlayProgress,
  }) : episodes = EpisodeHelper.normalizeEpisodes(episodes);

  @override
  State<MoviePlayerPage> createState() => _MoviePlayerPageState();
}

class _MoviePlayerPageState extends State<MoviePlayerPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _currentEpisodeLink;
  static const double _seekbarHitHeight = 28; // vùng chạm dày
  static const double _seekbarVisualHeight = 2; // thanh mỏng
  int _episodeCrossAxisCount = 1;
  static const double _episodeMaxExtent = 120;
  static const double _episodeMainExtent = 40;
  static const double _episodeMainSpacing = 5;
  static const double _episodeCrossSpacing = 5;
  static const double _episodePaddingTop = 10;
  static const double _episodePaddingH = 10;
  bool _isPLaying = false;
  int _currentEpisodeIndex = 0;
  String _currentServer = '';
  bool _isFullscreen = false;
  static const double kMinPanelHFull = 120; // title + handle (tối thiểu)
  static const double kMinPanelHRich = 260; // title + server list + TextField
  double _videoHeight = 0;
  bool _lsDrawerOpen = false;
  double _minVideoHeight = 0;
  double _maxVideoHeight = 0;
  double _initialDragY = 0;
  double _initialHeight = 0;
  bool _isDragging = false;
  bool _showControls = false;
  bool _isScrubbing = false;
  bool _isExpanded = false;
  Duration? _lastPosition;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  List<ConnectivityResult> _connectivityResults = const [];

  bool _connectivityInitialized = false;
  Timer? _connectivityConfirmTimer;
  bool _isCommentsEmptyPressed = false;
  final GlobalKey<NavigatorState> _commentsNavigatorKey =
      GlobalKey<NavigatorState>();
  OverlayEntry? _commentsOverlayEntry;
  double _commentsSheetHeight = 0;
  bool _commentsSheetPresentationStarted = false;
  final _drawerKey = GlobalKey<EpisodeDrawerState>();
  int _selectedServerIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollMovie = ScrollController();
  double _scrubValue = 0.0;
  int _seekCount = 0;
  BatteryState _batteryState = BatteryState.unknown;

  StreamSubscription<BatteryState>? _batteryStateSubscription;

  bool get _isCharging => _batteryState == BatteryState.charging;
  Timer? _wifiQualityTimer;

  int _estimatedWifiLevel = 2;

  DateTime? _lastWifiBufferingAt;
  bool get _isConnectedToPower =>
      _batteryState == BatteryState.charging ||
      _batteryState == BatteryState.full ||
      _batteryState == BatteryState.connectedNotCharging;
  static const double _serverBarH = 65;
  static const double _searchBarH = 50;
  static const double _seriesControlsSpacing = 3;
  static const double _seriesControlsBottomSpacing = 10;
  bool _isExitingPlayer = false;
  static const double _seriesControlsMaxH =
      _serverBarH +
      _seriesControlsSpacing +
      _searchBarH +
      _seriesControlsBottomSpacing;
  final int _seekStepSeconds = 10;
  final GlobalKey _videoBoxKey = GlobalKey(); // khai báo ở State
  final GlobalKey _playerSurfaceKey = GlobalKey(
    debugLabel: 'movie-player-surface',
  );

  final Battery _battery = Battery();

  Timer? _statusHeaderTimer;
  DateTime _statusNow = DateTime.now();
  int _batteryLevel = 100;

  /// Controls luôn phải hiện khi:
  /// - người dùng vừa chạm màn hình;
  /// - video đang tải/buffering;
  /// - video gặp lỗi.
  bool get _controlsVisible =>
      _showControls || _isPlayerLoading || _playerLoadError != null;
  static const double _thumbRadius = 6;
  final DraggableScrollableController _panelCtrl =
      DraggableScrollableController();
  static const double _panelMin = 0.18;
  static const double _panelMax = 0.65;
  double _dragDy = 0;
  double _miniDragDy = 0;
  final List<GlobalKey> _episodeKeys = [];
  bool get _isExpandedPortrait => _expandT >= 0.97;
  bool _wasPlayingBeforeScrub = false;
  Timer? _seekThrottle;
  Duration _previewPosition = Duration.zero;
  String? _previewThumbUrl; // nếu có storyboard từ server
  static const double _panelAmbientH = 26;

  bool _showSeekOverlay = false;
  SeekDirection? _seekDir;
  Timer? _hideControlsTimer;
  Timer? _seekOverlayTimer;
  bool _panelDragging = false;
  Timer? _saveProgressTimer;
  DateTime? _lastSeekTapTime;
  late final AnimationController _arrowCtrl;
  Future<void> _historyWriteQueue = Future<void>.value();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _episodeScrollController = ScrollController();

  bool _isEpisodeUserDragging = false;
  bool _isProgrammaticEpisodeScroll = false;

  double _lastEpisodeScrollPixels = 0;

  // Ban đầu thanh server hiển thị đầy đủ.
  double _seriesControlsExtent = _seriesControlsMaxH;
  final ScrollController _landscapeEpisodeScrollController = ScrollController();
  bool _isExpandInfor = false;
  _VideoDragMode? _videoDragMode; // null = undecided
  double _videoGestureDragDy = 0;
  bool _autoPlayTriggered = false;
  bool _isPlaybackCompleted = false;
  VoidCallback? _vpPositionListener;
  bool _panelResizingFromOverscroll = false;
  late final AnimationController _videoSnapCtrl;
  Animation<double>? _videoSnapAnim;
  double _panelDragDy = 0;
  double _videoResizeDragDy = 0;
  double? _videoSnapTarget;
  AnimationStatusListener? _snapStatusListener;
  double _dragStartHeight = 0;
  Orientation? _lastOrientation;
  bool _orientationChangeInFlight = false;
  bool _orientationSyncScheduled = false;
  Orientation? _pendingOrientationSync;
  Timer? _orientationChangeFallbackTimer;
  Timer? _autoToastTimer;
  bool _showAutoToast = false;
  String _autoToastText = '';
  VoidCallback? _vpEndListener;
  static const double _landscapeZoomMin = 1.0;
  static const double _landscapeZoomMax = 2.0;
  late final AnimationController _landscapeZoomSnapCtrl;
  Timer? _landscapeZoomLabelTimer;
  double _landscapeZoomScale = _landscapeZoomMin;
  double _landscapeZoomStartScale = _landscapeZoomMin;
  bool _landscapePinchZooming = false;
  bool _showLandscapeZoomLabel = false;
  bool _landscapeAtOrAboveFill = false;
  bool _landscapeControlsVisibleBeforeZoom = false;
  bool _startingPictureInPicture = false;
  late final PlayerCubit _playerCubit;
  late final UserLibraryCubit? _libraryCubit;
  int _playerInitGeneration = 0;
  bool _isVideoLoading = false;
  bool _isCommentsEmptyHovered = false;
  bool _isPlaybackBuffering = false;
  String? _playerLoadError;
  DateTime? _lastNowPlayingUpdate;
  bool? _lastNowPlayingIsPlaying;
  bool get _usesNativeIosVideoView => Platform.isIOS;
  bool get _isPlayerLoading {
    if (_playerLoadError != null) return false;

    final controller = _videoPlayerController;
    if (controller == null) return true;

    final value = controller.value;
    if (value.hasError) return false;

    return _isVideoLoading ||
        !value.isInitialized ||
        _isPlaybackBuffering ||
        value.isBuffering;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _playerCubit = context.read<PlayerCubit>();
    _libraryCubit = context.read<UserLibraryCubit?>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playerCubit.updateCurrentEpisode(
        widget.slug,
        _currentEpisodeIndex,
        _selectedServerIndex,
      );
    });
    _startStatusHeaderTicker();

    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _videoSnapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    widget.overlayController?.attachTransientOverlayDismissHandler(
      owner: this,
      dismiss: _dismissCommentsOverlay,
    );
    _landscapeZoomSnapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _selectedServerIndex = widget.initialServerIndex;
    _currentEpisodeIndex = widget.initialEpisodeIndex;
    _currentServer = widget.initialServer;

    if (widget.initialEpisodeLink != null &&
        widget.initialEpisodeLink!.isNotEmpty) {
      _currentEpisodeLink = widget.initialEpisodeLink;
      unawaited(_saveWatchProgress());
      _initializePlayer(widget.initialEpisodeLink!);
    } else if (widget.episodes.isNotEmpty) {
      _playEpisode(widget.initialEpisodeIndex, widget.episodes.first);
    } else {
      _currentEpisodeLink = null;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentEpisode(animated: false);
    });
    unawaited(SupportRotateScreen.onlyPotrait());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playerInitGeneration++;
    _saveProgressTimer?.cancel();
    unawaited(_saveWatchProgress(flushRemote: true));
    widget.overlayController?.detachPlaybackController(owner: this);
    widget.overlayController?.detachTransientOverlayDismissHandler(owner: this);
    _removeCommentsOverlayEntry();
    _hideControlsTimer?.cancel();
    _seekThrottle?.cancel();
    _seekOverlayTimer?.cancel();
    _landscapeZoomLabelTimer?.cancel();
    _orientationChangeFallbackTimer?.cancel();
    _removeVpListeners();
    _autoToastTimer?.cancel();
    _statusHeaderTimer?.cancel();

    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    PlaybackWakelock.unawaitedSetEnabled(false);
    unawaited(IosNowPlayingService.clear());
    unawaited(_detachPictureInPicture());
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

    _arrowCtrl.dispose();
    _videoSnapCtrl.dispose();
    _landscapeZoomSnapCtrl.dispose();
    _panelCtrl.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _scrollMovie.dispose();
    _episodeScrollController.dispose();
    _landscapeEpisodeScrollController.dispose();

    SupportRotateScreen.onlyPotrait();
    _batteryStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _connectivityConfirmTimer?.cancel();
    _connectivitySubscription?.cancel();
    _wifiQualityTimer?.cancel();
    super.dispose();
  }

  void _seekToThrottled(Duration target, {int ms = 80}) {
    _seekThrottle?.cancel();
    _seekThrottle = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      _videoPlayerController?.seekTo(target);
    });
  }

  VideoPlayerController _createVideoPlayerController(String videoUrl) {
    return VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: _usesNativeIosVideoView,
      ),
      viewType: _usesNativeIosVideoView
          ? VideoViewType.platformView
          : VideoViewType.textureView,
    );
  }

  Future<void> _attachPictureInPicture() async {
    final controller = _videoPlayerController;
    if (!_usesNativeIosVideoView ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    await IosNowPlayingService.configureSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(IosPictureInPictureService.attach(controller));
    });
  }

  Widget _buildNetworkIndicator() {
    // Plugin đang đọc trạng thái lần đầu:
    // không hiển thị Wi-Fi gạch chéo vội.
    if (!_connectivityInitialized) {
      return const _IosWifiStrengthIcon(
        level: 2,
        inactiveColor: Color(0x33FFFFFF),
      );
    }

    final results = _connectivityResults;

    final isOffline =
        results.isEmpty || results.contains(ConnectivityResult.none);

    if (isOffline) {
      return const Icon(
        CupertinoIcons.wifi_slash,
        color: Colors.white54,
        size: 21,
      );
    }

    if (results.contains(ConnectivityResult.wifi)) {
      return _buildDynamicIosWifiQuality();
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return const Text(
        'LTE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (results.contains(ConnectivityResult.ethernet)) {
      return const Icon(CupertinoIcons.globe, color: Colors.white, size: 20);
    }

    return const Icon(CupertinoIcons.globe, color: Colors.white, size: 20);
  }

  Widget _buildDynamicIosWifiQuality() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _IosWifiStrengthIcon(
        key: ValueKey<int>(_estimatedWifiLevel),
        level: _estimatedWifiLevel,
        size: 22,
      ),
    );
  }

  void _syncPlayerSystemUi() {
    if (!mounted) return;

    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      // Ngang: ẩn status bar thật vì mình sẽ dựng header giả.
      unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
      );
      return;
    }

    if (_isExpandedPortrait) {
      // Expand dọc: chỉ giữ thanh điều hướng dưới,
      // ẩn status bar phía trên.
      unawaited(
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: const [SystemUiOverlay.bottom],
        ),
      );
      return;
    }

    // Trạng thái xem phim dọc bình thường.
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    final normalized = results.toSet().toList(growable: false);

    final reportsOffline =
        normalized.isEmpty || normalized.contains(ConnectivityResult.none);

    _connectivityConfirmTimer?.cancel();

    if (reportsOffline) {
      // Trên iOS đôi khi stream báo none rồi ngay sau đó mới báo wifi.
      // Chờ một chút rồi kiểm tra lại trước khi hiển thị gạch chéo.
      _connectivityConfirmTimer = Timer(const Duration(milliseconds: 500), () {
        unawaited(_refreshConnectivity(confirmOffline: true));
      });

      return;
    }

    if (!mounted) return;

    setState(() {
      _connectivityResults = normalized;
      _connectivityInitialized = true;
    });
  }

  void _startStatusHeaderTicker() {
    unawaited(_refreshStatusHeader());
    _wifiQualityTimer?.cancel();

    _wifiQualityTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshEstimatedWifiLevel();
    });
    // Đọc mạng ngay khi vào màn hình.
    unawaited(_refreshConnectivity());

    // Theo dõi khi chuyển Wi-Fi/mobile hoặc mất kết nối.
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
      onError: (_) {
        unawaited(_refreshConnectivity());
      },
    );

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _batteryState = state;
      });

      unawaited(_refreshStatusHeader());
    });

    _statusHeaderTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(_refreshStatusHeader());
    });
  }

  void _refreshEstimatedWifiLevel() {
    if (!mounted) return;

    final usingWifi = _connectivityResults.contains(ConnectivityResult.wifi);

    if (!usingWifi) {
      return;
    }

    final vp = _videoPlayerController;
    var nextLevel = 2;

    if (vp == null || !vp.value.isInitialized) {
      nextLevel = 1;
    } else {
      final value = vp.value;

      if (_isPlaybackBuffering || value.isBuffering) {
        _lastWifiBufferingAt = DateTime.now();
        nextLevel = 1;
      } else {
        var bufferedAhead = Duration.zero;

        if (value.buffered.isNotEmpty) {
          final bufferedEnd = value.buffered.last.end;

          if (bufferedEnd > value.position) {
            bufferedAhead = bufferedEnd - value.position;
          }
        }

        final recentlyBuffered =
            _lastWifiBufferingAt != null &&
            DateTime.now().difference(_lastWifiBufferingAt!) <
                const Duration(seconds: 8);

        if (recentlyBuffered || bufferedAhead < const Duration(seconds: 6)) {
          nextLevel = 1;
        } else if (bufferedAhead < const Duration(seconds: 30)) {
          nextLevel = 2;
        } else {
          nextLevel = 3;
        }
      }
    }

    if (_estimatedWifiLevel == nextLevel) return;

    setState(() {
      _estimatedWifiLevel = nextLevel;
    });
  }

  Future<void> _refreshConnectivity({bool confirmOffline = false}) async {
    try {
      final results = await _connectivity.checkConnectivity();

      if (!mounted) return;

      final normalized = results.toSet().toList(growable: false);

      final reportsOffline =
          normalized.isEmpty || normalized.contains(ConnectivityResult.none);

      // Lần đọc đầu báo none thì kiểm tra lại sau 400 ms,
      // tránh icon Wi-Fi bị gạch chéo giả trên iOS.
      if (reportsOffline && !confirmOffline) {
        _connectivityConfirmTimer?.cancel();

        _connectivityConfirmTimer = Timer(
          const Duration(milliseconds: 400),
          () {
            unawaited(_refreshConnectivity(confirmOffline: true));
          },
        );

        return;
      }

      setState(() {
        _connectivityResults = normalized;
        _connectivityInitialized = true;
      });
    } catch (error) {
      debugPrint('Không đọc được trạng thái mạng: $error');

      // Không tự đổi thành offline khi plugin xảy ra lỗi.
      // Giữ trạng thái gần nhất.
    }
  }

  Future<void> _refreshStatusHeader() async {
    var level = _batteryLevel;
    var state = _batteryState;

    try {
      level = await _battery.batteryLevel;
      state = await _battery.batteryState;
    } catch (_) {
      // Giữ dữ liệu cũ nếu platform tạm thời chưa trả kết quả.
    }

    if (!mounted) return;

    setState(() {
      _statusNow = DateTime.now();
      _batteryLevel = level.clamp(0, 100).toInt();
      _batteryState = state;
    });
  }

  Future<void> _detachPictureInPicture() async {
    if (!_usesNativeIosVideoView) return;
    await IosPictureInPictureService.detach();
  }

  Future<void> _startPictureInPictureIfNeeded() async {
    final controller = _videoPlayerController;
    if (!_usesNativeIosVideoView ||
        controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isPlaying ||
        _startingPictureInPicture) {
      return;
    }

    _startingPictureInPicture = true;
    try {
      await IosPictureInPictureService.attach(controller);
      final started = await IosPictureInPictureService.start();
      if (started && !controller.value.isPlaying) {
        await controller.play();
      }
    } finally {
      _startingPictureInPicture = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshConnectivity());
      unawaited(_refreshStatusHeader());

      unawaited(IosPictureInPictureService.stop());
      _syncPlaybackSideEffects(force: true);
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_saveWatchProgress(flushRemote: true));
      unawaited(_startPictureInPictureIfNeeded());
    }
  }

  String _nowPlayingSubtitle() {
    final episodeName = _historyEpisodeName(
      _selectedServerIndex,
      _currentEpisodeIndex,
    ).trim();
    final serverName = _friendlyCurrentServerLabel();

    if (widget.movie.episode_current == 'Full') {
      return serverName;
    }
    if (episodeName.isEmpty) return serverName;
    if (serverName.isEmpty) return episodeName;
    return '$episodeName - $serverName';
  }

  String _friendlyCurrentServerLabel() {
    var serverName = _currentServer.trim();
    if (serverName.isEmpty &&
        _selectedServerIndex >= 0 &&
        _selectedServerIndex < widget.episodes.length) {
      serverName = widget.episodes[_selectedServerIndex].server_name.trim();
    }

    final serverInfo = CoverMap.getConfigFromServerName(serverName);
    final title = serverInfo['title'];
    if (title is String && title.trim().isNotEmpty) return title.trim();
    return 'Phụ Đề';
  }

  String _currentLandscapePlaybackLine() {
    if (widget.movie.episode_current == 'Full') {
      return _friendlyCurrentServerLabel();
    }

    final episodeName = _historyEpisodeName(
      _selectedServerIndex,
      _currentEpisodeIndex,
    ).trim();
    if (episodeName.isNotEmpty) return episodeName;

    final fallback = widget.movie.episode_current.trim();
    if (fallback.isNotEmpty) return fallback;
    return 'Đang phát';
  }

  void _syncPlaybackSideEffects({bool force = false}) {
    final value = _videoPlayerController?.value;
    if (value == null) {
      PlaybackWakelock.unawaitedSetEnabled(false);
      return;
    }

    final isPlaying = value.isInitialized && value.isPlaying;
    PlaybackWakelock.unawaitedSetEnabled(isPlaying);

    if (!_usesNativeIosVideoView || !value.isInitialized) {
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
        title: widget.movieName,
        subtitle: _nowPlayingSubtitle(),
        duration: value.duration,
        position: value.position,
        isPlaying: isPlaying,
        assetUrl: _currentEpisodeLink,
      ),
    );
  }

  double get _seekbarHPad {
    // 0 -> 12 khi expand (tự mượt theo _expandT)
    final t = Curves.easeOut.transform(_expandT);
    return lerpDouble(0, 12, t)!;
  }

  double get _seekbarExtraLift {
    // nâng thêm một chút khi expand
    final t = Curves.easeOut.transform(_expandT);
    return lerpDouble(0, 10, t)!;
  }

  void _toggleLandscapeDrawer() {
    setState(() => _lsDrawerOpen = !_lsDrawerOpen);

    if (_lsDrawerOpen) {
      // mở xong thì scroll tới tập hiện tại
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _drawerKey.currentState?.scrollToCurrentEpisode(animated: false);
      });
    }
  }

  void _showControlsWithAutoHide() {
    if (_orientationChangeInFlight) return;

    _hideControlsTimer?.cancel();

    if (!_showControls && mounted) {
      setState(() {
        _showControls = true;
      });
    }

    // Khi đang tải hoặc có lỗi, giữ controls lại,
    // không tự ẩn sau 3 giây.
    if (_isPlayerLoading || _playerLoadError != null) {
      return;
    }

    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        _showControls = false;
      });
    });
  }

  void _hideControlsNow() {
    _hideControlsTimer?.cancel();
    if (!mounted) return;
    setState(() => _showControls = false);
  }

  void _toggleControls() {
    if (_orientationChangeInFlight) return;

    // Đang loading: tap luôn làm hiện controls,
    // không cho tap làm ẩn nút back.
    if (_isPlayerLoading || _playerLoadError != null) {
      _hideControlsTimer?.cancel();

      if (!_showControls) {
        setState(() {
          _showControls = true;
        });
      }

      return;
    }

    if (_showControls) {
      _hideControlsNow();
    } else {
      _showControlsWithAutoHide();
    }
  }

  void _resetLandscapeZoom() {
    _landscapeZoomLabelTimer?.cancel();
    _landscapeZoomSnapCtrl.stop();
    _landscapeZoomSnapCtrl.value = 0;
    _landscapePinchZooming = false;
    _landscapeAtOrAboveFill = false;
    if (!mounted) return;
    setState(() {
      _landscapeZoomScale = _landscapeZoomMin;
      _landscapeZoomStartScale = _landscapeZoomMin;
      _showLandscapeZoomLabel = false;
    });
  }

  double _landscapeFillScaleFor(Size viewport) {
    if (viewport.width <= 0 || viewport.height <= 0) return _landscapeZoomMin;

    final value = _videoPlayerController?.value;
    final aspectRatio =
        (value != null &&
            value.isInitialized &&
            value.aspectRatio.isFinite &&
            value.aspectRatio > 0)
        ? value.aspectRatio
        : 16 / 9;

    final fittedWidth = math.min(viewport.width, viewport.height * aspectRatio);
    if (fittedWidth <= 0) return _landscapeZoomMin;

    return (viewport.width / fittedWidth).clamp(
      _landscapeZoomMin,
      _landscapeZoomMax,
    );
  }

  bool _shouldShowLandscapeBlur(double fillScale) {
    return _landscapeZoomScale < fillScale - 0.001;
  }

  void _triggerLandscapeBoundaryFeedback() {
    HapticFeedback.lightImpact();
    _landscapeZoomSnapCtrl.forward(from: 0);
  }

  void _handleLandscapeScaleStart(ScaleStartDetails details, double fillScale) {
    if (details.pointerCount < 2) return;
    _landscapeZoomLabelTimer?.cancel();
    _hideControlsTimer?.cancel();
    setState(() {
      _landscapePinchZooming = true;
      _landscapeZoomStartScale = _landscapeZoomScale;
      _showLandscapeZoomLabel = true;
      _landscapeAtOrAboveFill = _landscapeZoomScale >= fillScale;
      _landscapeControlsVisibleBeforeZoom = _showControls;
    });
  }

  void _handleLandscapeScaleUpdate(
    ScaleUpdateDetails details,
    double fillScale,
  ) {
    if (details.pointerCount < 2) return;

    if (!_landscapePinchZooming) {
      _landscapePinchZooming = true;
      _landscapeZoomStartScale = _landscapeZoomScale;
      _landscapeAtOrAboveFill = _landscapeZoomScale >= fillScale;
    }

    final nextScale = (_landscapeZoomStartScale * details.scale).clamp(
      _landscapeZoomMin,
      _landscapeZoomMax,
    );
    final nextAtOrAboveFill = nextScale >= fillScale;
    final crossedFillBoundary = nextAtOrAboveFill != _landscapeAtOrAboveFill;

    setState(() {
      _landscapeZoomScale = nextScale;
      _showLandscapeZoomLabel = true;
      _landscapeAtOrAboveFill = nextAtOrAboveFill;
    });

    if (crossedFillBoundary) {
      _triggerLandscapeBoundaryFeedback();
    }
  }

  void _handleLandscapeScaleEnd(ScaleEndDetails details) {
    if (!_landscapePinchZooming) return;

    _landscapePinchZooming = false;
    if (_landscapeZoomScale <= 1.01) {
      setState(() {
        _landscapeZoomScale = _landscapeZoomMin;
        _landscapeAtOrAboveFill = false;
      });
    }

    _landscapeZoomLabelTimer?.cancel();
    _landscapeZoomLabelTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() => _showLandscapeZoomLabel = false);
    });
    if (_landscapeControlsVisibleBeforeZoom) {
      _resetHideControlsTimer();
    }
  }

  String get _landscapeZoomText => '${_landscapeZoomScale.toStringAsFixed(1)}x';

  // 2) icon theo trạng thái
  IconData get _portraitExpandIcon {
    if (_isFullscreen)
      return Icons.fullscreen_exit; // đang landscape fullscreen
    if (_isExpandedPortrait)
      return Icons.screen_rotation; // đang fullscreen dọc -> chuyển sang ngang
    return Icons.open_in_full; // chưa fullscreen dọc -> expand dọc
  }

  // 3) hành vi theo trạng thái
  void _onPortraitExpandPressed() {
    if (_isFullscreen) {
      _toggleFullscreen(); // thoát landscape
      return;
    }

    if (_isExpandedPortrait) {
      _toggleFullscreen(); // đang fullscreen dọc -> xoay ngang
    } else {
      _animateVideoHeightTo(
        _maxVideoHeight,
      ); // chưa fullscreen dọc -> expand dọc
      _resetHideControlsTimer();
    }
  }

  void _resetHideControlsTimer() {
    _showControlsWithAutoHide();
  }

  Future<void> _saveWatchProgress({
    bool useCurrentPlaybackPosition = true,
    bool preserveExistingProgressWhenUnavailable = true,
    bool flushRemote = false,
  }) {
    final videoValue = _videoPlayerController?.value;
    final hasPlaybackPosition =
        useCurrentPlaybackPosition && (videoValue?.isInitialized ?? false);
    final positionMs = hasPlaybackPosition
        ? videoValue!.position.inMilliseconds
        : 0;
    final durationMs = hasPlaybackPosition
        ? videoValue!.duration.inMilliseconds
        : 0;
    final serverIndex = _selectedServerIndex;
    final episodeIndex = _currentEpisodeIndex;
    final episodeLink = _currentEpisodeLink;
    final serverName = _currentServer;
    final episodeName = _historyEpisodeName(serverIndex, episodeIndex);
    final category = widget.movie.category.isNotEmpty
        ? widget.movie.category.first
        : null;
    final library = _libraryCubit;
    if (library == null) return Future<void>.value();

    final write = _historyWriteQueue
        .then((_) async {
          if (library.state.isAuthenticated) {
            UserWatchHistory? existing;
            for (final item in library.state.history) {
              if (item.slug == widget.slug) {
                existing = item;
                break;
              }
            }
            final preserve =
                !hasPlaybackPosition && preserveExistingProgressWhenUnavailable;
            library.queueWatchHistory(
              UserWatchHistory(
                slug: widget.slug,
                name: widget.movieName,
                originName: widget.movie.origin_name,
                posterUrl: widget.movie.poster_url,
                thumbUrl: widget.movie.thumb_url,
                episodeCurrent: episodeName,
                quality: widget.movie.quality,
                lang: widget.movie.lang,
                year: widget.movie.year,
                rating: widget.movie.tmdb?.vote_average?.toDouble(),
                positionMs: preserve ? existing?.positionMs ?? 0 : positionMs,
                durationMs: preserve ? existing?.durationMs ?? 0 : durationMs,
                movieType: widget.movie.type,
                categoryId: category?.id,
                categoryName: category?.name,
                lastServerIndex: serverIndex,
                lastEpisodeIndex: episodeIndex,
                lastEpisodeName: episodeName,
                lastEpisodeLink: episodeLink,
                lastServerName: serverName,
                watchedAt: DateTime.now(),
              ),
              flush: flushRemote,
            );
          }

          debugPrint(
            '[WatchHistory] Saved: slug=${widget.slug}, server=$serverName, episode=$episodeName, positionMs=$positionMs',
          );
        })
        .catchError((Object error, StackTrace stack) {
          debugPrint('[WatchHistory] Write failed: $error');
        });

    _historyWriteQueue = write;
    return write;
  }

  String _historyEpisodeName(int serverIndex, int episodeIndex) {
    final fallback = widget.movie.episode_current.isNotEmpty
        ? widget.movie.episode_current
        : 'Full';

    if (widget.episodes.isEmpty ||
        serverIndex < 0 ||
        serverIndex >= widget.episodes.length) {
      return fallback;
    }

    final serverData = widget.episodes[serverIndex].server_data;
    if (episodeIndex < 0 || episodeIndex >= serverData.length) {
      return fallback;
    }

    return serverData[episodeIndex].name;
  }

  void _startSaveProgressTimer() {
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(_saveWatchProgress());
    });
  }

  Future<void> _initializePlayer(String videoUrl) async {
    final generation = ++_playerInitGeneration;
    final sourceUrl = videoUrl.trim();
    if (mounted) {
      setState(() {
        _isVideoLoading = true;
        _isPlaybackBuffering = false;
        _playerLoadError = null;
        _showControls = true;
      });
    }

    if (sourceUrl.isEmpty) {
      PlaybackWakelock.unawaitedSetEnabled(false);
      unawaited(IosNowPlayingService.clear());
      if (!mounted || generation != _playerInitGeneration) return;
      setState(() {
        _isVideoLoading = false;
        _playerLoadError = 'Server này chưa có nguồn phát.';
      });
      return;
    }

    VideoPlayerController? videoController;

    try {
      videoController = _createVideoPlayerController(sourceUrl);
      await videoController.initialize();
    } catch (error) {
      try {
        await videoController?.dispose();
      } catch (_) {}
      PlaybackWakelock.unawaitedSetEnabled(false);
      unawaited(IosNowPlayingService.clear());
      if (!mounted || generation != _playerInitGeneration) return;
      setState(() {
        _isVideoLoading = false;
        _playerLoadError = 'Không tải được nguồn phim này.';
      });
      debugPrint('InitializePlayer failed: $error');
      return;
    }

    if (!mounted || generation != _playerInitGeneration) {
      await videoController.dispose();
      return;
    }

    final initializedVideoController = videoController;

    _videoPlayerController = initializedVideoController;

    UserWatchHistory? savedProgress;
    final libraryState = _libraryCubit?.state;
    if (libraryState?.isAuthenticated ?? false) {
      for (final history in libraryState!.history) {
        if (history.slug == widget.slug &&
            history.lastServerIndex == _selectedServerIndex &&
            history.lastEpisodeIndex == _currentEpisodeIndex &&
            history.progress < .9) {
          savedProgress = history;
          break;
        }
      }
    }

    if (!mounted || generation != _playerInitGeneration) {
      await initializedVideoController.dispose();
      return;
    }

    final chewieController = ChewieController(
      videoPlayerController: initializedVideoController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: true,
      showControls: false,
      fullScreenByDefault: false,
    );

    _chewieController = chewieController;
    widget.overlayController?.attachPlaybackController(
      initializedVideoController,
      owner: this,
    );

    debugPrint('=== Video initialized ===');

    if (savedProgress != null) {
      final savedPosition = Duration(milliseconds: savedProgress.positionMs);
      await initializedVideoController.seekTo(savedPosition);
      debugPrint(
        'Restored progress: ${savedPosition.inSeconds}s / ${savedProgress.progress * 100}%',
      );
    }

    // Setup video listeners after player is initialized
    _attachVpListeners();
    await _attachPictureInPicture();
    _syncPlaybackSideEffects(force: true);

    if (!mounted || generation != _playerInitGeneration) return;
    _startSaveProgressTimer();
    unawaited(_saveWatchProgress());
    setState(() {
      _isVideoLoading = false;
      _playerLoadError = null;
    });
  }

  Future<void> _disposeAndInitializePlayer(
    String videoUrl, {
    bool restoreLastPosition = false,
  }) async {
    final generation = ++_playerInitGeneration;
    final sourceUrl = videoUrl.trim();
    widget.overlayController?.updatePlaybackIdentity(
      episodeLink: sourceUrl,
      episodeIndex: _currentEpisodeIndex,
      server: _currentServer,
      serverIndex: _selectedServerIndex,
    );
    debugPrint(
      '_disposeAndInitializePlayer: START, restoreLastPosition=$restoreLastPosition, _lastPosition=$_lastPosition',
    );

    _removeVpListeners();
    _hideControlsTimer?.cancel();
    _seekOverlayTimer?.cancel();
    _seekThrottle?.cancel();
    PlaybackWakelock.unawaitedSetEnabled(false);

    final oldChewieController = _chewieController;
    final oldVideoPlayerController = _videoPlayerController;
    widget.overlayController?.detachPlaybackController(owner: this);

    if (mounted) {
      setState(() {
        _chewieController = null;
        _videoPlayerController = null;
        _showControls = true;
        _isPlaybackCompleted = false;
        _showSeekOverlay = false;
        _isScrubbing = false;
        _scrubValue = 0.0;
        _isVideoLoading = true;
        _isPlaybackBuffering = false;
        _playerLoadError = null;
      });
    } else {
      _chewieController = null;
      _videoPlayerController = null;
    }

    await oldChewieController?.pause();
    await _detachPictureInPicture();
    oldChewieController?.dispose();
    await oldVideoPlayerController?.dispose();

    if (sourceUrl.isEmpty) {
      unawaited(IosNowPlayingService.clear());
      if (!mounted || generation != _playerInitGeneration) return;
      setState(() {
        _isVideoLoading = false;
        _playerLoadError = 'Server này chưa có nguồn phát.';
      });
      return;
    }

    debugPrint(
      '_disposeAndInitializePlayer: Creating VideoPlayerController with $sourceUrl',
    );
    VideoPlayerController? videoController;
    try {
      videoController = _createVideoPlayerController(sourceUrl);
      await videoController.initialize();
    } catch (error) {
      try {
        await videoController?.dispose();
      } catch (_) {}
      PlaybackWakelock.unawaitedSetEnabled(false);
      unawaited(IosNowPlayingService.clear());
      if (!mounted || generation != _playerInitGeneration) return;
      setState(() {
        _isVideoLoading = false;
        _playerLoadError = 'Không tải được nguồn phim này.';
      });
      debugPrint('_disposeAndInitializePlayer failed: $error');
      return;
    }
    debugPrint('_disposeAndInitializePlayer: Video initialized');

    final initializedVideoController = videoController;

    if (!mounted || generation != _playerInitGeneration) {
      await initializedVideoController.dispose();
      return;
    }

    final chewieController = ChewieController(
      videoPlayerController: initializedVideoController,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      allowFullScreen: false,
      allowMuting: true,
      showControls: false,
      fullScreenByDefault: false,
    );
    _videoPlayerController = initializedVideoController;
    _chewieController = chewieController;
    widget.overlayController?.attachPlaybackController(
      initializedVideoController,
      owner: this,
    );
    debugPrint('_disposeAndInitializePlayer: ChewieController created');

    debugPrint(
      '_disposeAndInitializePlayer: Before seek, _lastPosition=$_lastPosition, restoreLastPosition=$restoreLastPosition',
    );

    setState(() {});

    if (restoreLastPosition && _lastPosition != null) {
      debugPrint('RestorePosition: Seeking to $_lastPosition');
      await initializedVideoController.seekTo(_lastPosition!);
      final posAfterSeek = initializedVideoController.value.position;
      debugPrint(
        'RestorePosition: Seek completed, position after seek: $posAfterSeek',
      );
      await Future.delayed(const Duration(milliseconds: 200));
      await chewieController.play();
      final posAfterPlay = initializedVideoController.value.position;
      debugPrint('RestorePosition: After play, position: $posAfterPlay');
    } else {
      debugPrint(
        'RestorePosition: Not restoring, _lastPosition=$_lastPosition, restoreLastPosition=$restoreLastPosition',
      );
      await chewieController.play();
    }

    if (!mounted || generation != _playerInitGeneration) return;
    _lastPosition = null;
    debugPrint('_disposeAndInitializePlayer: END, cleared _lastPosition');

    // Setup video listeners after new episode is loaded
    _attachVpListeners();
    await _attachPictureInPicture();
    _syncPlaybackSideEffects(force: true);

    if (!mounted || generation != _playerInitGeneration) return;
    _startSaveProgressTimer();
    unawaited(_saveWatchProgress());
    setState(() {
      _isVideoLoading = false;
      _playerLoadError = null;
    });
  }

  void _showAutoPlayToast(bool enabled) {
    _autoToastTimer?.cancel();

    setState(() {
      _autoToastText = enabled ? 'Đã bật tự động phát' : 'Đã tắt tự động phát';
      _showAutoToast = true;
    });

    _autoToastTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _showAutoToast = false);
    });
  }

  void _playEpisode(int index, EpisodesModel episode) {
    if (episode.server_data.isEmpty) return;

    // Lưu chính xác nội dung cũ trước khi chuyển sang tập mới.
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      _lastPosition = _videoPlayerController!.value.position;
    }
    unawaited(_saveWatchProgress());

    final episodeData = index < episode.server_data.length
        ? episode.server_data[index]
        : episode.server_data.first;

    final link = episodeData.link_m3u8.isNotEmpty
        ? episodeData.link_m3u8
        : episodeData.link_embed;

    setState(() {
      _isPlaybackCompleted = false;
      _currentEpisodeIndex = index;
      _currentServer = episode.server_name;
      _currentEpisodeLink = link;
      _videoHeight = _minVideoHeight;
    });
    unawaited(
      _saveWatchProgress(
        useCurrentPlaybackPosition: false,
        preserveExistingProgressWhenUnavailable: false,
      ),
    );
    _scrollToCurrentEpisode();
    _lastPosition = null; // <<< quan trọng: không carry qua tập mới
    _disposeAndInitializePlayer(link, restoreLastPosition: false);
  }

  void _removeVpListeners() {
    final vp = _videoPlayerController;
    if (vp == null) return;

    if (_vpPositionListener != null) vp.removeListener(_vpPositionListener!);
    if (_vpEndListener != null) vp.removeListener(_vpEndListener!);

    _vpPositionListener = null;
    _vpEndListener = null;
  }

  void _animateVideoHeightTo(double target) {
    _videoSnapTarget = target;

    _videoSnapCtrl.stop();
    _videoSnapAnim?.removeListener(_onSnapTick);

    if (_snapStatusListener != null) {
      _videoSnapCtrl.removeStatusListener(_snapStatusListener!);
    }

    _videoSnapAnim = Tween<double>(begin: _videoHeight, end: target).animate(
      CurvedAnimation(parent: _videoSnapCtrl, curve: Curves.easeOutCubic),
    )..addListener(_onSnapTick);

    _snapStatusListener = (status) {
      if (status == AnimationStatus.completed &&
          mounted &&
          _videoSnapTarget != null) {
        setState(() {
          _videoHeight = _videoSnapTarget!;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _syncPlayerSystemUi();
          }
        });
      }
    };
    _videoSnapCtrl.addStatusListener(_snapStatusListener!);

    _videoSnapCtrl.forward(from: 0);
  }

  void _onSnapTick() {
    if (!mounted) return;
    setState(() {
      _videoHeight = _videoSnapAnim!.value;
    });
  }

  void _panelResizeByDy(double dy) {
    // dy > 0: kéo xuống -> tăng videoHeight (expand)
    final next = (_videoHeight + dy).clamp(_minVideoHeight, _maxVideoHeight);
    if (next == _videoHeight) return;
    setState(() => _videoHeight = next);
  }

  void _panelResizeEnd({double velocity = 0, double dragDy = 0}) {
    const snapT = 0.55; // ngưỡng theo vị trí
    const dragGate = 60.0; // ngưỡng theo quãng kéo

    // fling mạnh -> theo velocity
    if (velocity.abs() > 900) {
      _animateVideoHeightTo(velocity > 0 ? _maxVideoHeight : _minVideoHeight);
      return;
    }

    // kéo đủ xa -> theo hướng kéo
    if (dragDy > dragGate) {
      _animateVideoHeightTo(_maxVideoHeight); // kéo xuống => expand
      return;
    }
    if (dragDy < -dragGate) {
      _animateVideoHeightTo(_minVideoHeight); // kéo lên => collapse
      return;
    }

    // không đủ xa -> theo vị trí hiện tại
    _animateVideoHeightTo(
      _expandT >= snapT ? _maxVideoHeight : _minVideoHeight,
    );
  }

  void _attachVpListeners() {
    final vp = _videoPlayerController;
    if (vp == null) return;

    _removeVpListeners();
    _isPlaybackBuffering = vp.value.isBuffering;

    // _vpPositionListener = () {
    //   if (!mounted) return;
    //   setState(() {});
    // };
    // vp.addListener(_vpPositionListener!);

    _autoPlayTriggered = false;
    _vpEndListener = () {
      if (!mounted) return;

      final value = vp.value;
      final isBuffering = value.isBuffering && !value.hasError;

      if (_isPlaybackBuffering != isBuffering) {
        if (isBuffering) {
          _hideControlsTimer?.cancel();
        }

        setState(() {
          _isPlaybackBuffering = isBuffering;

          if (isBuffering) {
            // Giữ header, back và control bar.
            _showControls = true;
            _showSeekOverlay = false;
          }
        });

        // Mạng ổn trở lại thì bắt đầu đếm 3 giây để ẩn controls.
        if (!isBuffering) {
          _resetHideControlsTimer();
        }
      }

      _syncPlaybackSideEffects();
      final isCompleted =
          value.isInitialized &&
          !value.isPlaying &&
          value.duration > Duration.zero &&
          value.position >= value.duration - const Duration(seconds: 1);

      if (isCompleted && !_autoPlayTriggered) {
        _autoPlayTriggered = true;
        final state = _playerCubit.state;
        final shouldAutoPlayNext =
            state is PlayerLoadedState &&
            state.autoPlayNextEpisode &&
            widget.movie.episode_current != 'Full';

        if (shouldAutoPlayNext && _hasNextEpisode) {
          _playNextEpisode();
          return;
        }

        if (shouldAutoPlayNext) _playNextEpisode();
        _setPlaybackCompleted(true);
      }

      if (!isCompleted && _isPlaybackCompleted) {
        _setPlaybackCompleted(false);
      }

      if (value.isPlaying) {
        _autoPlayTriggered = false;
      }
    };
    vp.addListener(_vpEndListener!);
    _syncPlaybackSideEffects(force: true);
  }

  bool get _hasNextEpisode {
    if (_selectedServerIndex < 0 ||
        _selectedServerIndex >= widget.episodes.length) {
      return false;
    }
    final serverData = widget.episodes[_selectedServerIndex].server_data;
    return _currentEpisodeIndex >= 0 &&
        _currentEpisodeIndex < serverData.length - 1;
  }

  void _setPlaybackCompleted(bool completed) {
    if (!mounted || _isPlaybackCompleted == completed) return;
    if (completed) _hideControlsTimer?.cancel();
    setState(() {
      _isPlaybackCompleted = completed;
      if (completed) _showControls = true;
    });
  }

  void _playNextEpisode() {
    final currentServer = widget.episodes[_selectedServerIndex];
    final serverData = currentServer.server_data;

    if (_currentEpisodeIndex < serverData.length - 1) {
      _playEpisode(_currentEpisodeIndex + 1, currentServer);

      _playerCubit.updateCurrentEpisode(
        widget.slug,
        _currentEpisodeIndex,
        _selectedServerIndex,
      );

      // if (mounted) {
      //   toastification.show(

      //     context: context, // optional if you use ToastificationWrapper
      //     title: Text(
      //       'Đang chuyển sang tập \ ${_currentEpisodeIndex + 1}',
      //       style: const TextStyle(color: Colors.black),
      //     ),
      //     autoCloseDuration: const Duration(seconds: 2),
      //   );
      //   // ScaffoldMessenger.of(context).showSnackBar(
      //   //   SnackBar(
      //   //     content: Text(
      //   //       'Đang chuyển sang tập \ $_currentEpisodeIndex + 1}',
      //   //       style: const TextStyle(color: Colors.black),
      //   //     ),
      //   //     backgroundColor: const Color(0xFFC77DFF),
      //   //     duration: const Duration(seconds: 2),
      //   //   ),
      //   // );
      // }
    } else {
      if (mounted) {
        toastification.show(
          context: context, // optional if you use ToastificationWrapper
          title: Text(
            'Đã hết tập phim',
            style: const TextStyle(color: Colors.black),
          ),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    }
  }

  void _playPreviousEpisode() {
    final currentServer = widget.episodes[_selectedServerIndex];
    final serverData = currentServer.server_data;

    if (_currentEpisodeIndex > 0) {
      _playEpisode(_currentEpisodeIndex - 1, currentServer);

      _playerCubit.updateCurrentEpisode(
        widget.slug,
        _currentEpisodeIndex,
        _selectedServerIndex,
      );
    } else {
      toastification.show(
        context: context,
        title: const Text(
          'Đây là tập đầu tiên',
          style: TextStyle(color: Colors.black),
        ),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  void _scrollToCurrentEpisode({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final serverData = widget.episodes[_selectedServerIndex].server_data;

      if (serverData.isEmpty) return;

      final index = _currentEpisodeIndex.clamp(0, serverData.length - 1);

      if (_episodeKeys.length <= index) return;

      final itemContext = _episodeKeys[index].currentContext;
      if (itemContext == null) return;

      // Đánh dấu đây là scroll bằng code.
      // Trong thời gian này không được co thanh server.
      _isProgrammaticEpisodeScroll = true;
      _isEpisodeUserDragging = false;

      final scrollFuture = Scrollable.ensureVisible(
        itemContext,
        duration: animated ? const Duration(milliseconds: 350) : Duration.zero,
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );

      scrollFuture.whenComplete(() {
        // Đợi ScrollNotification cuối cùng chạy xong rồi mới mở lại.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          _isProgrammaticEpisodeScroll = false;

          if (_episodeScrollController.hasClients) {
            _lastEpisodeScrollPixels = _episodeScrollController.position.pixels;
          }
        });
      });
    });
  }

  bool _handleEpisodeScrollNotification(ScrollNotification notification) {
    // Chỉ xử lý scroll chính của danh sách tập.
    // Không xử lý các ListView con hoặc scroll ngang.
    if (notification.depth != 0) {
      return false;
    }

    if (notification is ScrollStartNotification) {
      _lastEpisodeScrollPixels = notification.metrics.pixels;

      // dragDetails != null nghĩa là người dùng đang đặt tay vuốt.
      _isEpisodeUserDragging =
          notification.dragDetails != null && !_isProgrammaticEpisodeScroll;

      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final currentPixels = notification.metrics.pixels;

      final delta =
          notification.scrollDelta ?? currentPixels - _lastEpisodeScrollPixels;

      _lastEpisodeScrollPixels = currentPixels;

      // ensureVisible, animateTo hoặc jumpTo:
      // chỉ cuộn grid, không thay đổi thanh server.
      if (!_isEpisodeUserDragging ||
          _isProgrammaticEpisodeScroll ||
          delta.abs() < 0.01) {
        return false;
      }

      final oldExtent = _seriesControlsExtent;

      // Vuốt lên:
      // delta > 0 => extent giảm => thanh ngăn nâng lên.
      //
      // Vuốt xuống:
      // delta < 0 => extent tăng => thanh server hiện lại.
      final nextExtent = (oldExtent - delta)
          .clamp(1.0, _seriesControlsMaxH)
          .toDouble();

      if ((nextExtent - oldExtent).abs() > 0.1) {
        setState(() {
          _seriesControlsExtent = nextExtent;
        });
      }

      final atTop =
          notification.metrics.pixels <=
          notification.metrics.minScrollExtent + 0.5;

      final isExpandingControls =
          delta < 0 &&
          oldExtent < _seriesControlsMaxH &&
          nextExtent > oldExtent;

      // Khi đang ở đầu list và kéo xuống để mở lại thanh server,
      // chặn notification đi tới _wrapOverscrollToResize.
      // Như vậy nó mở thanh server trước, chưa kéo giãn video.
      return atTop && isExpandingControls;
    }

    if (notification is OverscrollNotification) {
      if (!_isEpisodeUserDragging || _isProgrammaticEpisodeScroll) {
        return false;
      }

      // Kéo xuống ở đầu list khi thanh server chưa mở hết.
      if (notification.overscroll < 0 &&
          _seriesControlsExtent < _seriesControlsMaxH) {
        final nextExtent = (_seriesControlsExtent - notification.overscroll)
            .clamp(1.0, _seriesControlsMaxH)
            .toDouble();

        if ((nextExtent - _seriesControlsExtent).abs() > 0.1) {
          setState(() {
            _seriesControlsExtent = nextExtent;
          });
        }

        // Chặn outer listener kéo giãn video trong lúc
        // thanh server vẫn đang được mở lại.
        return true;
      }

      return false;
    }

    if (notification is ScrollEndNotification) {
      _isEpisodeUserDragging = false;
      return false;
    }

    if (notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle) {
      _isEpisodeUserDragging = false;
    }

    return false;
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
    unawaited(_saveWatchProgress());

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
    unawaited(
      _saveWatchProgress(
        useCurrentPlaybackPosition: isSingleType,
        preserveExistingProgressWhenUnavailable: false,
      ),
    );
    _scrollToCurrentEpisode();
    _disposeAndInitializePlayer(
      link,
      restoreLastPosition: shouldRestorePosition,
    );
  }

  Future<void> _toggleFullscreen() async {
    if (_orientationChangeInFlight) return;

    final targetLandscape =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    _hideControlsTimer?.cancel();
    _orientationChangeFallbackTimer?.cancel();
    setState(() {
      _orientationChangeInFlight = true;
      _showControls = false;
      _showSeekOverlay = false;
    });

    _orientationChangeFallbackTimer = Timer(
      const Duration(milliseconds: 1200),
      () {
        if (!mounted || !_orientationChangeInFlight) return;
        setState(() => _orientationChangeInFlight = false);
      },
    );

    try {
      if (targetLandscape) {
        await SupportRotateScreen.onlyLandscape();
      } else {
        await SupportRotateScreen.onlyPotrait();
      }
    } on PlatformException catch (error) {
      debugPrint('Không thể đổi hướng màn hình: $error');
      _orientationChangeFallbackTimer?.cancel();
      if (!mounted) return;
      setState(() => _orientationChangeInFlight = false);
    }
  }

  void _syncFullscreenWithOrientation(Orientation orientation) {
    final shouldBeFullscreen = orientation == Orientation.landscape;
    if (_isFullscreen == shouldBeFullscreen && !_orientationChangeInFlight) {
      return;
    }
    _pendingOrientationSync = orientation;
    if (_orientationSyncScheduled) return;
    _orientationSyncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orientationSyncScheduled = false;
      final orientationToSync = _pendingOrientationSync ?? orientation;
      _pendingOrientationSync = null;
      if (!mounted) return;

      final fullscreen = orientationToSync == Orientation.landscape;
      _orientationChangeFallbackTimer?.cancel();
      setState(() {
        _isFullscreen = fullscreen;
        _orientationChangeInFlight = false;
        _showControls = false;
        _showSeekOverlay = false;
      });
      _syncPlayerSystemUi();
    });
  }

  Widget _buildStablePlayerSurface(ChewieController controller) {
    return RepaintBoundary(
      key: _playerSurfaceKey,
      child: Chewie(key: ObjectKey(controller), controller: controller),
    );
  }

  Future<void> _togglePlayPause() async {
    final vp = _videoPlayerController;

    if (vp == null || !vp.value.isInitialized) {
      return;
    }

    // Đang buffering thì nút giữa đang là spinner,
    // không xử lý play/pause.
    if (vp.value.isBuffering || _isPlaybackBuffering) {
      return;
    }

    if (_isPlaybackCompleted) {
      _autoPlayTriggered = true;

      await vp.seekTo(Duration.zero);

      if (!mounted) return;

      _setPlaybackCompleted(false);
      await vp.play();

      _autoPlayTriggered = false;
    } else if (vp.value.isPlaying) {
      await vp.pause();
    } else {
      await vp.play();
    }

    if (!mounted) return;

    // Bảo đảm những widget ngoài ValueListenableBuilder
    // cũng nhận được trạng thái mới.
    setState(() {});

    _resetHideControlsTimer();
  }

  void _retryCurrentVideo() {
    final sourceUrl = _currentEpisodeLink?.trim();
    if (sourceUrl == null || sourceUrl.isEmpty) return;
    unawaited(_disposeAndInitializePlayer(sourceUrl));
  }

  Widget _buildPlayerError(String message) {
    final canRetry = _currentEpisodeLink?.trim().isNotEmpty ?? false;

    return Semantics(
      liveRegion: true,
      label: message,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.signal_wifi_connected_no_internet_4_rounded,
                color: Colors.white70,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (canRetry) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _retryCurrentVideo,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Thử lại'),
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColor.secondColor,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStatus(String message, {bool dimBackground = false}) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: ColoredBox(
        color: dimBackground
            ? Colors.black.withValues(alpha: 0.24)
            : Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.68),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColor.secondColor,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCommentsSheet(BuildContext providerContext) {
    if (_commentsOverlayEntry != null) return;

    final videoContext = _videoBoxKey.currentContext;
    final videoBox = videoContext?.findRenderObject() as RenderBox?;

    if (videoBox == null || !videoBox.hasSize) return;

    // Vị trí video trên toàn màn hình
    final videoPosition = videoBox.localToGlobal(Offset.zero);
    final videoBottom = videoPosition.dy + videoBox.size.height;

    final screenHeight = MediaQuery.sizeOf(providerContext).height;

    // Bottom sheet chỉ cao từ mép dưới video đến đáy màn hình
    final sheetHeight = (screenHeight - videoBottom)
        .clamp(0.0, screenHeight)
        .toDouble();
    if (sheetHeight <= 1) return;

    FocusScope.of(providerContext).unfocus();
    final commentsCubit = providerContext.read<CommentsCubit>();
    final overlay = Overlay.maybeOf(providerContext);
    if (overlay == null) return;

    _commentsSheetHeight = sheetHeight;
    _commentsSheetPresentationStarted = false;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => BlocProvider.value(
        value: commentsCubit,
        child: _buildCommentsNavigator(
          commentsCubit: commentsCubit,
          overlayEntry: entry,
        ),
      ),
    );
    _commentsOverlayEntry = entry;
    overlay.insert(entry);
  }

  bool _dismissCommentsOverlay() {
    if (_commentsOverlayEntry == null) return false;

    final commentsNavigator = _commentsNavigatorKey.currentState;
    if (commentsNavigator?.canPop() ?? false) {
      commentsNavigator!.pop();
      return true;
    }

    _removeCommentsOverlayEntry();
    return true;
  }

  void _removeCommentsOverlayEntry() {
    final entry = _commentsOverlayEntry;
    if (entry == null) return;
    _commentsOverlayEntry = null;
    _commentsSheetPresentationStarted = false;
    entry.remove();
    entry.dispose();
  }

  Widget _buildCommentsNavigator({
    required CommentsCubit commentsCubit,
    required OverlayEntry overlayEntry,
  }) {
    return Positioned.fill(
      child: HeroControllerScope.none(
        child: Navigator(
          key: _commentsNavigatorKey,
          onGenerateRoute: (_) => PageRouteBuilder<void>(
            settings: const RouteSettings(name: 'movie-comments-overlay'),
            opaque: false,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (context, animation, secondaryAnimation) {
              if (!_commentsSheetPresentationStarted) {
                _commentsSheetPresentationStarted = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted ||
                      !identical(_commentsOverlayEntry, overlayEntry) ||
                      !context.mounted) {
                    return;
                  }
                  unawaited(
                    _presentCommentsSheet(
                      context,
                      commentsCubit: commentsCubit,
                      overlayEntry: overlayEntry,
                    ),
                  );
                });
              }
              return const Material(
                type: MaterialType.transparency,
                child: SizedBox.expand(),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _presentCommentsSheet(
    BuildContext navigatorContext, {
    required CommentsCubit commentsCubit,
    required OverlayEntry overlayEntry,
  }) async {
    final disableAnimations =
        MediaQuery.maybeOf(navigatorContext)?.disableAnimations ?? false;
    final animationStyle = disableAnimations
        ? const AnimationStyle(
            duration: Duration.zero,
            reverseDuration: Duration.zero,
          )
        : const AnimationStyle(
            duration: Duration(milliseconds: 240),
            reverseDuration: Duration(milliseconds: 180),
          );

    await showModalBottomSheet<void>(
      context: navigatorContext,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      sheetAnimationStyle: animationStyle,
      builder: (_) => BlocProvider.value(
        value: commentsCubit,
        child: SizedBox(
          height: _commentsSheetHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Material(
              color: const Color(0xff191A24),
              child: Column(
                children: [
                  Semantics(
                    label: 'Kéo xuống để đóng bình luận',
                    child: SizedBox(
                      height: 22,
                      child: Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(child: CommentsTab()),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (mounted && identical(_commentsOverlayEntry, overlayEntry)) {
      _removeCommentsOverlayEntry();
    }
  }

  Widget _buildPlayerPlaceholder() {
    final errorText = _playerLoadError;

    if (errorText != null) {
      return _buildPlayerError(errorText);
    }

    // Spinner đã nằm ở vị trí nút play/pause.
    return const ColoredBox(color: Colors.black);
  }

  Widget _buildPlaybackStatusOverlay() {
    final controller = _videoPlayerController;

    if (controller == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (!value.hasError) {
          return const SizedBox.shrink(key: ValueKey('playback-ready'));
        }

        return KeyedSubtree(
          key: const ValueKey('playback-error'),
          child: _buildPlayerError('Không thể phát video. Vui lòng thử lại.'),
        );
      },
    );
  }

  void _collapseVideo() {
    if (_videoHeight >= _maxVideoHeight - 100) {
      setState(() {
        _videoHeight = _minVideoHeight;
        _isExpanded = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncPlayerSystemUi();
        }
      });
    }
  }

  Future<void> _enterMiniPlayer() async {
    if (_chewieController == null) return;

    unawaited(_saveWatchProgress());
    _isFullscreen = false;
    _resetLandscapeZoom();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SupportRotateScreen.onlyPotrait();
    if (!mounted) return;

    final overlayController = widget.overlayController;
    if (overlayController != null) {
      overlayController.minimize();
      return;
    }

    if (context.canPop()) context.pop();
  }

  Future<void> _seekTo(double position) async {
    final controller = _chewieController;
    if (controller == null) return;

    final duration = controller.videoPlayerController.value.duration;
    final newPosition = Duration(
      milliseconds: (position * duration.inMilliseconds).round(),
    );
    await controller.seekTo(newPosition);
  }

  double? _seekFractionFromLocal(double localDx, double width) {
    if (width <= 0) {
      return null;
    }

    return (localDx / width).clamp(0.0, 1.0).toDouble();
  }

  Duration _seekTargetForFraction(VideoPlayerValue value, double fraction) {
    final durationMs = value.duration.inMilliseconds;
    if (durationMs <= 0) return Duration.zero;

    return Duration(milliseconds: (durationMs * fraction).round());
  }

  void _startSeekbarDrag(
    double localDx,
    double width, {
    required bool keepControlsVisible,
  }) {
    final vp = _videoPlayerController;
    if (vp == null || !vp.value.isInitialized) return;

    final fraction = _seekFractionFromLocal(localDx, width);
    if (fraction == null) return;

    final target = _seekTargetForFraction(vp.value, fraction);

    _hideControlsTimer?.cancel();
    _seekThrottle?.cancel();
    _wasPlayingBeforeScrub = vp.value.isPlaying;

    setState(() {
      _showControls = keepControlsVisible;
      _isScrubbing = true;
      _scrubValue = fraction;
      _previewPosition = target;
    });

    _seekToThrottled(target, ms: 45);
  }

  void _updateSeekbarDrag(double localDx, double width) {
    final vp = _videoPlayerController;
    if (vp == null || !vp.value.isInitialized) return;

    final fraction = _seekFractionFromLocal(localDx, width);
    if (fraction == null) return;

    final target = _seekTargetForFraction(vp.value, fraction);

    setState(() {
      _scrubValue = fraction;
      _previewPosition = target;
    });

    _seekToThrottled(target, ms: 70);
  }

  Future<void> _finishSeekbarDrag({required bool keepControlsVisible}) async {
    final vp = _videoPlayerController;
    if (vp == null || !vp.value.isInitialized) return;

    _seekThrottle?.cancel();
    await _seekTo(_scrubValue);

    if (_wasPlayingBeforeScrub && !vp.value.isPlaying) {
      await vp.play();
    }

    if (!mounted) return;
    setState(() {
      _showControls = keepControlsVisible;
      _isScrubbing = false;
    });
  }

  void _ensureEpisodeKeys(int count) {
    if (_episodeKeys.length == count) return;
    _episodeKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));
  }

  double get _seekbarLift {
    final t = Curves.easeOut.transform(_expandT);
    return lerpDouble(0, 24, t)!; // 12 -> 24
  }

  bool isPlayingNow(int serverIndex, int episodeIndex) {
    final chewie = _chewieController;
    final vp = _videoPlayerController;

    final selectedMatch =
        _selectedServerIndex == serverIndex &&
        _currentEpisodeIndex == episodeIndex;

    final isActuallyPlaying =
        (chewie?.isPlaying ?? false) || (vp?.value.isPlaying ?? false);

    return selectedMatch && isActuallyPlaying;
  }

  void _handleYoutubeSeek(SeekDirection dir) {
    final chewie = _chewieController;
    if (chewie == null) return;

    final vp = chewie.videoPlayerController;
    final now = DateTime.now();

    final withinWindow =
        _lastSeekTapTime != null &&
        now.difference(_lastSeekTapTime!) <= const Duration(milliseconds: 800);
    // Ẩn controls khi tua và chỉ hiện lại khi user tap video.
    _hideControlsTimer?.cancel();
    setState(() {
      _showControls = false; // <- ẩn play/pause + top bar
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

    // _resetHideControlsTimer();
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

  // double get _seekbarLift {
  //   final t = Curves.easeOut.transform(_expandT);
  //   return lerpDouble(0, 12, t)!; // nhích lên tối đa 12px
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentsCubit>(
      create: (_) => CommentsCubit(
        repository: sl<CommentRepository>(),
        movieSlug: widget.slug,
      )..loadInitial(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: OrientationBuilder(
          builder: (context, orientation) {
            final previousOrientation = _lastOrientation;
            final rotated =
                previousOrientation != null &&
                previousOrientation != orientation;

            _lastOrientation = orientation;

            if (previousOrientation == null || rotated) {
              _syncFullscreenWithOrientation(orientation);
            }

            if (rotated) {
              _scrollToCurrentEpisode(animated: false);
            }

            if (orientation == Orientation.portrait &&
                (_landscapeZoomScale != _landscapeZoomMin ||
                    _showLandscapeZoomLabel)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _resetLandscapeZoom();
              });
            }

            return orientation == Orientation.landscape
                ? _buildLandscapePlayer()
                : _buildPortraitPlayer();
          },
        ),
      ),
    );
  }

  Widget _buildAutoPlayToggleButton() {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final autoPlay = state is PlayerLoadedState
            ? state.autoPlayNextEpisode
            : true;

        return SizedBox(
          width: 40, // chỉnh nhỏ theo ý
          height: 50,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Switch(
              padding: EdgeInsets.zero,
              value: autoPlay,
              onChanged: (v) {
                HapticFeedback.lightImpact();
                final newValue = !autoPlay;
                _playerCubit.setAutoPlayNextEpisode(newValue);
                _showAutoPlayToast(newValue);
              },

              // màu track
              activeTrackColor: Colors.white24,
              inactiveTrackColor: Colors.black54,

              // màu thumb
              activeColor: Colors.white,
              inactiveThumbColor: Colors.white24,
              trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
              // // viền track (Material 3)
              // trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              //   if (states.contains(WidgetState.selected)) {
              //     return const Color(0xFFC77DFF);
              //   }
              //   return Colors.white24;
              // }),

              // icon nằm trong thumb (Flutter mới)
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                final selected = states.contains(WidgetState.selected);
                return Icon(
                  selected ? Icons.play_arrow : Icons.pause,
                  size: 13,
                  color: selected ? Colors.black : Colors.white,
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBatteryIndicator() {
    final level = _batteryLevel.clamp(0, 100);
    final fraction = level / 100.0;

    final Color fillColor;

    if (_isCharging || _batteryState == BatteryState.full) {
      fillColor = const Color(0xff34C759); // Xanh khi sạc hoặc đầy
    } else if (level <= 15) {
      fillColor = const Color(0xffFF453A); // Đỏ khi gần hết pin
    } else if (level <= 30) {
      fillColor = const Color(0xffFFD60A); // Vàng khi pin yếu
    } else {
      fillColor = Colors.white;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$level%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            shadows: [Shadow(color: Colors.black87, blurRadius: 5)],
          ),
        ),
        const SizedBox(width: 5),

        // Tổng chiều rộng gồm thân pin và đầu pin.
        SizedBox(
          width: 29,
          height: 18,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // Thân pin
              Positioned(
                left: 0,
                top: 1,
                bottom: 1,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.5),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(1.7),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Nền rỗng của pin
                        ColoredBox(color: Colors.white.withValues(alpha: 0.13)),

                        // Lượng pin thật theo phần trăm
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(end: fraction),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedFraction, child) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: animatedFraction,
                                heightFactor: 1,
                                child: ColoredBox(color: fillColor),
                              ),
                            );
                          },
                        ),

                        // Biểu tượng sét khi đang sạc
                        if (_isCharging)
                          const Center(
                            child: Icon(
                              Icons.bolt_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Đầu pin
              Positioned(
                right: 0,
                child: Container(
                  width: 3,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _wrapPanelHeaderDrag({required Widget child}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (_) {
        _panelDragDy = 0;
        _panelDragging =
            true; // không cần setState nếu bạn không dùng để render
        _videoSnapCtrl.stop();
        _hideControlsNow();
      },
      onVerticalDragUpdate: (d) {
        _panelDragDy += d.delta.dy;

        final ctrl = (widget.movie.episode_current == 'Full')
            ? _scrollController
            : _episodeScrollController;

        final atTop = !ctrl.hasClients || ctrl.offset <= 0.5;

        if (atTop || _videoHeight > _minVideoHeight + 1) {
          _panelResizeByDy(d.delta.dy);
        }
      },
      onVerticalDragEnd: (d) => _panelResizeEnd(
        velocity: d.primaryVelocity ?? 0,
        dragDy: _panelDragDy,
      ),
      child: child,
    );
  }

  Widget _wrapOverscrollToResize({
    required ScrollController controller,
    required Widget child,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        if (_isFullscreen || isLandscape) return false;

        final m = n.metrics;
        final atTop = m.pixels <= m.minScrollExtent + 0.5;

        // Kéo xuống ở TOP: có thể ra Overscroll hoặc chỉ ScrollUpdate tùy máy
        double? dyPullDown;

        if (atTop && n is OverscrollNotification && n.overscroll < 0) {
          dyPullDown = -n.overscroll; // kéo xuống => dy dương
        }

        if (atTop && n is ScrollUpdateNotification) {
          final delta = n.scrollDelta ?? 0;
          if (delta < 0) dyPullDown = -delta; // kéo xuống => dy dương
        }

        if (dyPullDown != null && dyPullDown > 0) {
          if (!_panelResizingFromOverscroll) {
            _panelResizingFromOverscroll = true;
            _panelDragDy = 0;
            _videoSnapCtrl.stop();
            _hideControlsNow();
          }

          _panelDragDy += dyPullDown;
          _panelResizeByDy(dyPullDown);
          return false;
        }

        // Nếu đang resize mà user kéo ngược lên => trả lại scroll bình thường
        if (n is ScrollUpdateNotification &&
            _panelResizingFromOverscroll &&
            (n.scrollDelta ?? 0) > 0) {
          _panelResizingFromOverscroll = false;
          _panelDragDy = 0;
        }

        // Thả tay => snap
        final isReleaseOrIdle =
            (n is ScrollEndNotification) ||
            (n is UserScrollNotification &&
                n.direction == ScrollDirection.idle);

        if (isReleaseOrIdle && _panelResizingFromOverscroll) {
          _panelResizingFromOverscroll = false;
          _panelResizeEnd(dragDy: _panelDragDy, velocity: 0);
          _panelDragDy = 0;
        }

        return false;
      },
      child: child,
    );
  }

  Widget _buildLandscapeStatusHeader() {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final time = DateFormat('HH:mm').format(_statusNow);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 42,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.72),
                  Colors.black.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: viewPadding.left + 18,
                right: viewPadding.right + 18,
                top: 7,
                bottom: 7,
              ),
              child: Row(
                children: [
                  // Giờ bên trái
                  SizedBox(width: 80, child: _buildNetworkIndicator()),

                  // Wi-Fi chính giữa
                  Expanded(
                    child: Center(
                      child: Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Phần trăm pin bên phải
                  SizedBox(width: 80, child: _buildBatteryIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppbarScrim({required bool isExpanded}) {
    final h = isExpanded ? 160.0 : 110.0; // tuỳ bạn
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: h,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.65),
                  Colors.black.withOpacity(0.25),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoAreaWithoutSeekbar() {
    final isExpanded = _videoHeight >= _maxVideoHeight - 100;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      // Tap/double tap vẫn hoạt động trên cả vùng black bar
      onTap: _toggleControls,
      onDoubleTapDown: _handleDoubleTap,

      onVerticalDragStart: (_) {
        _miniDragDy = 0;
        _videoGestureDragDy = 0;

        _videoSnapCtrl.stop();
        _hideControlsNow();

        _videoDragMode = null; // undecided
      },

      onVerticalDragUpdate: (d) {
        // quyết định mode ở lần update đầu tiên
        if (_videoDragMode == null) {
          if (_videoHeight > _minVideoHeight + 1) {
            _videoDragMode = _VideoDragMode.resize;
          } else {
            // ở min: kéo LÊN => expand, kéo XUỐNG => mini
            _videoDragMode = (d.delta.dy < 0)
                ? _VideoDragMode.resize
                : _VideoDragMode.mini;
          }
        }

        if (_videoDragMode == _VideoDragMode.resize) {
          // drag up => d.delta.dy âm => -delta => dy dương => tăng height
          final dy = d.delta.dy;
          _videoGestureDragDy += dy;
          _panelResizeByDy(dy); // dy âm => collapse, dy dương => expand
          return;
        }

        // mini mode (kéo xuống)
        _miniDragDy += d.delta.dy;
        final overlayController = widget.overlayController;
        if (overlayController != null) {
          overlayController.beginDrag();
          overlayController.updateDragDelta(
            d.delta.dy,
            MediaQuery.sizeOf(context).height * 0.55,
          );
        }
      },

      onVerticalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;

        if (_videoDragMode == _VideoDragMode.resize) {
          // vì mình đảo dấu dy, velocity cũng đảo để snap đúng
          _panelResizeEnd(velocity: v, dragDy: _videoGestureDragDy);
          return;
        }

        // mini mode
        final overlayController = widget.overlayController;
        if (overlayController != null) {
          overlayController.endDrag(velocityY: v);
          return;
        }
        if (_miniDragDy > 80 || v > 800) {
          _enterMiniPlayer();
        }
      },
      onVerticalDragCancel: () {
        if (_videoDragMode == _VideoDragMode.mini) {
          widget.overlayController?.cancelDrag();
        }
      },

      child: Container(
        key: _videoBoxKey,
        height: _videoHeight,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized &&
                !_usesNativeIosVideoView)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.8,
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
            // chỉ build ambient/blur khi KHÔNG minify
            _buildAmbientAroundVideo(),
            if (_chewieController != null)
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildStablePlayerSurface(_chewieController!),
                ),
              )
            else
              _buildPlayerPlaceholder(),
            _buildPlayPauseOverlay(),
            _buildPlaybackStatusOverlay(),
            if (_showSeekOverlay && _seekDir != null) _buildSeekOverlay(50),
            // ✅ THÊM scrim cho appbar ở đây (nằm dưới appbar row)
            _buildTopAppbarScrim(isExpanded: isExpanded),
            Positioned(
              top: isExpanded ? 50 : 8,
              left: 8,
              right: 0,
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
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
                          onPressed: () {
                            unawaited(_exitPlayerPage());
                          },
                        ),
                        const Spacer(),
                        if (widget.movie.episode_current != 'Full')
                          _buildAutoPlayToggleButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            isExpanded
                ? _buildTitleOverlay(isExpanded: isExpanded)
                : SizedBox.shrink(),
            Positioned(
              top: 50,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showAutoToast ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: AnimatedScale(
                      scale: _showAutoToast ? 1.0 : 0.95,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          _autoToastText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleOverlay({required bool isExpanded}) {
    return Positioned(
      top: 100,
      left: 30,
      right: 12,
      child: IgnorePointer(
        ignoring: !_controlsVisible,
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: _showControls ? Offset.zero : const Offset(0, -0.08),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tên gốc (origin) - thường dài hơn -> 2 lines
                Text(
                  widget
                      .movie
                      .origin_name, // hoặc widget.movie.originName tuỳ model
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 2),

                // Tên Việt/hiển thị - 1 line
                Text(
                  widget.movieName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black54),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientAroundVideo() {
    return Positioned.fill(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;

            // video 16:9 đặt giữa theo chiều dọc
            final videoH = w * (9 / 16);
            final bar = ((h - videoH) / 2).clamp(0.0, h);

            // Không có bar => không cần ambient
            if (bar <= 0.5) return const SizedBox.shrink();

            // Lấn nhẹ vào vùng video để cảm nhận "ôm" video
            const feather = 120.0;

            // Opacity tăng theo độ "dư" (càng dư càng rõ)
            final t = (bar / 90.0).clamp(0.0, 1.0);
            final opacity = Curves.easeOut.transform(t);

            return Opacity(
              opacity: opacity,
              child: Stack(
                children: [
                  // TOP: đen từ trên xuống, fade về gần video
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: bar + feather,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.92),
                            Colors.black.withOpacity(0.85),
                            Colors.black.withOpacity(0.65),
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.25, 0.55, 0.80, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // BOTTOM: đen từ dưới lên, fade về gần video
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: bar + feather,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.92),
                            Colors.black.withOpacity(0.85),
                            Colors.black.withOpacity(0.65),
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.25, 0.55, 0.80, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Ambient blur "lụi" xuống đầu panel
  Widget _buildPanelAmbientTop() {
    final vp = _videoPlayerController;
    if (vp == null || !vp.value.isInitialized || _usesNativeIosVideoView) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lớp 1: Video (Chỉ lấy nửa dưới)
            Opacity(
              opacity: .45,
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
                      AppColor.bgApp.withValues(alpha: 0.3),
                      AppColor.bgApp.withValues(
                        alpha: 0.0,
                      ), // Trong suốt dần lên đỉnh
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAmbientStrip(double h) {
    final vp = _videoPlayerController;
    if (vp == null || !vp.value.isInitialized || _usesNativeIosVideoView) {
      return SizedBox(height: h);
    }
    return SizedBox(
      height: h,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 0.80,
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
            DecoratedBox(
              decoration: BoxDecoration(
                color: _showControls
                    ? Color(0xff191A24).withOpacity(1)
                    : Color(0xff191A24).withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentPreviewShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xff2A2A2A),
      highlightColor: const Color(0xff454545),
      period: const Duration(milliseconds: 1100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar giả
          Container(
            width: 30.r,
            height: 30.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: 8.w),

          // Nội dung bình luận giả
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),

                    SizedBox(height: 6.h),

                    Container(
                      width: constraints.maxWidth * 0.65,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayFadingInformation({required Widget child}) {
    final progress = widget.overlayProgress;
    if (progress == null) return Flexible(child: child);

    return Flexible(
      child: ValueListenableBuilder<double>(
        valueListenable: progress,
        child: RepaintBoundary(child: child),
        builder: (context, value, content) {
          final fadeProgress = Curves.easeOutCubic.transform(
            (value / 0.72).clamp(0.0, 1.0),
          );
          final opacity = 1 - fadeProgress;
          return IgnorePointer(
            ignoring: value > 0.04,
            child: ExcludeSemantics(
              excluding: opacity < 0.05,
              child: Opacity(opacity: opacity, child: content),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitPlayer() {
    // Khi expand video, ẩn SafeArea để video nằm chính giữa
    final isExpanded = _videoHeight >= _maxVideoHeight - 100;
    final mq = MediaQuery.of(context);
    final insets = mq.padding;

    // ✅ ổn định hơn so với _videoHeight >= ...
    final isExpandedNow = _expandT >= 0.97;

    // ✅ Animate safe area: bình thường ~1, expand -> 0
    final safeT = Curves.easeOutCubic.transform(
      ((0.97 - _expandT) / 0.07).clamp(0.0, 1.0),
    );

    final topPad = insets.top * safeT;
    final leftPad = insets.left * safeT;
    final rightPad = insets.right * safeT;

    // // Nếu bạn có dùng panelH để tính show/hide content:
    // final screenH = mq.size.height - topPad; // trừ topPad cho đúng cảm giác
    // final panelH = screenH - _videoHeight;

    // final minPanel = (widget.movie.episode_current == 'Full')
    //     ? kMinPanelHFull
    //     : kMinPanelHRich;

    // CHỐT: bình thường luôn hiện, expand thì phụ thuộc _showControls
    // final showSeekbar = isExpandedNow ? _showControls : true;
    final showSeekbar = isExpandedNow
        ? (_controlsVisible || _isScrubbing)
        : true;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 140),
      curve: Curves.bounceInOut,
      padding: EdgeInsets.only(top: topPad, left: leftPad, right: rightPad),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -topPad,
            left: 0,
            right: 0,
            height: topPad + 60,
            child: IgnorePointer(child: _buildTopAmbientStrip(topPad + 60)),
          ),
          Column(
            children: [
              RepaintBoundary(child: _buildVideoAreaWithoutSeekbar()),
              _buildOverlayFadingInformation(
                child: Material(
                  color: AppColor.bgApp,
                  clipBehavior: Clip.antiAlias, // QUAN TRỌNG
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final screen = MediaQuery.of(context).size;
                      final newMin = screen.width * (9 / 16);
                      final newMax = screen.height;

                      final needSync =
                          (_maxVideoHeight - newMax).abs() > 0.5 ||
                          (_minVideoHeight - newMin).abs() > 0.5;

                      if (needSync) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            _maxVideoHeight = newMax;
                            _minVideoHeight = newMin;
                            _videoHeight = _videoHeight.clamp(
                              _minVideoHeight,
                              _maxVideoHeight,
                            );
                          });
                        });
                      }
                      final commentsState = context
                          .watch<CommentsCubit>()
                          .state;

                      final firstComment = commentsState.comments.isNotEmpty
                          ? commentsState.comments.first
                          : null;
                      final isCommentsLoading =
                          commentsState.status == CommentsStatus.loading;
                      return Stack(
                        children: [
                          // Ambient blur cpc  trên cùng
                          if (!isExpanded)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: _buildPanelAmbientTop(),
                            ),
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: _wrapPanelHeaderDrag(
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
                                          const SizedBox(height: 6),

                                          if (widget.movie.episode_current !=
                                              'Full')
                                            Builder(
                                              builder: (context) {
                                                // Server hiện tại
                                                // final serverName = widget
                                                //     .episodes[_selectedServerIndex]
                                                //     .server_name;

                                                // Tên tập hiện tại (nếu có)
                                                final serverData = widget
                                                    .episodes[_selectedServerIndex]
                                                    .server_data;
                                                final epName =
                                                    (serverData.isNotEmpty &&
                                                        _currentEpisodeIndex >=
                                                            0 &&
                                                        _currentEpisodeIndex <
                                                            serverData.length)
                                                    ? serverData[_currentEpisodeIndex]
                                                          .name
                                                    : 'Full';

                                                final isPlaying =
                                                    _videoPlayerController
                                                        ?.value
                                                        .isPlaying ??
                                                    false;

                                                return Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 13,
                                                      height: 13,
                                                      child: Lottie.asset(
                                                        animate:
                                                            isPlaying, //  không phát -> đứng yên
                                                        'assets/icons/now_playing.json',
                                                        delegates: LottieDelegates(
                                                          values: [
                                                            ValueDelegate.color(
                                                              const ['**'],
                                                              value:
                                                                  Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),

                                                    Expanded(
                                                      child: Text(
                                                        'Đang phát: $epName',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha: 0.78,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          SizedBox(height: 10.h),
                                          // Bình luận
                                          Material(
                                            key: const ValueKey(
                                              'movie-comments-preview',
                                            ),
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: Ink(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: const Color(0xff1A1A22),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                splashFactory:
                                                    InkSplash.splashFactory,
                                                splashColor: Colors.white
                                                    .withValues(alpha: 0.045),
                                                highlightColor: Colors.white
                                                    .withValues(alpha: 0.025),
                                                onTap: () =>
                                                    _openCommentsSheet(context),
                                                child: Padding(
                                                  padding: EdgeInsets.all(12.w),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'Bình luận',
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                            WidgetSpan(
                                                              child: SizedBox(
                                                                width: 6.w,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  isCommentsLoading
                                                                  ? ''
                                                                  : '${commentsState.totalCount}',
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    const Color(
                                                                      0xffAAAAAA,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      SizedBox(height: 8.h),

                                                      AnimatedSwitcher(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 220,
                                                            ),
                                                        switchInCurve:
                                                            Curves.easeOut,
                                                        switchOutCurve:
                                                            Curves.easeIn,
                                                        child: isCommentsLoading
                                                            ? KeyedSubtree(
                                                                key: const ValueKey(
                                                                  'comments-loading',
                                                                ),
                                                                child:
                                                                    _buildCommentPreviewShimmer(),
                                                              )
                                                            : firstComment !=
                                                                  null
                                                            ? Row(
                                                                key: const ValueKey(
                                                                  'comments-loaded',
                                                                ),
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius:
                                                                        15.r,
                                                                    backgroundColor:
                                                                        const Color(
                                                                          0xff6155A6,
                                                                        ),
                                                                    backgroundImage:
                                                                        firstComment.authorAvatarUrl !=
                                                                                null &&
                                                                            firstComment.authorAvatarUrl!.trim().isNotEmpty
                                                                        ? NetworkImage(
                                                                            firstComment.authorAvatarUrl!,
                                                                          )
                                                                        : null,
                                                                    child:
                                                                        firstComment.authorAvatarUrl ==
                                                                                null ||
                                                                            firstComment.authorAvatarUrl!.trim().isEmpty
                                                                        ? Text(
                                                                            firstComment.authorName.trim().isEmpty
                                                                                ? '?'
                                                                                : firstComment.authorName.trim()[0].toUpperCase(),
                                                                            style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 11.sp,
                                                                              fontWeight: FontWeight.w700,
                                                                            ),
                                                                          )
                                                                        : null,
                                                                  ),

                                                                  SizedBox(
                                                                    width: 8.w,
                                                                  ),

                                                                  Expanded(
                                                                    child: Text(
                                                                      firstComment
                                                                              .isDeleted
                                                                          ? 'Bình luận đã bị xóa'
                                                                          : firstComment.body,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.85,
                                                                            ),
                                                                        fontSize:
                                                                            11.sp,
                                                                        height:
                                                                            1.3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : GestureDetector(
                                                                behavior:
                                                                    HitTestBehavior
                                                                        .opaque,

                                                                onTapDown: (_) {
                                                                  setState(() {
                                                                    _isCommentsEmptyPressed =
                                                                        true;
                                                                  });
                                                                },

                                                                onTapUp: (_) {
                                                                  setState(() {
                                                                    _isCommentsEmptyPressed =
                                                                        false;
                                                                  });
                                                                },

                                                                onTapCancel: () {
                                                                  setState(() {
                                                                    _isCommentsEmptyPressed =
                                                                        false;
                                                                  });
                                                                },

                                                                onTap: () =>
                                                                    _openCommentsSheet(
                                                                      context,
                                                                    ),

                                                                child: AnimatedContainer(
                                                                  key: const ValueKey(
                                                                    'comments-empty',
                                                                  ),
                                                                  duration:
                                                                      const Duration(
                                                                        milliseconds:
                                                                            120,
                                                                      ),
                                                                  curve: Curves
                                                                      .easeOut,

                                                                  width: double
                                                                      .infinity,
                                                                  padding: EdgeInsets.symmetric(
                                                                    vertical:
                                                                        8.h,
                                                                    horizontal:
                                                                        12.w,
                                                                  ),

                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        _isCommentsEmptyPressed
                                                                        ? Colors.white.withValues(
                                                                            alpha:
                                                                                0.16,
                                                                          )
                                                                        : Colors.grey.withValues(
                                                                            alpha:
                                                                                0.10,
                                                                          ),

                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          30.r,
                                                                        ),

                                                                    border: Border.all(
                                                                      color:
                                                                          _isCommentsEmptyPressed
                                                                          ? Colors.white.withValues(
                                                                              alpha: 0.20,
                                                                            )
                                                                          : Colors.transparent,
                                                                    ),

                                                                    boxShadow:
                                                                        _isCommentsEmptyPressed
                                                                        ? [
                                                                            BoxShadow(
                                                                              color: Colors.white.withValues(
                                                                                alpha: 0.12,
                                                                              ),
                                                                              blurRadius: 14,
                                                                              spreadRadius: 1,
                                                                            ),
                                                                          ]
                                                                        : const [],
                                                                  ),

                                                                  child: Text(
                                                                    'Chưa có bình luận',
                                                                    style: TextStyle(
                                                                      color:
                                                                          _isCommentsEmptyPressed
                                                                          ? Colors.white70
                                                                          : Colors.white38,
                                                                      fontSize:
                                                                          11.sp,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
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
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child:
                                          widget.movie.episode_current == 'Full'
                                          ? _buildEpisodeListForSingle()
                                          : _buildEpisodeListForSeriesMovie(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // 1) Info row + fullscreen (only show when _showControls)
          if (_controlsVisible) ...[
            Positioned(
              top:
                  _videoHeight -
                  (_thumbRadius * 2) -
                  44 -
                  _seekbarLift -
                  (isExpanded ? 30 : 0),
              left: (isExpanded ? 5 : 0),
              right: (isExpanded ? 5 : 0),
              child: _buildBottomInfoRow(),
            ),
          ],
          if (showSeekbar)
            Positioned(
              top:
                  _videoHeight -
                  _thumbRadius -
                  _seekbarLift -
                  (isExpanded ? 30 : 4),
              left: (isExpanded ? 20 : 0),
              right: (isExpanded ? 20 : 0),
              child: Material(
                color: Colors.transparent,
                child: _buildPinnedSeekbarOnly(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _textFieldEpisode() {
    return SizedBox(
      key: const ValueKey('series-episode-search'),
      height: _searchBarH,
      child: Padding(
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
      ),
    );
  }

  Widget _buildEpisodeListForSeriesMovie() {
    final serverData = widget.episodes[_selectedServerIndex].server_data;
    _ensureEpisodeKeys(serverData.length);
    final isPlaying = _videoPlayerController?.value.isPlaying ?? false;
    final currentServer = widget.episodes[_selectedServerIndex];

    return _wrapOverscrollToResize(
      controller: _episodeScrollController,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleEpisodeScrollNotification,
        child: CustomScrollView(
          key: const ValueKey('series-episode-scroll'),
          controller: _episodeScrollController,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            SliverPersistentHeader(
              floating: false,
              pinned: true,
              delegate: _FloatingSeriesControlsDelegate(
                extent: _seriesControlsExtent,
                contentHeight: _seriesControlsMaxH,
                child: Column(
                  children: [
                    _buildListServerForSeriesMovie(),
                    const SizedBox(height: _seriesControlsSpacing),
                    _textFieldEpisode(),
                    const SizedBox(height: _seriesControlsBottomSpacing),
                  ],
                ),
              ),
            ),
            SliverPadding(
              key: const ValueKey('series-episode-grid'),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  mainAxisExtent: 40,
                  childAspectRatio: 16 / 9,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final key = _episodeKeys[index];
                  final episode = serverData[index];
                  final isActive = _currentEpisodeIndex == index;

                  return KeyedSubtree(
                    key: key,
                    child: InkWell(
                      onTap: () => _playEpisode(index, currentServer),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff272A39),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFC77DFF),
                                    Color(0xFFFF9E9E),
                                    Color(0xFFFFD275),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                )
                              : null,
                          boxShadow: isActive
                              ? const [
                                  BoxShadow(
                                    color: Color(0xFFC77DFF),
                                    blurRadius: 12,
                                    offset: Offset.zero,
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
                                  animate: isPlaying,
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
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: serverData.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListServerForSeriesMovie() {
    return Container(
      key: const ValueKey('series-server-bar'),
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      height: 65,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff272A39).withOpacity(.3),
            Color(0xff191A24).withOpacity(.3),
          ],
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
    final vp = _videoPlayerController;
    final isSeries = widget.movie.episode_current != 'Full';

    Widget buildOverlay({
      required bool isLoading,
      required bool isPlaying,
      required bool canTogglePlayback,
    }) {
      final visible = _controlsVisible;

      return IgnorePointer(
        // Chỉ khóa toàn bộ khi controls đang ẩn.
        // Loading không được khóa previous/next.
        ignoring: !visible,
        child: Center(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous vẫn hiện và vẫn bấm được khi loading.
                if (isSeries) ...[
                  _buildSideEpisodeButton(
                    icon: Iconsax.previous_copy,
                    onTap: _playPreviousEpisode,
                  ),
                  const SizedBox(width: 30),
                ],

                // Chỉ riêng nút play/pause đổi thành loading.
                IgnorePointer(
                  ignoring: isLoading || !canTogglePlayback,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isLoading || !canTogglePlayback
                        ? null
                        : () {
                            unawaited(_togglePlayPause());
                          },
                    child: Container(
                      width: 61,
                      height: 61,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        reverseDuration: const Duration(milliseconds: 120),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          );
                        },
                        child: isLoading
                            ? SizedBox(
                                key: const ValueKey('loading'),
                                width: 29,
                                height: 29,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  color: AppColor.secondColor,
                                ),
                              )
                            : _isPlaybackCompleted
                            ? const Icon(
                                Icons.replay_rounded,
                                key: ValueKey('replay'),
                                color: Colors.white,
                                size: 35,
                              )
                            : isPlaying
                            ? const Icon(
                                Iconsax.pause_copy,
                                key: ValueKey('pause'),
                                color: Colors.white,
                                size: 35,
                              )
                            : Transform.translate(
                                key: const ValueKey('play'),
                                offset: const Offset(1.5, 0),
                                child: const Icon(
                                  Iconsax.play_copy,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // Next vẫn hiện và vẫn bấm được khi loading.
                if (isSeries) ...[
                  const SizedBox(width: 30),
                  _buildSideEpisodeButton(
                    icon: Iconsax.next_copy,
                    onTap: _playNextEpisode,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Chưa tạo xong controller:
    // vẫn hiện back + previous + spinner + next.
    if (vp == null) {
      return buildOverlay(
        isLoading: _playerLoadError == null,
        isPlaying: false,
        canTogglePlayback: false,
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: vp,
      builder: (context, value, _) {
        final isLoading =
            _isVideoLoading ||
            !value.isInitialized ||
            _isPlaybackBuffering ||
            value.isBuffering;

        return buildOverlay(
          isLoading: isLoading,
          isPlaying: value.isPlaying,
          canTogglePlayback: value.isInitialized && !value.hasError,
        );
      },
    );
  }

  Widget _buildSideEpisodeButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 23),
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
        shadows: [BoxShadow(color: Colors.black, blurRadius: 2)],
        size: 28,
      ),
    );
  }

  Widget _buildEpisodeListForSingle() {
    final isPlayingIocn = _videoPlayerController?.value.isPlaying ?? false;
    return Scrollbar(
      controller: _scrollController,
      child: _wrapOverscrollToResize(
        controller: _scrollController,
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(10),
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260, // Một ô rộng tối đa 250px.
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 16 / 9,
          ),
          itemCount: widget.episodes.length,
          itemBuilder: (context, index) {
            final serverName = CoverMap.getConfigFromServerName(
              widget.episodes[index].server_name,
            );
            final isPlaying = _selectedServerIndex == index;
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
                              url: widget.movie.poster_url,
                              fit: BoxFit.cover,
                              cacheWidth: 600,
                              cacheHeight: 900,
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
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Dóng hàng bên trái
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
                                    Flexible(
                                      child: Text(
                                        serverName['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                animate:
                                                    isPlayingIocn, // ✅ không phát -> đứng yên
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

  Widget _buildLoadingControlBar(double? trackHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                child: const Text(
                  '00:00 / 00:00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
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
                  padding: const EdgeInsets.all(5),
                  onPressed: _toggleFullscreen,
                  icon: SvgPicture.asset(
                    _isFullscreen
                        ? 'assets/icons/fullscreen_exit.svg'
                        : 'assets/icons/fullscreen.svg',
                    width: 25,
                    height: 25,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: trackHeight ?? _seekbarVisualHeight,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ],
    );
  }

  Widget _buildControlBar(double? trackHeight) {
    final vp = _videoPlayerController;

    if (vp == null) {
      return _buildLoadingControlBar(trackHeight);
    }

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
            if (_controlsVisible)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  // vertical: 5,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
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
                        padding: EdgeInsets.all(5),
                        onPressed: _toggleFullscreen,
                        icon: SvgPicture.asset(
                          _isFullscreen
                              ? 'assets/icons/fullscreen_exit.svg'
                              : 'assets/icons/fullscreen.svg',
                          width: 25,
                          height: 25,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SliderTheme(
              data: SliderThemeData(
                padding: EdgeInsets.zero,
                trackHeight: _isScrubbing
                    ? 4
                    : trackHeight ?? _seekbarVisualHeight,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final seekbarWidth = constraints.maxWidth;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      _startSeekbarDrag(
                        details.localPosition.dx,
                        seekbarWidth,
                        keepControlsVisible: false,
                      );
                    },
                    onTapUp: (_) => unawaited(
                      _finishSeekbarDrag(keepControlsVisible: false),
                    ),
                    onHorizontalDragStart: (details) {
                      _startSeekbarDrag(
                        details.localPosition.dx,
                        seekbarWidth,
                        keepControlsVisible: false,
                      );
                    },
                    onHorizontalDragUpdate: (details) {
                      _updateSeekbarDrag(
                        details.localPosition.dx,
                        seekbarWidth,
                      );
                    },
                    onHorizontalDragEnd: (_) => unawaited(
                      _finishSeekbarDrag(keepControlsVisible: false),
                    ),
                    onHorizontalDragCancel: () => unawaited(
                      _finishSeekbarDrag(keepControlsVisible: false),
                    ),
                    child: SizedBox(
                      height: 20, // chừa đủ cho thumb/overlay
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: IgnorePointer(
                          child: Slider(
                            value: sliderValue.clamp(0.0, 1.0).toDouble(),
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
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
                  padding: EdgeInsets.all(5),
                  onPressed: _toggleFullscreen,
                  icon: SvgPicture.asset(
                    _isFullscreen
                        ? 'assets/icons/exit_fullscreen.svg'
                        : 'assets/icons/fullscreen.svg',
                    width: 25,
                    height: 25,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
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
            trackHeight: _isScrubbing ? 4 : _seekbarVisualHeight,
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
          child: SizedBox(
            height: 18,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final seekbarWidth = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _startSeekbarDrag(
                      details.localPosition.dx,
                      seekbarWidth,
                      keepControlsVisible: false,
                    );
                  },
                  onTapUp: (_) =>
                      unawaited(_finishSeekbarDrag(keepControlsVisible: false)),
                  onHorizontalDragStart: (details) {
                    _startSeekbarDrag(
                      details.localPosition.dx,
                      seekbarWidth,
                      keepControlsVisible: false,
                    );
                  },
                  onHorizontalDragUpdate: (details) {
                    _updateSeekbarDrag(details.localPosition.dx, seekbarWidth);
                  },
                  onHorizontalDragEnd: (_) =>
                      unawaited(_finishSeekbarDrag(keepControlsVisible: false)),
                  onHorizontalDragCancel: () =>
                      unawaited(_finishSeekbarDrag(keepControlsVisible: false)),
                  child: SizedBox(
                    height: lerpDouble(
                      _thumbRadius * 2,
                      _seekbarHitHeight,
                      _expandT,
                    )!, // tăng hit area khi expand
                    child: IgnorePointer(
                      child: Slider(
                        value: sliderValue.clamp(0.0, 1.0).toDouble(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandscapeZoomableVideo({required double fillScale}) {
    final chewie = _chewieController;
    if (chewie == null) {
      return _buildPlayerPlaceholder();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _toggleControls,
      onDoubleTapDown: _handleDoubleTap,
      onScaleStart: (details) => _handleLandscapeScaleStart(details, fillScale),
      onScaleUpdate: (details) =>
          _handleLandscapeScaleUpdate(details, fillScale),
      onScaleEnd: _handleLandscapeScaleEnd,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _landscapeZoomSnapCtrl,
          builder: (context, child) {
            final snapT = Curves.easeOutCubic.transform(
              _landscapeZoomSnapCtrl.value,
            );
            final pulse = math.sin(snapT * math.pi) * 0.035;
            final shakeDx = math.sin(snapT * math.pi * 4) * 3.5;

            return Transform.translate(
              offset: Offset(shakeDx, 0),
              child: Transform.scale(
                scale: _landscapeZoomScale + pulse,
                alignment: Alignment.center,
                child: child,
              ),
            );
          },
          child: _buildStablePlayerSurface(chewie),
        ),
      ),
    );
  }

  Widget _buildLandscapeBoundaryFlash() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _landscapeZoomSnapCtrl,
        builder: (context, _) {
          final t = _landscapeZoomSnapCtrl.value;
          if (t == 0 || t == 1) return const SizedBox.shrink();

          final opacity = math.sin(t * math.pi) * 0.26;
          return Opacity(
            opacity: opacity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.white.withValues(alpha: 0.95),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLandscapeZoomLabel() {
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.58),
        child: AnimatedOpacity(
          opacity: _showLandscapeZoomLabel ? 1 : 0,
          duration: const Duration(milliseconds: 140),
          child: AnimatedScale(
            scale: _showLandscapeZoomLabel ? 1 : 0.94,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Text(
                _landscapeZoomText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeTitleOverlay() {
    final serverInfo = CoverMap.getConfigFromServerName(_currentServer);
    final isSingleMovie = widget.movie.episode_current == 'Full';
    final metaColor = isSingleMovie
        ? (serverInfo['color'] as Color? ?? const Color(0xFF5F6070))
        : const Color(0xFFC77DFF);
    final metaIcon = isSingleMovie
        ? (serverInfo['icon'] as IconData? ?? Iconsax.subtitle)
        : Iconsax.video_play;
    final originName = widget.movie.origin_name.trim();

    return Positioned(
      top: 52,
      left: 50,
      right: 240,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: _controlsVisible ? Offset.zero : const Offset(0, -0.08),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.movieName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
                  ),
                ),
                if (originName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    originName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black87),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: metaColor.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(metaIcon, size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            _currentLandscapePlaybackLine(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
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
  }

  Future<void> _exitPlayerPage() async {
    if (_isExitingPlayer || !mounted) return;

    _isExitingPlayer = true;
    _hideControlsTimer?.cancel();

    if (widget.overlayController != null) {
      await _enterMiniPlayer();
      _isExitingPlayer = false;
      return;
    }

    if (context.canPop()) context.pop();
  }

  Widget _buildLandscapePlayer() {
    final isPlayingIocn = _videoPlayerController?.value.isPlaying ?? false;
    return Scaffold(
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.5,
        backgroundColor: AppColor.bgApp,
        child: EpisodeDrawer(
          isPlayingIcon: isPlayingIocn,
          key: _drawerKey,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewport = Size(constraints.maxWidth, constraints.maxHeight);
            final fillScale = _landscapeFillScaleFor(viewport);
            final showLandscapeBlur = _shouldShowLandscapeBlur(fillScale);

            return Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                if (showLandscapeBlur &&
                    _videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized &&
                    !_usesNativeIosVideoView)
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
                _buildLandscapeZoomableVideo(fillScale: fillScale),
                _buildLandscapeBoundaryFlash(),
                _buildLandscapeStatusHeader(),
                _buildPlayPauseOverlay(),
                _buildPlaybackStatusOverlay(),
                _buildLandscapeZoomLabel(),
                _buildLandscapeTitleOverlay(),
                Positioned(
                  top: 44,
                  left: 8,
                  right: 8,
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: AnimatedOpacity(
                      opacity: _controlsVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Quay lại',
                            icon: const Icon(
                              Iconsax.arrow_down_1_copy,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              unawaited(_exitPlayerPage());
                            },
                          ),

                          const Spacer(),

                          if (widget.movie.episode_current != 'Full')
                            _buildAutoPlayToggleButton(),

                          IconButton(
                            tooltip: 'Danh sách tập',
                            icon: const Icon(
                              Iconsax.menu,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();

                              Future.delayed(
                                const Duration(milliseconds: 250),
                                () {
                                  _drawerKey.currentState
                                      ?.scrollToCurrentEpisode(animated: false);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _showAutoToast ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedScale(
                          scale: _showAutoToast ? 1.0 : 0.95,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _autoToastText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 50,
                  child: (_controlsVisible || _isScrubbing)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: _buildControlBar(3),
                        )
                      : const SizedBox.shrink(),
                ),
                if (_showSeekOverlay && _seekDir != null)
                  _buildSeekOverlay(200),
              ],
            );
          },
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

class _ComposerAvatar extends StatelessWidget {
  const _ComposerAvatar({this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final validUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 17,
      backgroundColor: Colors.white10,
      backgroundImage: validUrl ? NetworkImage(avatarUrl!) : null,
      child: validUrl
          ? null
          : const Icon(Icons.person_rounded, color: Colors.white54, size: 20),
    );
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

class ScrubPreview extends StatelessWidget {
  final String timeText;
  final String? thumbUrl;
  const ScrubPreview({super.key, required this.timeText, this.thumbUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (thumbUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 140,
              height: 80,
              child: FastCachedImage(
                url: thumbUrl!,
                fit: BoxFit.cover,
                cacheWidth: 420,
                cacheHeight: 240,
              ),
            ),
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            timeText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingSeriesControlsDelegate extends SliverPersistentHeaderDelegate {
  const _FloatingSeriesControlsDelegate({
    required this.extent,
    required this.contentHeight,
    required this.child,
  });

  /// Chiều cao đang hiển thị.
  /// Giá trị này chỉ thay đổi khi người dùng vuốt.
  final double extent;

  /// Chiều cao đầy đủ của server + ô nhập tập.
  /// Nội dung vẫn giữ nguyên kích thước và chỉ bị ClipRect che đi.
  final double contentHeight;

  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(
      child: Stack(
        key: const ValueKey('series-floating-controls'),
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          // Luôn giữ nội dung ở chiều cao đầy đủ.
          // Khi extent giảm, ClipRect sẽ cắt từ dưới lên:
          // ô tìm tập mất trước, sau đó tới chip server.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: contentHeight,
            child: ColoredBox(color: AppColor.bgApp, child: child),
          ),

          // Thanh ngăn luôn nằm ở đáy phần còn hiển thị,
          // nên nó sẽ nâng lên cùng thao tác scroll.
          Positioned(
            key: const ValueKey('series-list-top-border'),
            left: 0,
            right: 0,
            bottom: 0,
            height: 1,
            child: ColoredBox(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FloatingSeriesControlsDelegate oldDelegate) {
    return oldDelegate.extent != extent ||
        oldDelegate.contentHeight != contentHeight ||
        oldDelegate.child != child;
  }
}

class _IosWifiStrengthIcon extends StatelessWidget {
  const _IosWifiStrengthIcon({
    super.key,
    required this.level,
    this.size = 22,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x38FFFFFF),
  });

  /// 0: không có tín hiệu
  /// 1: nấc dưới
  /// 2: nấc dưới + cung giữa
  /// 3: đầy đủ ba nấc
  final int level;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size * 0.75,
        child: CustomPaint(
          painter: _IosWifiStrengthPainter(
            level: level.clamp(0, 3).toInt(),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
      ),
    );
  }
}

class _IosWifiStrengthPainter extends CustomPainter {
  const _IosWifiStrengthPainter({
    required this.level,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int level;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24;
    final sy = size.height / 18;

    double x(double value) => value * sx;
    double y(double value) => value * sy;

    // Vì canvas 24 × 18 và widget cũng cùng tỷ lệ,
    // sx và sy gần như bằng nhau.
    double radius(double value) => value * sx;

    Paint paintForLevel(int requiredLevel) {
      return Paint()
        ..color = level >= requiredLevel ? activeColor : inactiveColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    Path addRoundCaps({
      required Path path,
      required Offset leftCenter,
      required Offset rightCenter,
      required double capRadius,
    }) {
      final leftCap = Path()
        ..addOval(Rect.fromCircle(center: leftCenter, radius: capRadius));

      final rightCap = Path()
        ..addOval(Rect.fromCircle(center: rightCenter, radius: capRadius));

      final withLeftCap = Path.combine(PathOperation.union, path, leftCap);

      return Path.combine(PathOperation.union, withLeftCap, rightCap);
    }

    // =========================
    // CUNG NGOÀI
    // =========================

    final outerBasePath = Path()
      ..moveTo(x(1.7), y(6.2))
      ..cubicTo(x(7.2), y(0.8), x(16.8), y(0.8), x(22.3), y(6.2))
      ..lineTo(x(19.55), y(8.85))
      ..cubicTo(x(15.45), y(4.95), x(8.55), y(4.95), x(4.45), y(8.85))
      ..close();

    final outerBand = addRoundCaps(
      path: outerBasePath,

      // Trung điểm của hai cạnh đầu bên trái.
      leftCenter: Offset(x(3.08), y(7.52)),

      // Trung điểm của hai cạnh đầu bên phải.
      rightCenter: Offset(x(20.92), y(7.52)),

      // Tăng lên 2.0 nếu muốn đầu tròn hơn nữa.
      capRadius: radius(1.85),
    );

    // =========================
    // CUNG GIỮA
    // =========================

    final middleBasePath = Path()
      ..moveTo(x(5.8), y(10.15))
      ..cubicTo(x(9.15), y(6.95), x(14.85), y(6.95), x(18.2), y(10.15))
      ..lineTo(x(15.45), y(12.75))
      ..cubicTo(x(13.55), y(10.95), x(10.45), y(10.95), x(8.55), y(12.75))
      ..close();

    final middleBand = addRoundCaps(
      path: middleBasePath,
      leftCenter: Offset(x(7.18), y(11.45)),
      rightCenter: Offset(x(16.82), y(11.45)),
      capRadius: radius(1.82),
    );

    // =========================
    // NẤC DƯỚI
    // =========================

    final bottomBand = Path()
      ..moveTo(x(9.45), y(14.7))
      ..cubicTo(x(10.75), y(13.25), x(13.25), y(13.25), x(14.55), y(14.7))
      ..cubicTo(x(14.0), y(15.35), x(13.15), y(16.25), x(12), y(17.25))
      ..cubicTo(x(10.85), y(16.25), x(10.0), y(15.35), x(9.45), y(14.7))
      ..close();

    canvas.drawPath(outerBand, paintForLevel(3));

    canvas.drawPath(middleBand, paintForLevel(2));

    canvas.drawPath(bottomBand, paintForLevel(1));
  }

  @override
  bool shouldRepaint(covariant _IosWifiStrengthPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
