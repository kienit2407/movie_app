import 'dart:async';

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/config/utils/support_rotate_screen.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/core/player_overlay_controller.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:video_player/video_player.dart';

typedef PlayerOverlayBuilder =
    Widget Function(
      BuildContext context,
      MoviePlayerArgs args,
      PlayerOverlayController controller,
    );

class PlayerOverlayHost extends StatefulWidget {
  const PlayerOverlayHost({
    super.key,
    required this.child,
    required this.router,
    this.controller,
    this.playerBuilder,
  });

  final Widget child;
  final GoRouter router;
  final PlayerOverlayController? controller;
  final PlayerOverlayBuilder? playerBuilder;

  @override
  State<PlayerOverlayHost> createState() => _PlayerOverlayHostState();
}

class PlayerOverlayBackButtonDispatcher extends RootBackButtonDispatcher {
  PlayerOverlayBackButtonDispatcher(this.controller);

  final PlayerOverlayController controller;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) {
    if (controller.dismissTransientOverlay()) {
      return SynchronousFuture<bool>(true);
    }

    if (!controller.isVisible) return super.invokeCallback(defaultValue);

    if (!controller.minimizeEnabled) {
      controller.close();
      return SynchronousFuture<bool>(true);
    }

    if (controller.isMini || controller.progress.value >= 0.999) {
      controller.close();
      return SynchronousFuture<bool>(true);
    }
    return _minimizeAfterPortrait();
  }

  Future<bool> _minimizeAfterPortrait() async {
    await SupportRotateScreen.onlyPotrait();
    if (controller.isVisible) controller.minimize();
    return true;
  }
}

class _PlayerOverlayHostState extends State<PlayerOverlayHost>
    with TickerProviderStateMixin {
  static const Duration _settleDuration = Duration(milliseconds: 240);
  static const Duration _miniSnapDuration = Duration(milliseconds: 200);
  static const Duration _miniResizeDuration = Duration(milliseconds: 220);
  static const double _miniWidthFactor = 0.55;
  static const double _miniMargin = 16;
  static const double _miniFlingVelocity = 600;

  late PlayerOverlayController _controller;
  late final AnimationController _motion;
  late final AnimationController _miniSnapMotion;
  late final AnimationController _miniResizeMotion;
  Animation<Offset>? _miniSnapAnimation;
  Offset? _miniPosition;
  Widget? _playerChild;
  int? _mountedSessionId;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PlayerOverlayController.instance;
    _motion = AnimationController(
      vsync: this,
      value: _controller.progress.value,
    )..addListener(_publishMotionProgress);
    _miniSnapMotion = AnimationController(
      vsync: this,
      duration: _miniSnapDuration,
    )..addListener(_publishMiniSnapPosition);
    _miniResizeMotion = AnimationController(
      vsync: this,
      duration: _miniResizeDuration,
    );
    _controller.addListener(_handleControllerChanged);
    _syncSessionChild();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleControllerChanged();
    });
  }

  @override
  void didUpdateWidget(PlayerOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.controller ?? PlayerOverlayController.instance;
    if (identical(next, _controller)) return;
    _controller.removeListener(_handleControllerChanged);
    _controller = next;
    _controller.addListener(_handleControllerChanged);
    _motion.value = _controller.progress.value;
    _syncSessionChild();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _motion
      ..removeListener(_publishMotionProgress)
      ..dispose();
    _miniSnapMotion
      ..removeListener(_publishMiniSnapPosition)
      ..dispose();
    _miniResizeMotion.dispose();
    super.dispose();
  }

  void _publishMotionProgress() {
    _controller.progress.value = _motion.value;
  }

  void _publishMiniSnapPosition() {
    final animation = _miniSnapAnimation;
    if (!mounted || animation == null) return;
    setState(() => _miniPosition = animation.value);
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    _syncSessionChild();

    if (_controller.isDragging) {
      _motion.stop();
      return;
    }

    final target = _controller.target == PlayerOverlayTarget.mini ? 1.0 : 0.0;
    _settleTo(target);
  }

  void _syncSessionChild() {
    final args = _controller.args;
    final nextSessionId = args == null ? null : _controller.sessionId;
    if (_mountedSessionId == nextSessionId) return;

    _miniSnapMotion.stop();
    _miniSnapAnimation = null;
    _miniPosition = null;
    _miniResizeMotion
      ..stop()
      ..value = 0;
    _mountedSessionId = nextSessionId;
    _playerChild = args == null
        ? null
        : KeyedSubtree(
            key: ValueKey<int>(nextSessionId!),
            child:
                widget.playerBuilder?.call(context, args, _controller) ??
                MoviePlayerPage(
                  slug: args.slug,
                  movieName: args.movieName,
                  thumbnailUrl: args.thumbnailUrl,
                  episodes: args.episodes,
                  movie: args.movie,
                  initialEpisodeLink: args.initialEpisodeLink,
                  initialEpisodeIndex: args.initialEpisodeIndex,
                  initialServer: args.initialServer,
                  initialServerIndex: args.initialServerIndex,
                  resumeFromHistory: args.resumeFromHistory,
                  overlayController: _controller,
                  overlayProgress: _controller.progress,
                ),
          );
    _motion.value = _controller.progress.value;
    if (mounted) setState(() {});
  }

  void _settleTo(double target) {
    final start = _controller.progress.value;
    if ((_motion.value - start).abs() > 0.001) {
      _motion.value = start;
    }
    if ((start - target).abs() < 0.001) {
      _controller.progress.value = target;
      return;
    }

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _motion.value = target;
      return;
    }

    final remaining = (target - start).abs();
    final milliseconds = (_settleDuration.inMilliseconds * remaining)
        .round()
        .clamp(90, _settleDuration.inMilliseconds);
    unawaited(
      _motion.animateTo(
        target,
        duration: Duration(milliseconds: milliseconds),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  bool _isHubRoute(String path) {
    return path == '/home' ||
        path == '/search' ||
        path == '/favorites' ||
        path == '/profile';
  }

  Rect _miniMovementBounds({
    required Size screenSize,
    required EdgeInsets padding,
    required double reservedBottom,
    required Size miniSize,
  }) {
    final left = padding.left + _miniMargin;
    final top = padding.top + _miniMargin;
    final right =
        (screenSize.width - padding.right - miniSize.width - _miniMargin)
            .clamp(left, double.infinity)
            .toDouble();
    final bottom =
        (screenSize.height -
                miniSize.height -
                padding.bottom -
                reservedBottom -
                _miniMargin)
            .clamp(top, double.infinity)
            .toDouble();
    return Rect.fromLTRB(left, top, right, bottom);
  }

  Offset _clampMiniPosition(Offset position, Rect bounds) {
    return Offset(
      position.dx.clamp(bounds.left, bounds.right).toDouble(),
      position.dy.clamp(bounds.top, bounds.bottom).toDouble(),
    );
  }

  void _beginMiniDrag(Offset currentPosition) {
    _miniSnapMotion.stop();
    _miniSnapAnimation = null;
    setState(() => _miniPosition = currentPosition);
  }

  void _updateMiniDrag(DragUpdateDetails details, Rect bounds) {
    final current = _clampMiniPosition(
      _miniPosition ?? Offset(bounds.right, bounds.bottom),
      bounds,
    );
    setState(() {
      _miniPosition = _clampMiniPosition(current + details.delta, bounds);
    });
  }

  void _endMiniDrag(Velocity velocity, Rect bounds) {
    final current = _clampMiniPosition(
      _miniPosition ?? Offset(bounds.right, bounds.bottom),
      bounds,
    );
    final snapRight = velocity.pixelsPerSecond.dx.abs() >= _miniFlingVelocity
        ? velocity.pixelsPerSecond.dx > 0
        : current.dx >= (bounds.left + bounds.right) / 2;
    final projectedY = current.dy + velocity.pixelsPerSecond.dy * 0.08;
    final target = Offset(
      snapRight ? bounds.right : bounds.left,
      projectedY.clamp(bounds.top, bounds.bottom).toDouble(),
    );

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations || (current - target).distance < 0.5) {
      setState(() => _miniPosition = target);
      return;
    }

    _miniSnapAnimation = Tween<Offset>(begin: current, end: target).animate(
      CurvedAnimation(parent: _miniSnapMotion, curve: Curves.easeOutCubic),
    );
    _miniSnapMotion.forward(from: 0);
  }

  void _toggleMiniWidth() {
    if (!_controller.isMini) return;

    _miniSnapMotion.stop();
    _miniSnapAnimation = null;
    final target = _miniResizeMotion.value < 0.5 ? 1.0 : 0.0;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _miniResizeMotion.value = target;
      return;
    }

    unawaited(_miniResizeMotion.animateTo(target, curve: Curves.easeOutCubic));
  }

  Widget _buildBackgroundContent(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewport = mediaQuery.size;
    final keepPortraitLayout =
        _playerChild != null &&
        _controller.target == PlayerOverlayTarget.expanded &&
        viewport.width > viewport.height;

    if (!keepPortraitLayout) return widget.child;

    // Home và các tab vẫn được giữ mounted phía dưới player. Khi cửa sổ xoay
    // ngang, không truyền constraint ngang tạm thời xuống các trang chỉ hỗ trợ
    // dọc vì ScreenUtil sẽ làm các card/hero Column bị overflow. Player che kín
    // phần này nên ta giữ nguyên layout dọc của nền cho đến khi trở về portrait.
    final portraitSize = Size(viewport.height, viewport.width);
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: portraitSize.width,
        maxWidth: portraitSize.width,
        minHeight: portraitSize.height,
        maxHeight: portraitSize.height,
        child: MediaQuery(
          data: mediaQuery.copyWith(size: portraitSize),
          child: SizedBox.fromSize(size: portraitSize, child: widget.child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackgroundContent(context),
        if (_playerChild != null)
          AnimatedBuilder(
            animation: Listenable.merge([
              _controller.progress,
              _miniResizeMotion,
              widget.router.routerDelegate,
            ]),
            child: _playerChild,
            builder: (context, player) {
              final size = MediaQuery.sizeOf(context);
              final padding = MediaQuery.paddingOf(context);
              final path =
                  widget.router.routerDelegate.currentConfiguration.uri.path;
              final reservedBottom = _isHubRoute(path) ? 92.0 : 0.0;
              final normalMiniWidth = size.width * _miniWidthFactor;
              final availableWideWidth =
                  size.width - padding.left - padding.right - (_miniMargin * 2);
              final wideMiniWidth = availableWideWidth > normalMiniWidth
                  ? availableWideWidth
                  : normalMiniWidth;
              final miniWidth =
                  normalMiniWidth +
                  ((wideMiniWidth - normalMiniWidth) * _miniResizeMotion.value);
              final miniHeight = miniWidth * 9 / 16;
              final miniSize = Size(miniWidth, miniHeight);
              final miniBounds = _miniMovementBounds(
                screenSize: size,
                padding: padding,
                reservedBottom: reservedBottom,
                miniSize: miniSize,
              );
              final miniPosition = _clampMiniPosition(
                _miniPosition ?? Offset(miniBounds.right, miniBounds.bottom),
                miniBounds,
              );
              final miniRect = miniPosition & miniSize;
              final fullRect = Offset.zero & size;
              final progress = _controller.progress.value.clamp(0.0, 1.0);
              final rect = Rect.lerp(fullRect, miniRect, progress)!;
              final scale = rect.width / size.width;
              final radius = BorderRadius.circular(12 * progress);
              final miniOpacity = Curves.easeOut.transform(
                ((progress - 0.68) / 0.32).clamp(0.0, 1.0),
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    ignoring: progress >= 0.999,
                    child: const ModalBarrier(
                      dismissible: false,
                      color: Colors.transparent,
                    ),
                  ),
                  Positioned.fromRect(
                    key: const ValueKey('player-overlay-surface'),
                    rect: rect,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        boxShadow: progress > 0.1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: 0.42 * progress,
                                  ),
                                  blurRadius: 14 * progress,
                                  offset: Offset(0, 5 * progress),
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: radius,
                        child: IgnorePointer(
                          ignoring: progress >= 0.98,
                          child: Transform.scale(
                            scale: scale,
                            alignment: Alignment.topLeft,
                            child: Transform.translate(
                              offset: Offset(0, -padding.top * progress),
                              child: OverflowBox(
                                alignment: Alignment.topLeft,
                                minWidth: size.width,
                                maxWidth: size.width,
                                minHeight: size.height,
                                maxHeight: size.height,
                                child: SizedBox.fromSize(
                                  size: size,
                                  child: player,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (miniOpacity > 0)
                    Positioned.fromRect(
                      rect: rect,
                      child: ClipRRect(
                        borderRadius: radius,
                        child: Opacity(
                          opacity: miniOpacity,
                          child: _MiniPlayerChrome(
                            controller: _controller,
                            interactive: progress >= 0.999,
                            onPanStart: (_) => _beginMiniDrag(miniPosition),
                            onPanUpdate: (details) =>
                                _updateMiniDrag(details, miniBounds),
                            onPanEnd: (details) =>
                                _endMiniDrag(details.velocity, miniBounds),
                            onPanCancel: () =>
                                _endMiniDrag(Velocity.zero, miniBounds),
                            onDoubleTap: _toggleMiniWidth,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _MiniPlayerChrome extends StatelessWidget {
  const _MiniPlayerChrome({
    required this.controller,
    required this.interactive,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onPanCancel,
    required this.onDoubleTap,
  });

  final PlayerOverlayController controller;
  final bool interactive;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final GestureDragCancelCallback onPanCancel;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !interactive,
      child: ValueListenableBuilder<VideoPlayerController?>(
        valueListenable: controller.playbackController,
        builder: (context, playback, _) {
          if (playback == null) {
            return _buildSurface(context: context, value: null);
          }
          return ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: playback,
            builder: (context, value, _) =>
                _buildSurface(context: context, value: value),
          );
        },
      ),
    );
  }

  Widget _buildSurface({
    required BuildContext context,
    required VideoPlayerValue? value,
  }) {
    final loading = value == null || !value.isInitialized || value.isBuffering;
    final canDrag =
        value != null &&
        value.isInitialized &&
        !value.isBuffering &&
        !value.hasError;

    return GestureDetector(
      key: const ValueKey('mini-player-drag-surface'),
      behavior: HitTestBehavior.opaque,
      onPanStart: canDrag ? onPanStart : null,
      onPanUpdate: canDrag ? onPanUpdate : null,
      onPanEnd: canDrag ? onPanEnd : null,
      onPanCancel: canDrag ? onPanCancel : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            unawaited(SupportRotateScreen.onlyPotrait());
            controller.expand();
          },
          onDoubleTap: onDoubleTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!loading)
                Center(
                  child: IconButton(
                    tooltip: value.isPlaying
                        ? context.l10n.playerPause
                        : context.l10n.playerPlay,
                    onPressed: () {
                      unawaited(controller.togglePlayback());
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                    icon: Icon(
                      value.isPlaying ? Iconsax.pause_copy : Iconsax.play_copy,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              if (value != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _MiniProgress(value: value),
                ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton(
                  tooltip: context.l10n.playerClose,
                  onPressed: controller.close,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    minimumSize: const Size(32, 32),
                    padding: const EdgeInsets.all(5),
                  ),
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.value});

  static const double _horizontalInset = 0;
  final VideoPlayerValue value;

  @override
  Widget build(BuildContext context) {
    final duration = value.duration.inMilliseconds;
    final progress = duration <= 0
        ? 0.0
        : (value.position.inMilliseconds / duration).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9E9E)),
          ),
        ),
      ),
    );
  }
}
