import 'dart:math';
import 'package:flutter/cupertino.dart';
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

class SearchResultView extends StatefulWidget {
  final List<MovieModel> movies;
  final bool isLoadingMore; // ✅ thêm flag loading more
  final ScrollController scrollController;

  const SearchResultView({
    super.key,
    required this.movies,
    required this.isLoadingMore,
    required this.scrollController,
  });

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> {
  final Set<String> _animatedOnce = <String>{};
  String _sig = '';

  @override
  void didUpdateWidget(covariant SearchResultView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // nếu data search thay đổi (query mới), reset danh sách đã animate
    final newSig = widget.movies.take(10).map((e) => e.slug).join('|');
    if (newSig != _sig) {
      _sig = newSig;
      _animatedOnce.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy kết quả nào',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    //  dùng CustomScrollView để có indicator full width phía dưới grid
    return Scrollbar(
      controller: widget.scrollController,
      child: CustomScrollView(
        controller: widget.scrollController,
        cacheExtent: 1500,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            sliver: AnimationLimiter(
              // ✅ bọc 1 lần ở đây, không bọc từng item
              child: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final movie = widget.movies[index];
      
                  final firstTime = _animatedOnce.add(
                    movie.slug,
                  ); // true nếu lần đầu gặp
                  final shouldAnimate = firstTime && _animatedOnce.length <= 10;
      
                  final child = _buildItem(movie, context);
      
                  if (!shouldAnimate) return child;
      
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 3,
                    duration: const Duration(milliseconds: 400),
                    child: ScaleAnimation(
                      curve: Curves.easeOut,
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(child: child),
                      ),
                    ),
                  );
                }, childCount: widget.movies.length),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 0.55,
                ),
              ),
            ),
          ),
      
          if (widget.isLoadingMore)
            SliverToBoxAdapter(child: _buildLoadingMoreIndicator()),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 120),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CupertinoActivityIndicator(
              // Bạn có thể chỉnh độ lớn nhỏ ở đây
              color: Colors.grey, // Màu sắc của loading
            ),
          ),
          SizedBox(width: 10),
          Text('Loading...', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildItem(MovieModel movie, BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;

    // “Đủ nét” nhưng nhẹ: nhân dpr
    final cw = (140 * dpr).round();
    final ch = (cw * 3 / 2).round();

    // “Cố tình bớt nét để nhẹ hơn”: dùng dpr thấp hơn (vd 1.5)
    final cwLow = (140 * 1.5).round();
    final chLow = (cwLow * 3 / 2).round();
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
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final dpr = MediaQuery.of(context).devicePixelRatio;

                          final displayPxW = c.maxWidth * dpr; //  px thật
                          const quality = 1; // 0.8–0.95 tuỳ bạn

                          final cw = (displayPxW * quality).round();
                          final ch = (cw * 3 / 2).round();

                          return FastCachedImage(
                            key: ValueKey(movie.slug), //  ổn định widget
                            url: AppUrl.convertImageAddition(movie.poster_url),
                            fit: BoxFit.cover,
                            // cacheWidth: cw,
                            // cacheHeight: ch,
                            // filterQuality: FilterQuality
                            //     .low, // đừng none nếu muốn đỡ “xấu”
                            // gaplessPlayback: true,
                            fadeInDuration: const Duration(milliseconds: 120),
                            loadingBuilder: (_, __) =>
                                _buildSkeletonForposter(), // xem phần 2
                          );
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
