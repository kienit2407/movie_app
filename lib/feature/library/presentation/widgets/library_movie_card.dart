import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/routes/app_router.dart';

class LibraryMovieCard extends StatelessWidget {
  const LibraryMovieCard({
    super.key,
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    this.rating,
    this.progress,
    this.onRemove,
    this.onTap,
  });

  final String slug;
  final String name;
  final String originName;
  final String posterUrl;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final int year;
  final double? rating;
  final double? progress;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$name, $episodeCurrent',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap:
            onTap ??
            () => context.push(
              AppRoutes.movieDetail.replaceAll(
                ':slug',
                Uri.encodeComponent(slug),
              ),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: posterUrl.isEmpty
                        ? const ColoredBox(
                            color: Color(0xff292B38),
                            child: Icon(
                              Icons.movie_outlined,
                              color: Colors.white54,
                            ),
                          )
                        : FastCachedImage(
                            key: ValueKey('$slug-library-poster'),
                            url: posterUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 120),
                          ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _Badge(text: quality.isEmpty ? lang : quality),
                  ),
                  if (onRemove != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Xóa khỏi danh sách',
                        onPressed: onRemove,
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ),
                  if (progress != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                        child: LinearProgressIndicator(
                          value: progress!.clamp(0, 1),
                          minHeight: 4,
                          color: const Color(0xffC77DFF),
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              progress == null
                  ? [
                      episodeCurrent,
                      year > 0 ? '$year' : '',
                    ].where((value) => value.isNotEmpty).join(' • ')
                  : 'Tiếp tục ${(progress! * 100).round()}%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .58),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
