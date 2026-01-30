import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
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

    return Scrollbar(
      controller: scrollController,
      child: AnimationLimiter(
        child: GridView.builder(
          controller: scrollController,
          padding:  EdgeInsets.only(left: 10, right: 10, bottom: MediaQuery.of(context).padding.bottom),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            maxCrossAxisExtent: 150,
            childAspectRatio: 0.55,
          ),
          itemCount: movies.length + (hasMore ? 3 : 0),
          itemBuilder: (context, index) {
            if (index >= movies.length) {
              return const SizedBox(
                height: 100,
                width: 100,
                child: SizedBox(),
              );
            }
      
            final movie = movies[index];
      
            return AnimationConfiguration.staggeredGrid(
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(MovieModel movie, BuildContext context) {
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FastCachedImage(
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
                        color: AppColor.secondColor,
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
                    right: 0,
                    bottom: 2,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _itemChip(
                          content: movie.lang.toConvertLang(),
                          isLeft: true,
                        ),
                        _itemChip(content: movie.quality, isGadient: true),
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

  Widget _itemChip({
    required String content,
    bool isGadient = false,
    double? size,
    bool isLeft = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isGadient ? null : Colors.white,
        borderRadius: isLeft
            ? const BorderRadius.only(topLeft: Radius.circular(5))
            : const BorderRadius.only(topRight: Radius.circular(5)),
        gradient: isGadient
            ? const LinearGradient(
                colors: [Color(0xffe73827), Color.fromARGB(255, 254, 136, 115)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
      ),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            fontSize: size ?? 8,
            fontWeight: FontWeight.w600,
            color: AppColor.bgApp,
            decoration: TextDecoration.none,
          ),
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
}
