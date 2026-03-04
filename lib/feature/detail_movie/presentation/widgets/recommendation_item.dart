import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/detail_movie/presentation/widgets/movie_badge.dart';

class RecommendationItem extends StatelessWidget {
  final ItemEntity itemEntity;

  const RecommendationItem({super.key, required this.itemEntity});

  @override
  Widget build(BuildContext context) {
    final List<MediaTagType> langTags = itemEntity.lang.toMediaTags();
    final String? currentEp = itemEntity.episodeCurrent;

    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.movieDetail.replaceAll(':slug', itemEntity.slug),
        );
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showAnimatedDialog(
          context: context,
          dialog: ShowDetailMovieDialog(slug: itemEntity.slug),
        );
      },
      child: SizedBox(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FastCachedImage(
                        url: itemEntity.posterUrl.startsWith('http')
                            ? itemEntity.posterUrl
                            : AppUrl.convertImageAddition(itemEntity.posterUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 5, left: 5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFC77DFF),
                            Color(0xFFFF9E9E),
                            Color(0xFFFFD275),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFC77DFF),
                            blurRadius: 12,
                            offset: Offset(0, 0),
                            spreadRadius: -2,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        itemEntity.tmdb.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: Column(
                      spacing: 3,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      verticalDirection: VerticalDirection.up,
                      children: [
                        ...langTags.map(
                          (tag) =>
                              MovieBadge(text: tag.label, color: tag.color),
                        ),
                        if (currentEp != null &&
                            currentEp.isNotEmpty &&
                            currentEp != 'Full')
                          MovieBadge(
                            text: EpisodeFormatter.toShort(currentEp),
                            color: Colors.redAccent,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              itemEntity.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              itemEntity.originName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
