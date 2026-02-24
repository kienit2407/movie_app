import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/mini_player_manager.dart';
import 'package:video_player/video_player.dart';

class MiniPlayerOverlay extends StatefulWidget {
  const MiniPlayerOverlay({super.key});

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}

class _MiniPlayerOverlayState extends State<MiniPlayerOverlay> with TickerProviderStateMixin {
  final MiniPlayerManager mgr = MiniPlayerManager();
  Offset? _pos;
  bool _wasInactive = true;
  static const double _margin = 16.0;
  bool _draggingMini = false;
  late final AnimationController _snapCtrl =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  Future<bool> _handleBackPress() async {
    if (mgr.isMiniPlayerActive) {
      mgr.disposeMiniPlayer();
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mgr,
      builder: (context, _) {
        final isActive = mgr.isMiniPlayerActive;

        if (!isActive) {
          _pos = null;
          _wasInactive = true;
          return const SizedBox.shrink();
        }

        final size = MediaQuery.sizeOf(context);
        final bottomInset = MediaQuery.paddingOf(context).bottom;

        final miniW = size.width * 0.55;
        final miniH = miniW * 9 / 16;
        final stored = mgr.currentPos;
        if ((_wasInactive || _pos == null) && stored != null) {
          _pos = stored;
          _wasInactive = false;
        }
        if (_wasInactive || _pos == null) {
          _pos = Offset(
            size.width - miniW - 16,
            size.height - miniH - 16 - bottomInset,
          );
          _wasInactive = false;
        }

        Offset clampPos(Offset p) => Offset(
          p.dx.clamp(_margin, size.width - miniW - _margin),
          p.dy.clamp(_margin, size.height - miniH - bottomInset - _margin),
        );
        final currentPos = clampPos(_pos!);
        _pos = currentPos;

        return WillPopScope(
          onWillPop: _handleBackPress,
          child: Positioned(
            left: currentPos.dx,
            top: currentPos.dy,
            child: GestureDetector(
              onPanUpdate: (d) {
                final newPos = clampPos(_pos! + d.delta);
                setState(() {
                  _pos = newPos;
                  mgr.updateMiniPosition(newPos);
                });
              },
              onPanStart: (_) => setState(() => _draggingMini = true),
              onPanEnd: (d) {
                setState(() => _draggingMini = false);
                final vy = d.velocity.pixelsPerSecond.dy;
                if (vy > 1200) {
                  mgr.disposeMiniPlayer();
                  return;
                }

                // Không snap nữa, chỉ clamp cho chắc
                final clamped = clampPos(_pos!);
                setState(() {
                  _pos = clamped;
                  mgr.updateMiniPosition(clamped);
                });
              },

              onTap: () {
                _openPlayer();
              },
              child: Container(
                width: miniW,
                height: miniH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (mgr.chewieController != null)
                        Chewie(controller: mgr.chewieController!)
                      else if (mgr.launch?.thumbnailUrl != null)
                        _buildThumbnail(mgr.launch!.thumbnailUrl!),

                      Positioned(
                        top: 6,
                        right: 6,
                        left: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(child: _buildPlayPauseOverlay()),
                            GestureDetector(
                              onTap: () => mgr.disposeMiniPlayer(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -3,
                        left: 0,
                        right: 0,
                        child: _buildSeekBar(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _bufferedFraction(VideoPlayerValue v) {
    if (!v.isInitialized) return 0;
    final dur = v.duration.inMilliseconds;
    if (dur <= 0) return 0;
    if (v.buffered.isEmpty) return 0;
    final end = v.buffered.last.end.inMilliseconds;
    return (end / dur).clamp(0.0, 1.0);
  }

  Widget _buildSeekBar() {
    final chewie = mgr.chewieController;
    if (chewie == null) return const SizedBox.shrink();

    final vp = chewie.videoPlayerController;

    return Material(
      color: Colors.transparent,
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: vp,
        builder: (context, value, child) {
          if (!value.isInitialized) return const SizedBox(height: 8);

          final durMs = value.duration.inMilliseconds;
          if (durMs <= 0) return const SizedBox(height: 8);

          final max = durMs.toDouble();
          var v = value.position.inMilliseconds.toDouble();
          if (v < 0) v = 0;
          if (v > max) v = max;

          if (!max.isFinite || !v.isFinite || max <= 0) {
            return const SizedBox(height: 8);
          }

          final buffered = _bufferedFraction(value).clamp(0.0, 1.0);

          return SizedBox(
            height: 8,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                tickMarkShape: const RoundSliderTickMarkShape(
                  tickMarkRadius: 0,
                ),
                inactiveTrackColor: const Color(0x55FFFFFF),
                trackShape: GradientBufferedSliderTrackShape(
                  buffered: buffered,
                  bufferedColor: Colors.white.withOpacity(0.35),
                  gradientColors: const [
                    Color(0xFFC77DFF),
                    Color(0xFFFF9E9E),
                    Color(0xFFFFD275),
                  ],
                ),
              ),
              child: Slider(
                min: 0,
                max: max,
                value: v,
                // KHÔNG seek liên tục trong onChanged
                onChanged: (_) {},
                onChangeEnd: (nv) {
                  final current = mgr.chewieController; // lấy lại mới nhất
                  if (current == null) return;

                  final val = current.videoPlayerController.value;
                  if (!val.isInitialized) return;
                  if (val.duration.inMilliseconds <= 0) return;

                  try {
                    current.seekTo(Duration(milliseconds: nv.toInt()));
                  } catch (_) {}
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _openPlayer() {
    final handoff = mgr.detachForOpen();
    final launch = handoff.launch;
    if (launch == null) return;

    final args = MoviePlayerArgs(
      launch.slug,
      launch.thumbnailUrl,
      launch.initialEpisodeLink,
      launch.initialEpisodeIndex,
      launch.initialServer,
      launch.movieName,
      launch.episodes,
      launch.movie,
      initialServerIndex: launch.initialServerIndex,
    );

    final navContext = AppRoutes.navigatorKey.currentContext;
    if (navContext == null) return;

    // Nếu đang ở player rồi thì thôi (tránh push chồng)
    final router = GoRouter.of(navContext);
    final loc = router.routeInformationProvider.value.uri.toString();
    if (loc.startsWith(AppRoutes.player)) return;

    router.pushNamed('player', extra: args);
  }

  Widget _buildThumbnail(String url) {
    return FastCachedImage(
      url: url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.black12,
        child: Icon(Iconsax.video, color: Colors.white30, size: 32),
      ),
      loadingBuilder: (context, progress) => Container(
        color: Colors.black12,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
        ),
      ),
    );
  }

  Widget _buildPlayPauseOverlay() {
    final controller = mgr.chewieController;
    if (controller == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        setState(() {
          if (controller.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Container(
          key: ValueKey(controller.isPlaying),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: controller.isPlaying
              ? Icon(
                  Iconsax.pause_copy,
                  key: const ValueKey('pause'),
                  color: Colors.white,
                  size: 20,
                )
              : Icon(
                  Iconsax.play_copy,
                  key: const ValueKey('play'),
                  color: Colors.white,
                  size: 20,
                ),
        ),
      ),
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
