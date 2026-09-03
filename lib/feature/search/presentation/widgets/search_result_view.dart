import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:movie_app/common/components/app_auto_scroll_text.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';

class SearchResultView extends StatefulWidget {
  final List<MovieModel> movies;
  final bool isLoadingMore; // ✅ thêm flag loading more
  final ScrollController scrollController;
  final String resultSignature;

  const SearchResultView({
    super.key,
    required this.movies,
    required this.isLoadingMore,
    required this.scrollController,
    required this.resultSignature,
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

    // Chỉ reset animation khi keyword/filter đổi, không reset khi load-more.
    final newSig = widget.resultSignature;
    if (newSig != _sig) {
      _sig = newSig;
      _animatedOnce.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return Center(
        child: Text(
          context.l10n.searchNoResults,
          style: const TextStyle(color: Colors.white),
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
              bottom: MediaQuery.of(context).padding.bottom + 110,
            ),
            sliver: AnimationLimiter(
              // ✅ bọc 1 lần ở đây, không bọc từng item
              child: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final movie = widget.movies[index];

                  final firstTime = _animatedOnce.add(
                    movie.slug,
                  ); // true nếu lần đầu gặp
                  final shouldAnimate = firstTime && _animatedOnce.length <= 15;

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
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CupertinoActivityIndicator(
              // Bạn có thể chỉnh độ lớn nhỏ ở đây
              color: Colors.grey, // Màu sắc của loading
            ),
          ),
          const SizedBox(width: 10),
          Text(
            context.l10n.commonLoading,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(MovieModel movie, BuildContext context) {
    final List<MediaTagType> langTags = movie.lang.toMediaTags();
    final String currentEp = movie.episode_current;
    return KeyedSubtree(
      key: ValueKey('search-result-${movie.slug}'),
      child: GestureDetector(
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
                            final pixelRatio = MediaQuery.devicePixelRatioOf(
                              context,
                            );
                            final cacheWidth = (c.maxWidth * pixelRatio)
                                .round()
                                .clamp(1, 600)
                                .toInt();
                            final cacheHeight = (c.maxHeight * pixelRatio)
                                .round()
                                .clamp(1, 900)
                                .toInt();

                            return Image(
                              key: ValueKey(
                                '${movie.slug}:${movie.poster_url}',
                              ),
                              image: ResizeImage(
                                FastCachedImageProvider(movie.poster_url),
                                width: cacheWidth,
                                height: cacheHeight,
                              ),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: const Color(0xff191A24)),
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
                          if (currentEp.isNotEmpty && currentEp != 'Full')
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
              AppAutoScrollText(
                movie.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppAutoScrollText(
                movie.origin_name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
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
}
