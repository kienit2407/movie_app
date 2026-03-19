import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/cached_image.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_state.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_cubit.dart';
import 'package:movie_app/feature/home/presentation/widgets/blur_effect.dart';
import 'package:movie_app/feature/home/presentation/widgets/country_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/genre_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/overlay_gadient.dart';
import 'package:movie_app/feature/home/presentation/widgets/polk_effect.dart';
import 'package:movie_app/feature/home/presentation/widgets/recommend_movie_widget.dart';
import 'package:movie_app/feature/home/presentation/widgets/year_bottom_sheet.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final CarouselSliderController indexCarouselController;
  final ScrollController _scrollController = ScrollController();
  static const int itemCountStandart = 10;
  int currentIndex = 0;
  double _chipOpacity = 1.0;
  double _chipOffset = 0.0;
  bool isSelectedGenre = false;
  bool _isLoading = false;

  @override
  void initState() {
    indexCarouselController = CarouselSliderController();
    super.initState();
    // context.read<FetchFillterCubit>().fetchFillterGenreNotLoadMore(FillterMovieReq(typeList: '', fillterType: Filltertype.chinaMovie));
    // context.read<FetchFillterCubit>().fetchFillterGenreNotLoadMore(FillterMovieReq(typeList: '', fillterType: Filltertype.koreaMovie));
    // Theo dõi vị trí cuộn để điều khiển chip buttons
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        // Tính opacity: mờ dần trong 40px đầu tiên
        _chipOpacity = (1 - offset / 40).clamp(0.0, 1.0);
        // Tính offset: trượt lên tối đa 10px
        _chipOffset = offset.clamp(0.0, 30);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 92.h,
        foregroundColor: Colors.white,
        title: Column(
          children: [
            Row(
              children: [
                Image.asset(AppImage.splashLogo, scale: 1.5),
                const Spacer(),
                IconButton.outlined(
                  onPressed: () {
                    GenreBottomSheet.show(context);
                  },
                  icon: Icon(Iconsax.filter, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Stack(
                  children: [
                    IconButton.outlined(
                      onPressed: () {},
                      icon: Icon(Iconsax.notification, size: 20.sp),
                    ),
                    Positioned(
                      top: 11.h,
                      right: 11.w,
                      child: Container(
                        alignment: Alignment.center,
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(fontSize: 6.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  opacity: _chipOpacity,
                  child: Transform.translate(
                    offset: Offset(0, -_chipOffset),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildChipButton('Đề Xuất', isSelected: true),
                          SizedBox(width: 8.w),
                          _buildChipButton(
                            'Thể loại',
                            icon: Iconsax.arrow_down_1_copy,
                            showIcon: true,
                            onPressed: () {
                              GenreBottomSheet.show(context);
                            },
                            isSelected: isSelectedGenre,
                          ),
                          SizedBox(width: 8.w),
                          _buildChipButton(
                            onPressed: () => CountryBottomSheet.show(context),
                            'Quốc gia',
                            icon: Iconsax.arrow_down_1_copy,
                            showIcon: true,
                          ),
                          SizedBox(width: 8.w),
                          _buildChipButton(
                            onPressed: () => YearBottomSheet.show(context),
                            'Năm',
                            icon: Iconsax.arrow_down_1_copy,
                            showIcon: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  Colors.black,
                  Colors.black.withValues(alpha: .9),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          context.read<CarouselDisplayCubit>().getLatestMovie();
        },
        child: BlocBuilder<CarouselDisplayCubit, CarouselDisplayState>(
          builder: (context, state) {
            if (state is CarouselLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (state is CarouselFalure) {
              return Center(child: Text("Lỗi: ${state.message}"));
            } else if (state is CarouselSuccess) {
              return _buildContent();
            } else {
              return const Center(child: Text("Không có dữ liệu"));
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 100.h),
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          _buildCarouselPoster(),
          const MovieSectionWithScroll(),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  // Widget _lastedMovie() {
  //   return BlocBuilder<FetchFillterCubit, FetchFillterState>(
  //     builder: (context, state) {
  //       if (state is FetchFillterSuccess) {
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 10),
  //           child: Column(
  //             children: [
  //               _itemLatestMovieCountry(
  //                 content: "Korea Movie Latest",
  //                 gadient: LinearGradient(
  //                   colors: [
  //                     Color(0xff94D877),
  //                     Color(0xff8FD199),
  //                     Color.fromARGB(255, 197, 226, 224),
  //                   ],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //                 items: state.fillterMovieGenreEntity.items,
  //                 typeOfList: 'han-quoc'
  //               ),
  //               _itemLatestMovieCountry(
  //                 content: "China Movie Latest",
  //                 gadient: LinearGradient(
  //                   colors: [Color(0xffA088BD), Color.fromARGB(255, 216, 213, 220)],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //                 items: state.fillterMovieGenreEntity.items,
  //                 typeOfList: 'trung-quoc'
  //               ),
  //               // _itemLatestMovieCountry(
  //               //   content: "US-UK Movie Latest",
  //               //   gadient: LinearGradient(
  //               //     colors: [Color(0xffEAC66B), Color.fromARGB(255, 210, 204, 191)],
  //               //     begin: Alignment.topLeft,
  //               //     end: Alignment.bottomRight,
  //               //   ),
  //               // ),
  //             ],
  //           ),
  //         );
  //       }
  //       return SizedBox();
  //     },
  //   );
  // }

  int _visibleItemCount(List<ItemEntity> latestMovie) {
    if (latestMovie.isEmpty) return 0;
    return latestMovie.length < itemCountStandart
        ? latestMovie.length
        : itemCountStandart;
  }

  int _safeCurrentIndex(List<ItemEntity> latestMovie) {
    final visibleCount = _visibleItemCount(latestMovie);
    if (visibleCount == 0) return 0;
    if (currentIndex >= visibleCount) return 0;
    return currentIndex;
  }

  Widget _buildCarouselPoster() {
    return BlocConsumer<CarouselDisplayCubit, CarouselDisplayState>(
      listener: (context, state) {
        if (state is CarouselLoading) {
          _isLoading = true;
        } else {
          _isLoading = false;
        }
      },
      builder: (context, data) {
        if (data is CarouselSuccess && data.latestMovie.isNotEmpty) {
          return SizedBox(
            height: 0.89.sh,
            width: 1.sw,
            child: Stack(
              children: [
                //background image
                _buildBackgroundImage(data.latestMovie),
                //Gadient Overlay
                OverlayGadient(),
                //Background Blur Effect
                BlurEffect(),
                //Polk Effect
                _polkEffect(),
                //Movie Infora
                _buildInforSection(data.latestMovie),
              ],
            ),
          );
        }
        return SizedBox(
          height: 0.89.sh,
          child: const Center(child: SizedBox.shrink()),
        );
      },
    );
  }

  Widget _buildInforSection(List<ItemEntity> latestMovie) {
    final safeIndex = _safeCurrentIndex(latestMovie);
    final selectedMovie = latestMovie[safeIndex];

    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      top: 0.185.sh,
      child: Column(
        children: [
          _buildCarousel(latestMovie),
          SizedBox(height: 8.h),
          _buildCategory(selectedMovie.category),
          SizedBox(height: 18.h),
          _buildInforMovie(latestMovie),
          SizedBox(height: 15.h),
          _buildDotIndicator(latestMovie),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Iconsax.play_circle, 'Watch Now'),
                SizedBox(width: 10.w),
                _buildActionButton(Iconsax.info_circle, 'Information'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(List<CategoryEntity> category) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 6.w,
        runSpacing: 6.h,
        children: List.generate(category.length, (index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              category[index].name,
              style: TextStyle(fontSize: 10.sp),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInforMovie(List<ItemEntity> latestMovie) {
    final safeIndex = _safeCurrentIndex(latestMovie);
    final selectedMovie = latestMovie[safeIndex];

    return Skeletonizer(
      enabled: _isLoading,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              selectedMovie.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              selectedMovie.originName,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xfff85032),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Wrap(
                  direction: Axis.horizontal,
                  runSpacing: 10.h,
                  alignment: WrapAlignment.center,
                  spacing: 10.w,
                  children: [
                    _buildInforChip(
                      borderColor: const Color(0xfff85032),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5.w,
                        children: [
                          Text(
                            'iMdB',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xfff85032),
                            ),
                          ),
                          Text(
                            selectedMovie.tmdb.voteAverage.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildInforChip(
                      isGadient: true,
                      borderColor: Colors.transparent,
                      child: Text(
                        selectedMovie.quality,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildInforChip(
                      child: Text(
                        selectedMovie.year.toString(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildInforChip(
                      child: Text(
                        (selectedMovie.episodeCurrent == 'Full')
                            ? selectedMovie.time.toFormatEpisode()
                            : selectedMovie.time,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 10.w,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildInforChip(
                      backgroundColor: Colors.white,
                      child: Text(
                        selectedMovie.episodeCurrent,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildInforChip(
                      child: Text(
                        selectedMovie.lang,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipButton(
    String content, {
    IconData? icon,
    bool isSelected = false,
    bool showIcon = false,
    VoidCallback? onPressed,
  }) {
    return Container(
      alignment: Alignment.center,
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white),
        color: isSelected ? Colors.white : Colors.transparent,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 9.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              content,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
            if (showIcon) SizedBox(width: 5.w),
            showIcon
                ? Icon(
                    icon,
                    size: 14.sp,
                    color: isSelected ? Colors.black : Colors.white,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String content) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xffe73827), Color.fromARGB(255, 254, 136, 115)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size(0, 42.h),
            maximumSize: Size.fromWidth(200.w),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22.sp),
              SizedBox(width: 5.w),
              Text(
                content,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator(List<ItemEntity> latestMovie) {
    final visibleCount = _visibleItemCount(latestMovie);
    if (visibleCount == 0) return const SizedBox.shrink();
    final safeIndex = _safeCurrentIndex(latestMovie);

    return Skeletonizer(
      enabled: _isLoading,
      child: SizedBox(
        height: 34.h,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(visibleCount, (index) {
              final isSelected = safeIndex == index;
              return Padding(
                padding: EdgeInsets.only(
                  right: index == visibleCount - 1 ? 0 : 8.w,
                ),
                child: GestureDetector(
                  onTap: () {
                    indexCarouselController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : 1,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      curve: Curves.easeOutCubic,
                      duration: const Duration(milliseconds: 260),
                      width: isSelected ? 30.w : 24.w,
                      height: isSelected ? 30.w : 24.w,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: .45),
                          width: isSelected ? 2.w : 1.w,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: .2),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ]
                            : null,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: AppUrl.convertImageDirect(
                          latestMovie[index].posterUrl,
                        ),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.medium,
                        fadeInDuration: const Duration(milliseconds: 220),
                        placeholder: (context, url) =>
                            Container(color: Colors.white12),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.white10,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                            size: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildInforChip({
    Color? borderColor,
    bool isGadient = false,
    Widget? child,
    Color? backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? Colors.white),
        borderRadius: BorderRadius.circular(7.r),
        gradient: isGadient
            ? const LinearGradient(
                colors: [Color(0xffe73827), Color.fromARGB(255, 254, 136, 115)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
      ),
      child: child,
    );
  }

  Widget _buildBackgroundImage(List<ItemEntity> latestMovie) {
    final safeIndex = _safeCurrentIndex(latestMovie);

    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: CachedNetworkImage(
          key: ValueKey(latestMovie[safeIndex].posterUrl),
          imageUrl: AppUrl.convertImageDirect(latestMovie[safeIndex].posterUrl),
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 260),
          placeholder: (context, url) => Container(color: Colors.black12),
          errorWidget: (context, url, error) =>
              Container(color: Colors.black26),
        ),
      ),
    );
  }

  Widget _polkEffect() {
    return PolkBackGround(
      dotColor: AppColor.bgApp.withValues(alpha: .5),
      dotRadius: .55.r,
      spacing: 4.w,
    );
  }

  Widget _buildCarousel(List<ItemEntity> latestMovie) {
    final visibleCount = _visibleItemCount(latestMovie);
    if (visibleCount == 0) return const SizedBox.shrink();

    return Skeletonizer(
      enabled: _isLoading,
      child: ClipRRect(
        child: SizedBox(
          height: 0.37.sh,
          child: CarouselSlider.builder(
            carouselController: indexCarouselController,
            options: CarouselOptions(
              height: 0.35.sh,
              viewportFraction: .62,
              autoPlay: visibleCount > 1,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 680),
              autoPlayCurve: Curves.easeOutCubic,
              initialPage: 0,
              enlargeCenterPage: true,
              enlargeFactor: .2,
              enableInfiniteScroll: visibleCount > 1,
              pauseAutoPlayOnTouch: true,
              pauseAutoPlayInFiniteScroll: true,
              clipBehavior: Clip.none,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            itemCount: visibleCount,
            itemBuilder: (BuildContext context, int index, int realiindex) {
              final isSelected = _safeCurrentIndex(latestMovie) == index;
              return GestureDetector(
                onTap: () {
                  showAnimatedDialog(
                    context: context,
                    dialog: ShowDetailMovieDialog(
                      slug: latestMovie[index].slug,
                    ),
                  );
                },
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  showAnimatedDialog(
                    context: context,
                    dialog: ShowDetailMovieDialog(
                      slug: latestMovie[index].slug,
                    ),
                  );
                },
                child: Center(
                  child: RepaintBoundary(
                    child: AnimatedScale(
                      scale: isSelected ? 1 : .94,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: CachedImageContainer(
                        imageUrl: AppUrl.convertImageDirect(
                          latestMovie[index].posterUrl,
                        ),
                        height: 0.34.sh,
                        width: 0.57.sw,
                        boxFit: BoxFit.cover,
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        border: Border.all(color: Colors.white, width: 2.w),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .2),
                            blurRadius: 20.r,
                            offset: Offset(0, 10.h),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
