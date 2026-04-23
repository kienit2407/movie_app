import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movie_app/common/components/lost_network.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/common/helpers/watch_history_storage.dart';
import 'package:movie_app/common/models/watch_history_entry.dart';
import 'package:movie_app/core/config/utils/blocking_back_page.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/core/config/utils/package_infor.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_state.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/feature/detail_movie/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/usecase/get_movies_by_filter_usecase.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_state.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/home_ui_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/home_ui_state.dart';
import 'package:movie_app/feature/home/presentation/widgets/blur_effect.dart';
import 'package:movie_app/feature/home/presentation/widgets/comprehensive_filter_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/country_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/genre_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/home_skeleton.dart';
import 'package:movie_app/feature/home/presentation/widgets/overlay_gadient.dart';
import 'package:movie_app/feature/home/presentation/widgets/recommend_movie_widget.dart';
import 'package:movie_app/feature/home/presentation/widgets/year_bottom_sheet.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';
import 'package:movie_app/feature/search/presentation/pages/search_page.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const double _bannerPosterAspectRatio = 2 / 3;
  late final HomeUiCubit _homeUiCubit;
  CarouselSliderController? indexCarouselController;
  double itemCount = 0;
  double normalize = 0;
  final ScrollController _scrollController = ScrollController();
  int itemCountStandart = 20;
  String? selectedValue;
  final ValueNotifier<double> _currentPageNotifier = ValueNotifier<double>(0.0);
  int _carouselGen = 0; //  token để ignore callback của carousel cũ
  bool _pendingResetToFirst = false; //  trì hoãn reset cho tới khi jump xong
  String _lastCarouselKey = '';
  bool _carouselReady = false;

  HomeUiState get _uiState => _homeUiCubit.state;

  @override
  void initState() {
    _homeUiCubit = HomeUiCubit();
    _loadPackageInfo();
    indexCarouselController = CarouselSliderController();
    super.initState();

    // Theo dõi vị trí cuộn để điều khiển chip buttons
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      _homeUiCubit.updateScrollEffects(offset);
    });
  }

  @override
  void dispose() {
    _currentPageNotifier.dispose();
    _scrollController.dispose();
    indexCarouselController?.dispose();
    _homeUiCubit.close();
    super.dispose();
  }

  int _safeIndex(int length) {
    if (length <= 0) return 0;
    return _uiState.currentIndex.clamp(0, length - 1);
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfor.getPackageInfo();
    if (mounted) {
      _currentPageNotifier.value = 0.0;
      _homeUiCubit.setPackageInfo(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Take height size of device
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider.value(
      value: _homeUiCubit,
      child: Scaffold(
        extendBodyBehindAppBar: true, //-> dùng khi muốn làm appbar trong suốt
        extendBody:
            true, //-> cái này nó sẽ render full màn hình bottom nav trong suốt
        // bottom nav
        // bottomNavigationBar: Transform.translate(
        //   offset: Offset(0, -20),
        //   child: Container(
        //     margin: EdgeInsets.symmetric(horizontal: 20),
        //     height: 70,
        //     child: LiquidGlass(
        //       shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(50)),
        //       settings: LiquidGlassSettings(
        //         blur: 2,
        //         blend: 10
        //       ),
        //       child: Transform.translate(
        //         offset: Offset(0, 18),
        //         child: NavigationBar(
        //           indicatorColor: Colors.transparent,
        //           shadowColor: Colors.transparent,
        //           elevation: 0,
        //           surfaceTintColor: Colors.transparent,
        //           overlayColor: WidgetStateProperty.all(Colors.transparent),
        //           labelTextStyle: WidgetStateProperty.all(
        //             TextStyle(color: Colors.white, fontSize: 12),
        //           ),
        //           backgroundColor: Colors.transparent,
        //           destinations: [
        //             NavigationDestination(
        //               icon: Icon(Iconsax.home_2_copy,),
        //               selectedIcon: Icon(Iconsax.home_2),
        //               label: 'Home',
        //             ),
        //             NavigationDestination(
        //               icon: Icon(Iconsax.home_2_copy,),
        //               selectedIcon: Icon(Iconsax.home_2),
        //               label: 'Home',
        //             ),
        //             NavigationDestination(
        //               icon: Icon(Iconsax.home_2_copy,),
        //               selectedIcon: Icon(Iconsax.home_2),
        //               label: 'Home',
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        //app bar
        appBar: AppBar(
          toolbarHeight: 90.h,
          foregroundColor: Colors.white,
          title: Column(
            spacing: 10.h,
            children: [
              Row(
                children: [
                  Image.asset(AppImage.splashLogo, scale: 28),
                  Spacer(),
                  IconButton.outlined(
                    onPressed: () {
                      ComprehensiveFilterBottomSheet.show(context);
                    },
                    icon: Icon(Iconsax.filter_copy),
                  ),
                  SizedBox(width: 15.w),
                  IconButton.outlined(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchPage(),
                        ),
                      );
                    },
                    icon: Icon(Iconsax.search_normal_1_copy),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final uiState = context.read<HomeUiCubit>().state;
                  return AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    opacity: uiState.chipOpacity,
                    child: Transform.translate(
                      offset: Offset(0, -uiState.chipOffset),
                      child: Row(
                        spacing: 10.w,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildChipButton('Đề Xuất', isSelected: true),
                          _buildChipButton(
                            'Thể loại',
                            icon: Iconsax.arrow_down_1_copy,
                            showIcon: true,
                            onPressed: () {
                              GenreBottomSheet.show(context);
                            },
                            isSelected: uiState.isSelectedGenre,
                          ),
                          _buildChipButton(
                            onPressed: () => CountryBottomSheet.show(context),
                            'Quốc gia',
                            icon: Iconsax.arrow_down_1_copy,
                            showIcon: true,
                          ),
                          _buildChipButton(
                            onPressed: () => YearBottomSheet.show(context),
                            'Năm',
                            icon: Iconsax.arrow_down_1_copy,
                            showIcon: true,
                          ),
                        ],
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
                    Colors.black.withOpacity(.90),
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
            // Reset carousel state TRƯỚC khi gọi getLatestMovie
            _carouselGen++;
            _carouselReady = false;
            _lastCarouselKey = '';
            _currentPageNotifier.value = 0.0;
            _homeUiCubit.setCurrentIndex(0);
            indexCarouselController = CarouselSliderController();

            context.read<CarouselDisplayCubit>().getLatestMovie();
          },
          child: BlocBuilder<CarouselDisplayCubit, CarouselDisplayState>(
            builder: (context, state) {
              // 1. TRẠNG THÁI ĐANG TẢI
              if (state is CarouselLoading) {
                return const Center(child: HomeSkeleton());
              }
              // 2. TRẠNG THÁI LỖI (MẤT MẠNG)
              else if (state is CarouselFalure) {
                return CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Bắt buộc để vuốt được
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const Center(
                        child: LostNetworkPage(),
                      ), // Trang báo lỗi của bạn
                    ),
                  ],
                );
              }
              // 3. TRẠNG THÁI THÀNH CÔNG
              else if (state is CarouselSuccess) {
                return _buildContent(); // Hiển thị dữ liệu khi đã tải xong
              }
              // 4. TRẠNG THÁI KHÔNG CÓ DỮ LIỆU
              else {
                return CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Bắt buộc để vuốt được
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const Center(child: Text("Không có dữ liệu")),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return PrimaryScrollController(
      controller: _scrollController,
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          // primary: true,
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 100.h),
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              BlocBuilder<HomeUiCubit, HomeUiState>(
                buildWhen: (previous, current) =>
                    previous.carouselKeyCounter != current.carouselKeyCounter ||
                    previous.currentIndex != current.currentIndex,
                builder: (context, _) =>
                    _buildCarouselPoster(screenHeight, screenWidth),
              ),
              SizedBox(height: 10.h),
              const MovieSectionWithScroll(),
              SizedBox(height: 30.h),
              //HISTORICAL MOVIE
              _watchedMoviesSection(),
              SizedBox(height: 30.h),
              _lastedMovie(),
              SizedBox(height: 30.h),
              BlocBuilder<HomeUiCubit, HomeUiState>(
                buildWhen: (previous, current) =>
                    previous.version != current.version ||
                    previous.buildNumber != current.buildNumber ||
                    previous.appName != current.appName ||
                    previous.packageName != current.packageName,
                builder: (context, _) => _buildVersionInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lastedMovie() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(
              'Phim mới coóng!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            // padding: const EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
              gradient: LinearGradient(
                colors: [Color(0xff272A39), Color(0xff191A24)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                CountryMovieSection(
                  title: "Phim Hàn Quốc",
                  gradient: LinearGradient(
                    colors: [
                      Color(0xff94D877),
                      Color(0xff8FD199),
                      Color.fromARGB(255, 197, 226, 224),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  countrySlug: 'han-quoc',
                ),
                SizedBox(height: 20.h),
                CountryMovieSection(
                  title: "Phim Trung Quốc",
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffA088BD),
                      Color.fromARGB(255, 216, 213, 220),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  countrySlug: 'trung-quoc',
                ),
                SizedBox(height: 20.h),
                CountryMovieSection(
                  title: "Phim Mỹ - UK",
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffEAC66B),
                      Color.fromARGB(255, 210, 204, 191),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  countrySlug: 'au-my',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselPoster(double screenHeight, double screenWidth) {
    return BlocConsumer<CarouselDisplayCubit, CarouselDisplayState>(
      listener: (context, state) {
        if (state is CarouselSuccess) {
          _carouselGen++;
          _carouselReady = false;

          _pendingResetToFirst = false;
          _lastCarouselKey = '';

          _currentPageNotifier.value = 0.0;
          _homeUiCubit.setCurrentIndex(0);

          indexCarouselController = CarouselSliderController();
          _homeUiCubit.bumpCarouselKeyCounter();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _carouselReady = true;
          });
        }
      },
      builder: (context, data) {
        if (data is CarouselSuccess) {
          // chiều cao “thiết kế” theo XR: 0.89 * 896 ≈ 797
          // quy về theo width 414 => ratio ≈ 797/414 = 1.92
          final heroHeight = (screenWidth * 1.88).clamp(700.h, 900.h);
          return SizedBox(
            height: heroHeight,
            width: screenWidth,
            child: Stack(
              clipBehavior: Clip.hardEdge, // (2) chặn vẽ tràn đè xuống dưới
              children: [
                //background image
                _buildBackgroundImage(data.latestMovie),
                //Gadient Overlay
                OverlayGadient(),
                //Background Blur Effect
                BlurEffect(),
                //Polk Effect
                // _polkEffect(),
                //Movie Infora
                _buildInforSection(heroHeight, data.latestMovie),
              ],
            ),
          );
        }

        return SizedBox(
          height: screenHeight * .88,
          child: Center(child: Text('')),
        );
      },
    );
  }

  Widget _buildInforSection(double heroHeight, List<ItemEntity> latestMovie) {
    final safeTop = MediaQuery.of(context).padding.top;
    final minTopFromFilters = safeTop + 90.h + 10.h;
    final sectionTop = math.max(heroHeight * .17, minTopFromFilters);
    final safeIndex = _safeIndex(latestMovie.length);
    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      top: sectionTop,
      child: Column(
        children: [
          SizedBox(height: 8.h),
          _buildCarousel(heroHeight, latestMovie),
          SizedBox(height: 8.h),
          _buildCategory(latestMovie[safeIndex].category),
          SizedBox(height: 12.h),
          _buildInforMovie(latestMovie),
          SizedBox(height: 10.h),
          _buildDotIndicator(latestMovie),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            child: Row(
              spacing: 10.w,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Iconsax.play_circle, 'Xem Phim', () async {
                  await _navigateToPlayer(
                    latestMovie[_uiState.currentIndex].slug,
                  );
                }),
                _buildActionButton(Iconsax.info_circle, 'Thông Tin', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailPage(
                        slug: latestMovie[_uiState.currentIndex].slug,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(List<CategoryEntity> category) {
    return SizedBox(
      height: 36.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 70.w),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5.w,
          runSpacing: 5.h,
          children: List.generate(category.length, (index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.1),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                category[index].name,
                style: TextStyle(fontSize: 9.sp),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInforMovie(List<ItemEntity> latestMovie) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: Text(
            latestMovie[_uiState.currentIndex].name,
            textAlign: TextAlign.justify,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: Text(
            textAlign: TextAlign.justify,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            latestMovie[_uiState.currentIndex].originName,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xfff85032),
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            spacing: 10.h,
            children: [
              Wrap(
                direction: Axis.horizontal,
                runSpacing: 10.h,
                alignment: WrapAlignment.center,
                spacing: 10.w,
                children: [
                  _buildInforChip(
                    borderColor: Color(0xfff85032),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5.w,
                      children: [
                        Text(
                          'iMdB',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xfff85032),
                          ),
                        ),
                        Text(
                          latestMovie[_uiState.currentIndex].tmdb.voteAverage
                              .toStringAsFixed(1),
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
                      latestMovie[_uiState.currentIndex].quality,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildInforChip(
                    child: Text(
                      latestMovie[_uiState.currentIndex].year.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildInforChip(
                    child: Text(
                      (latestMovie[_uiState.currentIndex].episodeCurrent ==
                              'Full')
                          ? latestMovie[_uiState.currentIndex].time
                                .toFormatEpisode()
                          : latestMovie[_uiState.currentIndex].time,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 10.w,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildInforChip(
                    backgroundColor: Colors.white,
                    child: Text(
                      latestMovie[_uiState.currentIndex].episodeCurrent,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // if (latestMovie[_uiState.currentIndex].chieurap == false)
                  //   _buildInforChip(
                  //     isGadient: true,
                  //     borderColor: Colors.transparent,
                  //     child: const Text(
                  //       'Chiếu Rạp',
                  //       style: TextStyle(
                  //         fontSize: 10,
                  //         fontWeight: FontWeight.w600,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  if (latestMovie[_uiState.currentIndex].subDocquyen == true)
                    _buildInforChip(
                      isGadient: true,
                      borderColor: Colors.transparent,
                      child: Text(
                        'Sub Độc Quyền',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  _buildInforChip(
                    child: Text(
                      latestMovie[_uiState.currentIndex].lang,
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
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: showIcon ? 5.w : 0,
          children: [
            Text(
              content,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
            showIcon
                ? Icon(
                    icon,
                    size: 15.sp,
                    color: isSelected ? Colors.black : Colors.white,
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToPlayer(String slug) async {
    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        dialogContext = context;
        return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColor.fourthColor,

            size: 30,
          ),
        );
      },
    );

    try {
      HapticFeedback.mediumImpact();

      final cubit = DetailMovieCubit(sl<GetDetailMovieUsecase>());
      await cubit.getDetailMovie(slug);

      if (dialogContext != null && (dialogContext?.mounted ?? false)) {
        Navigator.pop(dialogContext!);
      }

      final state = cubit.state;
      if (state is! DetailMovieSuccessed) return;

      final detail = state.detailMovieModel;
      final movie = detail.movie;
      final episodes = detail.episodes;

      if (episodes.isEmpty) return;

      int? currentEpisodeNum;
      final episodeCurrent = movie.episode_current;

      if (episodeCurrent.toLowerCase().contains('hoàn tất')) {
        final match = RegExp(r'\((\d+)').firstMatch(episodeCurrent);
        if (match != null) {
          currentEpisodeNum = int.tryParse(match.group(1)!);
        }
      } else {
        final match = RegExp(r'(\d+)').firstMatch(episodeCurrent);
        if (match != null) {
          currentEpisodeNum = int.tryParse(match.group(1)!);
        }
      }

      int serverIndex = 0;
      int episodeIndex = 0;
      String? episodeLink;

      if (currentEpisodeNum != null) {
        for (int s = 0; s < episodes.length; s++) {
          final serverEpisodes = episodes[s].server_data;
          for (int e = 0; e < serverEpisodes.length; e++) {
            final ep = serverEpisodes[e];
            final epMatch = RegExp(r'(\d+)').firstMatch(ep.name);
            if (epMatch != null) {
              final epNum = int.tryParse(epMatch.group(1)!);
              if (epNum == currentEpisodeNum) {
                serverIndex = s;
                episodeIndex = e;
                episodeLink = ep.link_m3u8;
                break;
              }
            }
          }
          if (episodeLink != null) break;
        }
      }

      if (episodeLink == null) {
        if (episodes.isNotEmpty && episodes[0].server_data.isNotEmpty) {
          serverIndex = 0;
          episodeIndex = 0;
          episodeLink = episodes[0].server_data[0].link_m3u8;
        }
      }

      if (!mounted || episodeLink == null) {
        debugPrint('Could not find episode link');
        return;
      }

      Navigator.push(
        context,
        NoBackSwipeRoute(
          builder: (ctx) => BlocProvider.value(
            value: context.read<PlayerCubit>(),
            child: MoviePlayerPage(
              slug: movie.slug,
              movieName: movie.name,
              thumbnailUrl: movie.poster_url,
              episodes: episodes,
              movie: movie,
              initialEpisodeLink: episodeLink,
              initialEpisodeIndex: episodeIndex,
              initialServer: episodes[serverIndex].server_name,
              initialServerIndex: serverIndex,
            ),
          ),
        ),
      );
    } catch (e) {
      if (dialogContext != null && (dialogContext?.mounted ?? false)) {
        Navigator.pop(dialogContext!);
      }
      debugPrint('Error navigating to player: $e');
    }
  }

  Widget _buildActionButton(IconData icon, String content, VoidCallback onTap) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
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
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            maximumSize: Size.fromWidth(200.w),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10.r),
            ),
          ),
          onPressed: () {
            onTap();
            HapticFeedback.mediumImpact();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5.w,
            children: [
              Icon(icon, size: 25.sp),
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
    final count = math.min(latestMovie.length, 20);
    return SizedBox(
      height: 30.h,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 30.w),
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10.w,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            bool isSelected = _uiState.currentIndex == index;
            return GestureDetector(
              onTap: () {
                indexCarouselController?.jumpToPage(index);
              },
              child: AnimatedContainer(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 300),
                width: isSelected ? 30.w : 25.w,
                height: isSelected ? 30.w : 25.w,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      AppUrl.convertImageDirect(latestMovie[index].posterUrl),
                    ),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2.w)
                      : null,
                ),
              ),
            );
          }),
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
        boxShadow: isGadient
            ? const [
                BoxShadow(
                  color: Color(0xFFC77DFF),
                  blurRadius: 12,
                  offset: Offset(0, 0),
                  spreadRadius: -2,
                ),
              ]
            : null,
        gradient: isGadient
            ? const LinearGradient(
                colors: [
                  Color(0xFFC77DFF), // Tím
                  Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                  Color(0xFFFFD275),
                ], // Vàng],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
      ),
      child: child,
    );
  }

  Widget _buildBackgroundImage(List<ItemEntity> latestMovie) {
    final safeIndex = _safeIndex(latestMovie.length);
    final url = AppUrl.convertImageDirect(latestMovie[safeIndex].posterUrl);
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: Image.network(
          key: ValueKey(url),
          url,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) return child;
            return _buildBannerShimmer(borderRadius: BorderRadius.zero);
          },
          errorBuilder: (context, error, stackTrace) =>
              Container(color: const Color(0xff191A24)),
        ),
      ),
    );
  }

  // Widget _polkEffect() {
  //   return PolkBackGround(
  //     dotColor: AppColor.bgApp.withOpacity(.5),
  //     dotRadius: .5,
  //     spacing: 4,
  //   );
  // }

  Widget _buildCarousel(double heroHeight, List<ItemEntity> latestMovie) {
    final count = math.min(latestMovie.length, 20);
    if (count == 0) {
      _carouselReady = false;
      return const SizedBox.shrink();
    }

    final int buildGen =
        _carouselGen; //  gen tại thời điểm build (để guard callback)
    final carouselKey = latestMovie.take(count).map((e) => e.slug).join('|');

    if (_lastCarouselKey != carouselKey) {
      _lastCarouselKey = carouselKey;
      _currentPageNotifier.value = 0.0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chờ thêm 1 frame nữa để carousel slider hoàn tất khởi tạo internal PageView
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && buildGen == _carouselGen) _carouselReady = true;
      });
    });
    final carouselH = math.min(heroHeight * 0.42, 340.h);
    final posterHeight = carouselH;
    final posterWidth = posterHeight * _bannerPosterAspectRatio;

    return SizedBox(
      height: carouselH + 5.h,
      child: PrimaryScrollController.none(
        child: CarouselSlider.builder(
          key: ValueKey(
            '$carouselKey-${_uiState.carouselKeyCounter}',
          ), //  key mới mỗi khi data đổi
          carouselController: indexCarouselController!,
          options: CarouselOptions(
            height: carouselH,
            viewportFraction: .65,
            autoPlay: true,
            animateToClosest: true,
            initialPage: 0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              if (buildGen != _carouselGen) return;
              _currentPageNotifier.value = index.toDouble();
              if (!mounted) return;
              _homeUiCubit.setCurrentIndex(index);
            },
            onScrolled: (value) {
              if (value == null || !_carouselReady || buildGen != _carouselGen)
                return;
              final normalizedValue = value % count;
              // Bỏ qua jump lớn bất thường (do carousel internal page math khi khởi tạo)
              if ((_currentPageNotifier.value - normalizedValue).abs() >
                  count / 2) {
                return;
              }
              _currentPageNotifier.value = normalizedValue;
            },
          ),
          itemCount: count,
          itemBuilder: (BuildContext context, int index, int realiindex) {
            return ValueListenableBuilder<double>(
              valueListenable: _currentPageNotifier,
              builder: (context, currentPage, child) {
                final double itemCount = count.toDouble();

                double diff = index - currentPage;
                diff = diff - itemCount * (diff / itemCount).round();
                diff = diff.clamp(-1.0, 1.0);

                final double angle = diff * (math.pi * 0.1);
                return Center(
                  child: Transform.rotate(angle: angle, child: child),
                );
              },
              child: GestureDetector(
                onTap: () {
                  AppNavigator.push(
                    context,
                    MovieDetailPage(slug: latestMovie[index].slug),
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
                child: Container(
                  width: posterWidth,
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3.w),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: AspectRatio(
                    aspectRatio: _bannerPosterAspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        AppUrl.convertImageDirect(latestMovie[index].posterUrl),
                        fit: BoxFit.cover,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }
                              return _buildBannerShimmer();
                            },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildBannerShimmer(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _watchedMoviesSection() {
    return FutureBuilder<List<WatchHistoryEntry>>(
      future: WatchHistoryStorage().getHistory(limit: 20),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final watchedMovies = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Text(
                    'Bạn đã xem gần đây',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 260.h,
              child: ListView.separated(
                padding: EdgeInsets.only(left: 15.w),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemCount: watchedMovies.length,
                itemBuilder: (context, index) {
                  return _ItemWatchedMovie(entry: watchedMovies[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    if (_uiState.version.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          Text(
            'Version: ${_uiState.version} (${_uiState.buildNumber})',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            '${_uiState.appName} - ${_uiState.packageName}',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerShimmer({
    BorderRadius borderRadius = const BorderRadius.all(Radius.zero),
  }) {
    return Shimmer.fromColors(
      baseColor: const Color(0xff272A39),
      highlightColor: const Color(0xff4A4E69),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

extension on CarouselSliderController? {
  void dispose() {}
}

class CountryMovieSection extends StatefulWidget {
  final String title;
  final Gradient gradient;
  final String countrySlug;

  const CountryMovieSection({
    super.key,
    required this.title,
    required this.gradient,
    required this.countrySlug,
  });

  @override
  State<CountryMovieSection> createState() => _CountryMovieSectionState();
}

class _CountryMovieSectionState extends State<CountryMovieSection> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FetchFillterCubit(
            getMoviesByFilterUsecase: sl<GetMoviesByFilterUsecase>(),
          )..fetchMovies(
            FillterMovieReq(
              typeList: widget.countrySlug,
              fillterType: Filltertype.country,
            ),
          ),
      child: BlocBuilder<FetchFillterCubit, FetchFillterState>(
        builder: (context, state) {
          final List<ItemEntity> itemsList = [];
          if (state is FetchFillterLoaded) {
            itemsList.addAll(state.items.take(20));
          }
          final listH = 260.h;
          return Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: SharderText(
                      gradient: widget.gradient,
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      final filteredResult = FillterMovieReq(
                        typeList: widget.countrySlug,
                        fillterType: Filltertype.country,
                      );
                      AppNavigator.push(
                        context,
                        AllMoviePage(fillterReq: filteredResult),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: Text(
                        'Xem tất cả',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final filteredResult = FillterMovieReq(
                        typeList: widget.countrySlug,
                        fillterType: Filltertype.country,
                      );
                      AppNavigator.push(
                        context,
                        AllMoviePage(fillterReq: filteredResult),
                      );
                    },
                    icon: Icon(Iconsax.arrow_right_3_copy),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (itemsList.isEmpty)
                const _CountrySkeletonList()
              else
                SizedBox(
                  height: listH,
                  child: AnimationLimiter(
                    child: ListView.separated(
                      padding: EdgeInsets.only(left: 10.w),
                      scrollDirection: Axis.horizontal,
                      addAutomaticKeepAlives: true,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 10.w),
                      itemCount: itemsList.length,
                      cacheExtent: 500,
                      itemBuilder: (context, index) {
                        return _ItemLatestMovie(items: itemsList[index]);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemLatestMovie extends StatelessWidget {
  final ItemEntity items;
  const _ItemLatestMovie({required this.items});

  @override
  Widget build(BuildContext context) {
    // 1. Parse chuỗi ngôn ngữ sang List các Enum
    final List<MediaTagType> langTags = items.lang.toMediaTags();

    // 2. Lấy tập hiện tại (Check null an toàn)
    final String? currentEp = items.episodeCurrent;
    return GestureDetector(
      onTap: () {
        AppNavigator.push(context, MovieDetailPage(slug: items.slug));
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showAnimatedDialog(
          context: context,
          dialog: ShowDetailMovieDialog(slug: items.slug),
        );
      },
      child: SizedBox(
        width: 140.w,
        height: 260.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FastCachedImage(
                        url: AppUrl.convertImageAddition(items.posterUrl),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, loadingProgress) {
                          return _buildSkeletonForposter();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildSkeletonForposter();
                        },
                      ),
                    ),
                    Positioned(
                      top: 5.h,
                      left: 5.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
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
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          items.tmdb.voteAverage.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      // right: 0,
                      bottom: 5.h,
                      left: 5.w,
                      child: Column(
                        spacing: 3.h,
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
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                items.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              items.originName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required String text, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: color), // Viền đậm cùng tông
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white, // Chữ đậm cùng tông
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
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
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }
}

class _ItemWatchedMovie extends StatelessWidget {
  final WatchHistoryEntry entry;
  const _ItemWatchedMovie({required this.entry});

  @override
  Widget build(BuildContext context) {
    final List<MediaTagType> langTags = (entry.lang ?? '').toMediaTags();
    final progress = entry.progressPercent;

    return GestureDetector(
      onTap: () {
        AppNavigator.push(context, MovieDetailPage(slug: entry.slug));
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showAnimatedDialog(
          context: context,
          dialog: ShowDetailMovieDialog(slug: entry.slug),
        );
      },
      child: SizedBox(
        width: 140.w,
        height: 260.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FastCachedImage(
                        url: AppUrl.convertImageAddition(entry.posterUrl),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, loadingProgress) {
                          return AspectRatio(
                            aspectRatio: 2 / 3,
                            child: Shimmer.fromColors(
                              baseColor: Color(0xff272A39),
                              highlightColor: Color(0xff4A4E69),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return AspectRatio(
                            aspectRatio: 2 / 3,
                            child: Shimmer.fromColors(
                              baseColor: Color(0xff272A39),
                              highlightColor: Color(0xff4A4E69),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (entry.rating != null)
                      Positioned(
                        top: 5.h,
                        left: 5.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 3.h,
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
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            entry.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 2.h,
                      left: 0,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              top: 4.h,
                              bottom: 4.h,
                              left: 5.w,
                              right: 5.w,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              spacing: 3.h,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...langTags.map(
                                  (tag) => _buildBadge(
                                    text: tag.label,
                                    color: tag.color,
                                  ),
                                ),
                                if (entry.episodeCurrent.isNotEmpty &&
                                    entry.episodeCurrent != 'Full')
                                  _buildBadge(
                                    text: EpisodeFormatter.toShort(
                                      entry.episodeCurrent,
                                    ),
                                    color: Colors.redAccent,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (progress > 0)
                      Positioned(
                        left: 1,
                        right: 1,
                        bottom: -1,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double p = entry.progressPercent;
                              if (p > 1) p /= 100; //  phòng trường hợp 0..100
                              p = p.clamp(0.0, 1.0); //  chặn vượt

                              return Align(
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: p,
                                  child: Container(
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
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              entry.originName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBadge({required String text, required Color color}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 9.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _CountrySkeletonList extends StatelessWidget {
  const _CountrySkeletonList();

  @override
  Widget build(BuildContext context) {
    final listH = 260.h;
    return SizedBox(
      height: listH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 10.w),
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 100.w,
            child: Shimmer.fromColors(
              baseColor: const Color(0xff272A39).withOpacity(0.2),
              highlightColor: const Color(0xff191A24).withOpacity(0.2),
              child: SizedBox(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      height: 12.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      height: 10.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
