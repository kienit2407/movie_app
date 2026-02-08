import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_shimmer_loading.dart';
import 'package:shimmer/shimmer.dart';

class SearchResultView extends StatelessWidget {
  final List<MovieModel> movies;
  final bool hasMore;
  final ScrollController scrollController;

  const SearchResultView({
    super.key,
    required this.movies,
    required this.hasMore,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy kết quả nào',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PrimaryScrollController(
      controller: scrollController,
      child: GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisSpacing: 20,
          crossAxisSpacing: 10,
          maxCrossAxisExtent: 150,
          childAspectRatio: 0.55,
        ),
        itemCount: movies.length + (hasMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= movies.length) {
            return const SizedBox(height: 100, width: 100, child: SizedBox());
          }

          final movie = movies[index];

          if (index < 10) {
            return AnimationLimiter(
              child: AnimationConfiguration.staggeredGrid(
                position: index,
                columnCount: 3,
                duration: const Duration(milliseconds: 400),
                child: ScaleAnimation(
                  curve: Curves.easeOut,
                  child: SlideAnimation(
                    verticalOffset: 50,
                    child: FadeInAnimation(child: _buildItem(movie, context)),
                  ),
                ),
              ),
            );
          } else {
            return _buildItem(movie, context);
          }
        },
      ),
    );
  }

  Widget _buildItem(MovieModel movie, BuildContext context) {
    final List<MediaTagType> langTags = movie.lang.toMediaTags();
    final String? currentEp = movie.episode_current;
    return GestureDetector(
      onTap: () {
        AppNavigator.push(context, MovieDetailPage(slug: movie.slug));
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showAnimatedDialog(
          context: context,
          dialog: ShowDetailMovieDialog(slug: movie.slug),
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FastCachedImage(
                        filterQuality: FilterQuality.medium,
                        url: AppUrl.convertImageAddition(movie.poster_url),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, loadingProgress) {
                          return _buildSkeletonForposter();
                        },
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
                        movie.tmdb?.vote_average?.toStringAsFixed(1) ?? "N/A",
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
                              _buildBadge(text: tag.label, color: tag.color),
                        ),
                        if (currentEp != null &&
                            currentEp.isNotEmpty &&
                            currentEp != 'Full')
                          _buildBadge(
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
              movie.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              movie.origin_name,
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

  Widget _buildBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSkeletonForposter() {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Shimmer.fromColors(
        baseColor: Color(0xff272A39),
        highlightColor: Color(0xff4A4E69),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
