import 'dart:math';
import 'dart:ui';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/common/helpers/static_data.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';
import 'package:movie_app/feature/movie_pagination/presentation/widgets/all_movie_skeleton.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AllMoviePage extends StatefulWidget {
  const AllMoviePage({super.key, required this.fillterReq});
  final FillterMovieReq fillterReq;

  @override
  State<AllMoviePage> createState() => _AllMoviePageState();
}

class _AllMoviePageState extends State<AllMoviePage> {
  final ScrollController _scrollController = ScrollController();
  final random = Random();
  late final Map<LinearGradient, Color> _selectedGradient;

  int _firstBatchCount = 0;

  final GlobalKey _largeTitleKey = GlobalKey();
  bool _showSmallTitle = false;

  @override
  void initState() {
    super.initState();

    _selectedGradient =
        StaticData.randomeGadientTitlePage[random.nextInt(
          StaticData.randomeGadientTitlePage.length,
        )];

    _fetchMovies();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchFillterCubit>().stream.listen((state) {
        if (state is FetchFillterLoaded && _firstBatchCount == 0) {
          setState(() {
            _firstBatchCount = state.items.length;
          });
        }
      });
    });
  }

  void _fetchMovies({bool isLoadMore = false}) {
    context.read<FetchFillterCubit>().fetchMovies(
      widget.fillterReq,
      isLoadMore: isLoadMore,
    );
  }

  void _onScroll() {
    if (_isBottom) {
      _fetchMovies(isLoadMore: true);
    }

    // Check if large title is scrolled out of view
    _checkLargeTitleVisibility();
  }

  void _checkLargeTitleVisibility() {
    final RenderObject? renderObject = _largeTitleKey.currentContext
        ?.findRenderObject();
    if (renderObject == null) return;

    final RenderBox renderBox = renderObject as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final double largeTitleBottom = position.dy + renderBox.size.height;

    // AppBar height (status bar + toolbar)
    final double appBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    // Show small title when large title scrolls behind the app bar
    final bool shouldShowSmall = largeTitleBottom < appBarHeight + 10;

    if (shouldShowSmall != _showSmallTitle) {
      setState(() {
        _showSmallTitle = shouldShowSmall;
      });
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColor = _selectedGradient.keys.single;
    final appBarColor = _selectedGradient.values.single;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: gradientColor),
          ),
          _buildContent(appBarColor),
        ],
      ),
    );
  }

  Widget _buildContent(Color gradientColor) {
    return RefreshIndicator.adaptive(
      color: Colors.white,
      onRefresh: () async {
        setState(() {
          _firstBatchCount = 0;
        });
        _fetchMovies(isLoadMore: false);
      },
      child: Scrollbar(
        controller: _scrollController,
        interactive: true,
        child: CustomScrollView(
          cacheExtent: 1500.0,
          controller: _scrollController,
          slivers: [
            // iOS-style AppBar - only shows small title when scrolled
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0, // Fix lỗi ám đen khi cuộn

              systemOverlayStyle: SystemUiOverlayStyle.light,
              toolbarHeight: kToolbarHeight,
              leading: IconButton(
                icon: const Icon(
                  Iconsax.arrow_left_2_copy,
                  color: Colors.white,
                ),
                onPressed: () => AppNavigator.pop(context),
              ),
              // Blur background when scrolled
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _showSmallTitle ? 30.0 : 0.0,
                    sigmaY: _showSmallTitle ? 30.0 : 0.0,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: _showSmallTitle
                        ? BoxDecoration(
                            border: Border.all(
                              color: AppColor.buttonColor.withOpacity(0.3),
                            ),
                            color: Color(gradientColor.value).withOpacity(0.7),
                          )
                        : null,
                  ),
                ),
              ),
              // Small title - only visible when large title is scrolled away
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showSmallTitle ? 1.0 : 0.0,
                child: BlocBuilder<FetchFillterCubit, FetchFillterState>(
                  builder: (context, state) {
                    final title = (state is FetchFillterLoaded)
                        ? state.titlePage
                        : '';
                    return Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              centerTitle: true,
            ),

            // Large Title - scrolls with content (iOS Settings style)
            SliverToBoxAdapter(
              child: Padding(
                key: _largeTitleKey,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 16,
                ),
                child: BlocBuilder<FetchFillterCubit, FetchFillterState>(
                  builder: (context, state) {
                    if (state is FetchFillterLoading) {
                      return Align(
                        // widget giúp k bị ép size từ parent
                        alignment: Alignment.centerLeft,
                        child: Shimmer.fromColors(
                          baseColor: Color(0xff272A39).withOpacity(.2),
                          highlightColor: Color(0xff191A24).withOpacity(.2),
                          child: Container(
                            width:
                                150, //để giữ đúng kích thước của title k bị ép sai  của sliverBoxAdapter
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff272A39), Color(0xff191A24)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    }
                    final title = (state is FetchFillterLoaded)
                        ? state.titlePage
                        : '';
                    return SharderText(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.black,
                          Color(0xff717285),
                          Colors.black,
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          // color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              sliver: BlocBuilder<FetchFillterCubit, FetchFillterState>(
                builder: (context, state) {
                  if (state is FetchFillterLoading) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildSkeletonItem(),
                          childCount: 9,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 10,
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 0.55,
                            ),
                      ),
                    );
                  }

                  if (state is FetchFillterLoaded) {
                    return MultiSliver(
                      children: [
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = state.items[index];

                            if (index < _firstBatchCount) {
                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                columnCount: 3,
                                duration: const Duration(milliseconds: 400),
                                child: ScaleAnimation(
                                  curve: Curves.easeOut,
                                  child: SlideAnimation(
                                    verticalOffset: 50,
                                    child: FadeInAnimation(
                                      child: _buildItem(item),
                                    ),
                                  ),
                                ),
                              );
                            }

                            return _buildItem(item);
                          }, childCount: state.items.length),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 10,
                                maxCrossAxisExtent: 150,
                                childAspectRatio: 0.55,
                              ),
                        ),
                        if (state.isLoadingMore)
                          SliverToBoxAdapter(child: _buildIndicator()),
                      ],
                    );
                  }

                  if (state is FetchFillterFailure) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text(state.message)),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300),
      height: 60,
      padding: const EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator.adaptive(), Text('Loading')],
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Shimmer.fromColors(
      baseColor: Color(0xff272A39).withOpacity(.2),
      highlightColor: Color(0xff191A24).withOpacity(.2),
      child: SizedBox(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
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
        border: Border.all(color: color), // Viền đậm cùng tông
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white, // Chữ đậm cùng tông
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildItem(ItemEntity itemEntity) {
    // 1. Parse chuỗi ngôn ngữ sang List các Enum
    final List<MediaTagType> langTags = itemEntity.lang.toMediaTags();

    // 2. Lấy tập hiện tại (Check null an toàn)
    final String? currentEp = itemEntity.episodeCurrent;
    return GestureDetector(
      onTap: () {
        AppNavigator.push(context, MovieDetailPage(slug: itemEntity.slug));
      },
      onLongPress: () {
        // Long press also shows preview with haptic feedback
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

                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FastCachedImage(
                        url: AppUrl.convertImageAddition(itemEntity.posterUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.only(top: 5, left: 5),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        // color: AppColor.secondColor,
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFC77DFF), // Tím
                            Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                            Color(0xFFFFD275),
                          ], // Vàng],
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
                      ),
                      child: Text(
                        itemEntity.tmdb.voteAverage.toStringAsFixed(1),
                        style: TextStyle(
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
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Căn lề phải
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

  // Widget _itemChip({
  //   required String content,
  //   bool isGadient = false,
  //   double? size,
  //   bool isLeft = false,
  // }) {
  //   return Container(
  //     padding: EdgeInsets.all(5),
  //     decoration: BoxDecoration(
  //       color: isGadient ? null : Colors.white,
  //       borderRadius: isLeft
  //           ? BorderRadius.only(topLeft: Radius.circular(5))
  //           : BorderRadius.only(topRight: Radius.circular(5)),
  //       gradient: isGadient
  //           ? LinearGradient(
  //               colors: [Color(0xffe73827), Color.fromARGB(255, 254, 136, 115)],
  //               begin: Alignment.topRight,
  //               end: Alignment.bottomLeft,
  //             )
  //           : null,
  //     ),
  //     child: Center(
  //       child: Text(
  //         content,
  //         style: TextStyle(
  //           fontSize: size ?? 8,
  //           fontWeight: FontWeight.w600,
  //           color: AppColor.bgApp,
  //           decoration: TextDecoration.none,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
