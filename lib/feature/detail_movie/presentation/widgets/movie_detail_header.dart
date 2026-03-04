import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';

class MovieDetailHeader extends StatelessWidget {
  final String? trailerUrl;
  final String thumbUrl;
  final String posterUrl;
  final bool isPlayerReady;
  final bool isPlayerError;
  final Widget? playerWidget;
  final VoidCallback? onClose;
  final VoidCallback? onMuteToggle;
  final bool isMuted;

  const MovieDetailHeader({
    super.key,
    this.trailerUrl,
    required this.thumbUrl,
    required this.posterUrl,
    this.isPlayerReady = false,
    this.isPlayerError = false,
    this.playerWidget,
    this.onClose,
    this.onMuteToggle,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrailer = trailerUrl?.trim().isNotEmpty ?? false;
    final String posterUrlFinal = thumbUrl.isNotEmpty ? thumbUrl : posterUrl;
    final displayUrl = posterUrlFinal.startsWith('http')
        ? posterUrlFinal
        : AppUrl.convertImageAddition(posterUrlFinal);

    final showSkeleton = hasTrailer && !isPlayerReady && !isPlayerError;
    final showPlayer = hasTrailer && playerWidget != null && !isPlayerError;
    final showThumbnail =
        (!hasTrailer || isPlayerError) && displayUrl.isNotEmpty;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (showThumbnail)
                FastCachedImage(url: displayUrl, fit: BoxFit.cover),

              if (showPlayer) playerWidget!,

              if (showSkeleton)
                Shimmer.fromColors(
                  baseColor: const Color(0xff272A39).withOpacity(.2),
                  highlightColor: const Color(0xff191A24).withOpacity(.2),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),

        if (!showPlayer)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, const Color(0xff191A24)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

        if (showPlayer && onMuteToggle != null) ...[
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: onMuteToggle,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],

        if (onClose != null)
          Positioned(
            top: 10,
            left: 10,
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
