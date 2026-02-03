import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/mini_player_manager.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';

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

        final miniW = size.width * 0.45;
        final miniH = miniW * 9 / 16;

        _pos ??= mgr.initialPos ?? Offset(
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
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
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
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildThumbnail(String url) {
    return FastCachedImage(
      url: url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.black12,
        child: Icon(
          Iconsax.video,
          color: Colors.white30,
          size: 32,
        ),
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
                  size: 16,
                )
              : Icon(
                  Iconsax.play_copy,
                  key: ValueKey('play'),
                  color: Colors.white,
                  size: 16,
                ),
        ),
      ),
    );
  }
}
