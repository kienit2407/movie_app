import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:movie_app/core/mini_player_manager.dart';

class MiniPlayerOverlay extends StatefulWidget {
  const MiniPlayerOverlay({super.key});

  @override
  State<MiniPlayerOverlay> createState() => _MiniPlayerOverlayState();
}

class _MiniPlayerOverlayState extends State<MiniPlayerOverlay> {
  final MiniPlayerManager _miniPlayerManager = MiniPlayerManager();

  @override
  Widget build(BuildContext context) {
    if (!_miniPlayerManager.isMiniPlayerActive) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final miniWidth = screenSize.width * 0.4;
    final miniHeight = 200.0;

    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: _miniPlayerManager.onTap,
        child: Container(
          width: miniWidth,
          height: miniHeight,
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
                if (_miniPlayerManager.chewieController != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width:
                          _miniPlayerManager
                              .chewieController!
                              .videoPlayerController
                              .value
                              .size
                              .width ??
                          16 * 9,
                      height:
                          _miniPlayerManager
                              .chewieController!
                              .videoPlayerController
                              .value
                              .size
                              .height ??
                          9 * 16,
                      child: Chewie(
                        controller: _miniPlayerManager.chewieController!,
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      _miniPlayerManager.hideMiniPlayer();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_miniPlayerManager.movieName != null)
                        Text(
                          _miniPlayerManager.movieName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (_miniPlayerManager.currentEpisode != null)
                        Text(
                          _miniPlayerManager.currentEpisode!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
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
  }
}
