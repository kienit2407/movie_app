import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/mini_player_manager.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:video_player/video_player.dart';

class MiniPlayerOverlay extends StatefulWidget {
  const MiniPlayerOverlay({super.key});

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}

class _MiniPlayerOverlayState extends State<MiniPlayerOverlay> {
  final MiniPlayerManager mgr = MiniPlayerManager();
  Offset? _pos;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mgr,
      builder: (context, _) {
        if (!mgr.isMiniPlayerActive) return const SizedBox.shrink();

        final size = MediaQuery.sizeOf(context);
        final bottomInset = MediaQuery.paddingOf(context).bottom;

        final miniW = size.width * 0.56;
        final miniH = miniW * 9 / 16;

        _pos ??=
            mgr.initialPos ??
            Offset(
              size.width - miniW - 16,
              size.height - miniH - 16 - bottomInset,
            );

        Offset clampPos(Offset p) => Offset(
          p.dx.clamp(0.0, size.width - miniW),
          p.dy.clamp(0.0, size.height - miniH - bottomInset),
        );

        _pos = clampPos(_pos!);

        return Positioned(
          left: _pos!.dx,
          top: _pos!.dy,
          child: GestureDetector(
            onPanUpdate: (d) =>
                setState(() => _pos = clampPos(_pos! + d.delta)),
            onPanEnd: (d) {
              final vy = d.velocity.pixelsPerSecond.dy;
              if (vy > 1200) {
                mgr.disposeMiniPlayer();
                return;
              }

              final toRight = (_pos!.dx + miniW / 2) > size.width / 2;
              final target = Offset(
                toRight ? size.width - miniW - 16 : 16,
                size.height - miniH - 16 - bottomInset,
              );

              setState(() => _pos = target);
            },
            onTap: () {
              final handoff = mgr.detachForOpen();
              if (handoff.launch != null && handoff.controller != null) {
                AppNavigator.push(
                  context,
                  MoviePlayerPage(
                    movie: handoff.launch!.movie,
                    episodes: handoff.launch!.episodes,
                    movieName: handoff.launch!.movieName,
                    slug: handoff.launch!.slug,
                    initialEpisodeIndex: handoff.launch!.initialEpisodeIndex,
                    initialServer: handoff.launch!.initialServer,
                    thumbnailUrl: handoff.launch!.thumbnailUrl,
                    initialEpisodeLink: handoff.launch!.initialEpisodeLink,
                    initialServerIndex: handoff.launch!.initialServerIndex,
                  ),
                );
              }
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
                      bottom: -2,
                      left: 0,
                      right: 0,
                      child: _buildSeekBar(),
                    ),
                  ],
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
    if (v.duration.inMilliseconds == 0) return 0;
    if (v.buffered.isEmpty) return 0;
    final end = v.buffered.last.end.inMilliseconds;
    return end / v.duration.inMilliseconds;
  }

  Widget _buildSeekBar() {
    final controller = mgr.chewieController;
    if (controller == null) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: ValueListenableBuilder(
        valueListenable: controller.videoPlayerController,
        builder: (context, VideoPlayerValue value, child) {
          final buffered = _bufferedFraction(value);
          return SizedBox(
            height: 8,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                // Ẩn thumb + overlay
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),

                // (tuỳ chọn) ẩn tick nếu có
                tickMarkShape: const RoundSliderTickMarkShape(
                  tickMarkRadius: 0,
                ),
                inactiveTrackColor: const Color(0x55FFFFFF),
                trackShape: GradientBufferedSliderTrackShape(
                  buffered: buffered,
                  bufferedColor: Colors.white.withValues(alpha: 0.35),
                  gradientColors: const [
                    Color(0xFFC77DFF), // Tím
                    Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                    Color(0xFFFFD275),
                  ],
                ),
              ),
              child: Slider(
                value: value.isInitialized
                    ? value.position.inMilliseconds.toDouble()
                    : 0,
                max: value.isInitialized
                    ? value.duration.inMilliseconds.toDouble()
                    : 1,
                onChanged: (v) {
                  controller.seekTo(Duration(milliseconds: v.toInt()));
                },
              ),
            ),
          );
        },
      ),
    );
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
                  key: ValueKey('pause'),
                  color: Colors.white,
                  size: 20,
                )
              : Icon(
                  Iconsax.play_copy,
                  key: ValueKey('play'),
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
