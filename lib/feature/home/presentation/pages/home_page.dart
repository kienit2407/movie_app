import 'dart:async';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movie_app/common/components/app_auto_scroll_text.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/lost_network.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/constants/const_globals.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/config/utils/package_infor.dart';
import 'package:movie_app/core/player_overlay_launcher.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_state.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_cubit.dart';
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
import 'package:movie_app/feature/home/notification/new_movie_notification_coordinator.dart';
import 'package:movie_app/feature/home/notification/new_movie_inbox.dart';
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
import 'package:movie_app/feature/home/presentation/widgets/top_movie_rankings.dart';
import 'package:movie_app/feature/hub/presentation/pages/hub_page.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const double _bannerPosterAspectRatio = 2 / 3;
  static const int _homePosterPrecacheLimit = 8;
  static const int _firstPosterPrecacheBatchSize = 3;
  static const int _dotLoopMultiplier = 201;
  static const int _dotLoopStartMultiplier = _dotLoopMultiplier ~/ 2;
  static const double _carouselVirtualPageBase = 10000.0;
  late final HomeUiCubit _homeUiCubit;
  CarouselSliderController? indexCarouselController;
  double itemCount = 0;
  double normalize = 0;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _dotScrollController = ScrollController();
  int itemCountStandart = 20;
  String? selectedValue;
  final ValueNotifier<double> _currentPageNotifier = ValueNotifier<double>(0.0);
  final Set<String> _preloadedHomePosterUrls = <String>{};
  int _carouselGen = 0; //  token để ignore callback của carousel cũ
  String _lastCarouselKey = '';
  String _lastDotCarouselKey = '';
  int _dotVirtualIndex = 0;
  int? _lastScheduledDotVirtualIndex;
  double? _lastScheduledDotViewportWidth;
  double? _lastScheduledDotItemExtent;
  bool _carouselReady = false;
  bool _carouselReadyFrameScheduled = false;
  bool _notificationSetupStarted = false;
  int _rankingsRefreshGeneration = 0;

  HomeUiState get _uiState => _homeUiCubit.state;

  int _cacheExtent(double logicalPixels, {int? maxPhysicalPixels}) {
    final pixelRatio = View.of(context).devicePixelRatio;
    final physicalPixels = math.max(1, (logicalPixels * pixelRatio).round());
    return maxPhysicalPixels == null
        ? physicalPixels
        : math.min(physicalPixels, maxPhysicalPixels);
  }

  ImageProvider _optimizedPosterProvider(
    String url, {
    required int cacheWidth,
    int? cacheHeight,
  }) {
    return ResizeImage(
      FastCachedImageProvider(url),
      width: cacheWidth,
      height: cacheHeight,
    );
  }

  void _setCurrentPageIfChanged(double value, {bool force = false}) {
    if (!force && (_currentPageNotifier.value - value).abs() < 0.01) return;
    _currentPageNotifier.value = value;
  }

  void _setCurrentIndexIfChanged(int index) {
    if (!mounted || _homeUiCubit.state.currentIndex == index) return;
    _homeUiCubit.setCurrentIndex(index);
  }

  double _normalizeCarouselPage(double page, int count) {
    final normalized = (page - _carouselVirtualPageBase) % count;
    return normalized < 0 ? normalized + count : normalized;
  }

  void _scheduleCarouselReady(int buildGen) {
    if (_carouselReady || _carouselReadyFrameScheduled) return;

    _carouselReadyFrameScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _carouselReadyFrameScheduled = false;
        if (buildGen == _carouselGen) _carouselReady = true;
      });
    });
  }

  @override
  void initState() {
    _homeUiCubit = HomeUiCubit();
    _loadPackageInfo();
    indexCarouselController = CarouselSliderController();
    super.initState();
    HubTabReselectNotifier.instance.addListener(_onHubTabReselected);

    // Theo dõi vị trí cuộn để điều khiển chip buttons
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      _homeUiCubit.updateScrollEffects(offset);
    });
  }

  @override
  void dispose() {
    HubTabReselectNotifier.instance.removeListener(_onHubTabReselected);
    _currentPageNotifier.dispose();
    _scrollController.dispose();
    _dotScrollController.dispose();
    indexCarouselController?.dispose();
    _homeUiCubit.close();
    super.dispose();
  }

  void _onHubTabReselected() {
    if (HubTabReselectNotifier.instance.index != 0) return;
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfor.getPackageInfo();
    if (mounted) {
      _setCurrentPageIfChanged(0.0, force: true);
      _homeUiCubit.setPackageInfo(
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    }
  }

  void _precacheHomePosters(List<ItemEntity> latestMovie) {
    if (!mounted || latestMovie.isEmpty) return;

    final urls = <String>{};
    for (final movie in latestMovie.take(_homePosterPrecacheLimit)) {
      if (movie.posterUrl.trim().isEmpty) continue;

      urls.add(movie.posterUrl);
    }

    final freshUrls = urls
        .where((url) => url.trim().isNotEmpty)
        .where(_preloadedHomePosterUrls.add)
        .toList(growable: false);

    if (freshUrls.isEmpty) return;

    final firstBatch = freshUrls
        .take(_firstPosterPrecacheBatchSize)
        .toList(growable: false);
    final nextBatch = freshUrls
        .skip(_firstPosterPrecacheBatchSize)
        .toList(growable: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_precachePosterBatch(firstBatch));

      if (nextBatch.isNotEmpty) {
        unawaited(_precacheDelayedPosterBatch(nextBatch));
      }
    });
  }

  Future<void> _precacheDelayedPosterBatch(List<String> urls) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    await _precachePosterBatch(urls);
  }

  Future<void> _precachePosterBatch(List<String> urls) async {
    if (!mounted || urls.isEmpty) return;

    final cacheWidth = _cacheExtent(260.w);
    final cacheHeight = _cacheExtent(390.h);

    for (final url in urls) {
      if (!mounted) return;

      try {
        await precacheImage(
          _optimizedPosterProvider(
            url,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
          ),
          context,
        );
      } catch (_) {
        // Ignore single-image failures; Home should keep rendering normally.
      }

      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  void _handleCarouselSuccess(CarouselSuccess state) {
    if (!mounted) return;

    _precacheHomePosters(state.latestMovie);
    if (!_notificationSetupStarted) {
      _notificationSetupStarted = true;
      unawaited(_prepareNewMovieNotifications(state.latestMovie));
    }
    _carouselGen++;
    _carouselReady = false;
    _carouselReadyFrameScheduled = false;
    _lastCarouselKey = '';
    _lastDotCarouselKey = '';
    _dotVirtualIndex = 0;
    _lastScheduledDotVirtualIndex = null;
    _lastScheduledDotViewportWidth = null;
    _lastScheduledDotItemExtent = null;
    _setCurrentPageIfChanged(0.0, force: true);
    _setCurrentIndexIfChanged(0);
    indexCarouselController = CarouselSliderController();
    _homeUiCubit.bumpCarouselKeyCounter();
  }

  Future<void> _prepareNewMovieNotifications(
    List<ItemEntity> latestMovies,
  ) async {
    try {
      final coordinator = sl<NewMovieNotificationCoordinator>();
      final setup = await coordinator.prepareHome(latestMovies);
      if (!mounted || !setup.shouldShowOnboarding) return;

      final shouldEnable = await showAnimatedDialog<bool>(
        context: context,
        barrierDismissible: false,
        dialog: const AppAlertDialog(
          icon: Icon(Iconsax.notification_copy, size: 30),
          title: 'Nhận thông báo phim mới?',
          content:
              'Liquid Phim có thể kiểm tra định kỳ trong nền và thông báo '
              'khi phát hiện phim mới. Hệ điều hành có thể thực hiện việc '
              'kiểm tra trễ hơn 20 phút để tiết kiệm pin.',
          buttonTitle: 'Bật thông báo',
          cancelButtonTitle: 'Không bật',
        ),
      );

      if (shouldEnable == true) {
        final permissionGranted = await coordinator.enableNotifications();
        if (!mounted || permissionGranted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quyền thông báo chưa được bật. Bạn có thể bật lại trong '
              'Cài đặt của điện thoại.',
            ),
          ),
        );
      } else {
        await coordinator.declineNotifications();
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[NewMovieNotifications] Home setup failed: $error\n$stackTrace',
      );
      _notificationSetupStarted = false;
    }
  }

  Widget _buildCarouselFailure(String? message) {
    final normalizedMessage = message?.toLowerCase() ?? '';
    final isNetworkFailure =
        normalizedMessage.contains('networkexception') ||
        normalizedMessage.contains('connection') ||
        normalizedMessage.contains('network');

    if (isNetworkFailure) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: const Center(child: LostNetworkPage()),
          ),
        ],
      );
    }

    debugPrint('[HomeCarousel] $message');
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 42.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Không thể tải dữ liệu phim.\n'
                    'Kéo xuống để thử lại.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(AppImage.splashIcon, scale: 28),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 2.h,
                      children: [
                        Text(
                          Global.instance.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondColor,
                          ),
                        ),
                        Text(
                          Global.instance.subTilleLogo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: () {
                      ComprehensiveFilterBottomSheet.show(context);
                    },
                    icon: Icon(Iconsax.filter_copy),
                  ),
                  SizedBox(width: 8.w),
                  BlocBuilder<NewMovieInboxCubit, NewMovieInboxState>(
                    buildWhen: (previous, current) =>
                        previous.unreadCount != current.unreadCount,
                    builder: (context, inboxState) {
                      final count = inboxState.unreadCount;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton.outlined(
                            tooltip: 'Thông báo',
                            onPressed: () =>
                                context.push(AppRoutes.notifications),
                            icon: const Icon(Iconsax.notification_copy),
                          ),
                          // SvgPicture.asset(
                          //   'assets/icons/main_icon.svg',
                          //   width: 24.w,
                          //   height: 24.h,
                          // ),
                          if (count > 0)
                            Positioned(
                              right: 1.w,
                              top: 1.h,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16.w,
                                  minHeight: 16.h,
                                ),
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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
            _carouselReadyFrameScheduled = false;
            _lastCarouselKey = '';
            _lastDotCarouselKey = '';
            _dotVirtualIndex = 0;
            _lastScheduledDotVirtualIndex = null;
            _lastScheduledDotViewportWidth = null;
            _lastScheduledDotItemExtent = null;
            _setCurrentPageIfChanged(0.0, force: true);
            _setCurrentIndexIfChanged(0);
            indexCarouselController = CarouselSliderController();

            await context.read<CarouselDisplayCubit>().getLatestMovie();
            if (mounted) {
              setState(() => _rankingsRefreshGeneration++);
            }
          },
          child: BlocConsumer<CarouselDisplayCubit, CarouselDisplayState>(
            listener: (context, state) {
              if (state is CarouselSuccess) {
                _handleCarouselSuccess(state);
              }
            },
            builder: (context, state) {
              // 1. TRẠNG THÁI ĐANG TẢI
              if (state is CarouselLoading) {
                return const Center(child: HomeSkeleton());
              }
              // 2. TRẠNG THÁI LỖI
              else if (state is CarouselFalure) {
                return _buildCarouselFailure(state.message);
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
          key: const PageStorageKey<String>('home-scroll-view'),
          // primary: true,
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 100.h),
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              BlocBuilder<HomeUiCubit, HomeUiState>(
                buildWhen: (previous, current) =>
                    previous.carouselKeyCounter != current.carouselKeyCounter,
                builder: (context, _) =>
                    _buildCarouselPoster(screenHeight, screenWidth),
              ),
              SizedBox(height: 10.h),
              const MovieSectionWithScroll(),
              SizedBox(height: 30.h),
              _lastedMovie(),
              SizedBox(height: 30.h),
              TopMovieRankings(refreshGeneration: _rankingsRefreshGeneration),
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
                  key: const ValueKey('country-section-han-quoc'),
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
                  key: const ValueKey('country-section-trung-quoc'),
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
                  key: const ValueKey('country-section-au-my'),
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
    return BlocBuilder<CarouselDisplayCubit, CarouselDisplayState>(
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
          BlocSelector<HomeUiCubit, HomeUiState, int>(
            selector: (state) => state.currentIndex,
            builder: (context, selectedIndex) {
              if (latestMovie.isEmpty) return const SizedBox.shrink();

              final safeIndex = selectedIndex
                  .clamp(0, latestMovie.length - 1)
                  .toInt();
              final selectedMovie = latestMovie[safeIndex];

              return Column(
                children: [
                  _buildCategory(selectedMovie.category),
                  SizedBox(height: 12.h),
                  _buildInforMovie(selectedMovie),
                  SizedBox(height: 10.h),
                  _buildDotIndicator(latestMovie, safeIndex),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    child: Row(
                      spacing: 10.w,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          Iconsax.play_circle,
                          'Xem Phim',
                          () async {
                            await _navigateToPlayer(selectedMovie.slug);
                          },
                        ),
                        _buildActionButton(
                          Iconsax.info_circle,
                          'Thông Tin',
                          () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailPage(slug: selectedMovie.slug),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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

  Widget _buildInforMovie(ItemEntity movie) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: AppAutoScrollText(
            movie.name,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: AppAutoScrollText(
            movie.originName,
            textAlign: TextAlign.justify,
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
                          movie.tmdb.voteAverage.toStringAsFixed(1),
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
                      movie.quality,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildInforChip(
                    child: Text(
                      movie.year.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildInforChip(
                    child: Text(
                      (movie.episodeCurrent == 'Full')
                          ? movie.time.toFormatEpisode()
                          : movie.time,
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
                      movie.episodeCurrent,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // if (movie.chieurap == false)
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
                  if (movie.subDocquyen == true)
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
                      movie.lang,
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

  String _episodeLink(ServerData episode) {
    return episode.link_m3u8.isNotEmpty
        ? episode.link_m3u8
        : episode.link_embed;
  }

  _PlayerEpisodeTarget? _targetFromIndexes(
    List<EpisodesModel> episodes,
    int serverIndex,
    int episodeIndex, {
    String? fallbackLink,
  }) {
    if (serverIndex < 0 || serverIndex >= episodes.length) return null;

    final server = episodes[serverIndex];
    if (server.server_data.isEmpty) return null;
    if (episodeIndex < 0 || episodeIndex >= server.server_data.length) {
      return null;
    }

    final episode = server.server_data[episodeIndex];
    final link = _episodeLink(episode).isNotEmpty
        ? _episodeLink(episode)
        : fallbackLink;
    if (link == null || link.isEmpty) return null;

    return _PlayerEpisodeTarget(
      serverIndex: serverIndex,
      episodeIndex: episodeIndex,
      episodeLink: link,
    );
  }

  _PlayerEpisodeTarget? _firstPlayableTarget(List<EpisodesModel> episodes) {
    for (int serverIndex = 0; serverIndex < episodes.length; serverIndex++) {
      final server = episodes[serverIndex];
      for (
        int episodeIndex = 0;
        episodeIndex < server.server_data.length;
        episodeIndex++
      ) {
        final link = _episodeLink(server.server_data[episodeIndex]);
        if (link.isNotEmpty) {
          return _PlayerEpisodeTarget(
            serverIndex: serverIndex,
            episodeIndex: episodeIndex,
            episodeLink: link,
          );
        }
      }
    }
    return null;
  }

  _PlayerEpisodeTarget? _targetFromLatestEpisode(
    String episodeCurrent,
    List<EpisodesModel> episodes,
  ) {
    if (episodes.isEmpty) return null;

    int? currentEpisodeNum;

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

    if (currentEpisodeNum != null) {
      for (int serverIndex = 0; serverIndex < episodes.length; serverIndex++) {
        final serverEpisodes = episodes[serverIndex].server_data;
        for (
          int episodeIndex = 0;
          episodeIndex < serverEpisodes.length;
          episodeIndex++
        ) {
          final ep = serverEpisodes[episodeIndex];
          final epMatch = RegExp(r'(\d+)').firstMatch(ep.name);
          if (epMatch == null) continue;

          final epNum = int.tryParse(epMatch.group(1)!);
          if (epNum == currentEpisodeNum) {
            final target = _targetFromIndexes(
              episodes,
              serverIndex,
              episodeIndex,
            );
            if (target != null) return target;
          }
        }
      }
    }

    return _firstPlayableTarget(episodes);
  }

  Future<void> _navigateToPlayer(String slug) async {
    BuildContext? dialogContext;
    void closeLoadingDialog() {
      final loadingContext = dialogContext;
      if (loadingContext != null && loadingContext.mounted) {
        Navigator.pop(loadingContext);
      }
      dialogContext = null;
    }

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

      closeLoadingDialog();

      final state = cubit.state;
      if (state is! DetailMovieSuccessed) return;

      final detail = state.detailMovieModel;
      final movie = detail.movie;
      final episodes = detail.episodes;

      if (episodes.isEmpty) return;

      final target = _targetFromLatestEpisode(movie.episode_current, episodes);

      final selectedTarget = target;
      if (!mounted || selectedTarget == null) {
        debugPrint('Could not find episode link');
        return;
      }

      context.openMoviePlayer(
        MoviePlayerArgs(
          movie.slug,
          movie.poster_url,
          selectedTarget.episodeLink,
          selectedTarget.episodeIndex,
          episodes[selectedTarget.serverIndex].server_name,
          movie.name,
          episodes,
          movie,
          initialServerIndex: selectedTarget.serverIndex,
        ),
      );
    } catch (e) {
      closeLoadingDialog();
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

  Widget _buildDotIndicator(List<ItemEntity> latestMovie, int selectedIndex) {
    final count = math.min(latestMovie.length, 20);
    if (count == 0) return const SizedBox.shrink();

    final selectedRealIndex = _positiveModulo(selectedIndex, count);
    final carouselKey = latestMovie.take(count).map((e) => e.slug).join('|');

    return SizedBox(
      height: 30.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemExtent = 40.w;
          final dataChanged = _lastDotCarouselKey != carouselKey;

          if (dataChanged) {
            _lastDotCarouselKey = carouselKey;
            _dotVirtualIndex =
                (count * _dotLoopStartMultiplier) + selectedRealIndex;
            _lastScheduledDotVirtualIndex = null;
            _lastScheduledDotViewportWidth = null;
            _lastScheduledDotItemExtent = null;
          }

          _scheduleSelectedDotCenter(
            selectedIndex: selectedRealIndex,
            count: count,
            itemExtent: itemExtent,
            viewportWidth: constraints.maxWidth,
            jump: dataChanged,
          );

          if (count == 1) {
            final url = latestMovie.first.posterUrl;
            return Center(child: _buildDotItem(url: url, isSelected: true));
          }

          return ListView.builder(
            controller: _dotScrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count * _dotLoopMultiplier,
            itemBuilder: (context, virtualIndex) {
              final realIndex = _positiveModulo(virtualIndex, count);
              final isSelected = selectedRealIndex == realIndex;
              final url = latestMovie[realIndex].posterUrl;

              return SizedBox(
                width: itemExtent,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _dotVirtualIndex = virtualIndex;
                      indexCarouselController?.jumpToPage(realIndex);
                    },
                    child: _buildDotItem(url: url, isSelected: isSelected),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDotItem({required String url, required bool isSelected}) {
    final cacheSize = _cacheExtent(48.w);

    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      width: isSelected ? 30.w : 25.w,
      height: isSelected ? 30.w : 25.w,
      padding: EdgeInsets.all(isSelected ? 2.w : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white, width: 2.w) : null,
      ),
      child: ClipOval(
        child: Image(
          key: ValueKey('dot-$url'),
          image: _optimizedPosterProvider(
            url,
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
          ),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: const Color(0xff191A24)),
        ),
      ),
    );
  }

  void _scheduleSelectedDotCenter({
    required int selectedIndex,
    required int count,
    required double itemExtent,
    required double viewportWidth,
    required bool jump,
  }) {
    if (count <= 1 || viewportWidth <= 0) return;

    final currentVirtualIndex = _currentDotVirtualIndex(
      itemExtent: itemExtent,
      viewportWidth: viewportWidth,
    );
    final targetVirtualIndex = _nearestDotVirtualIndex(
      selectedIndex: selectedIndex,
      count: count,
      currentVirtualIndex: currentVirtualIndex,
    );

    _dotVirtualIndex = targetVirtualIndex;

    final alreadyScheduled =
        !jump &&
        _lastScheduledDotVirtualIndex == targetVirtualIndex &&
        _lastScheduledDotViewportWidth == viewportWidth &&
        _lastScheduledDotItemExtent == itemExtent;

    if (alreadyScheduled) return;

    _lastScheduledDotVirtualIndex = targetVirtualIndex;
    _lastScheduledDotViewportWidth = viewportWidth;
    _lastScheduledDotItemExtent = itemExtent;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_dotScrollController.hasClients) return;

      final targetOffset =
          (targetVirtualIndex * itemExtent) +
          (itemExtent / 2) -
          (viewportWidth / 2);
      final maxScrollExtent = _dotScrollController.position.maxScrollExtent;
      final offset = targetOffset.clamp(0.0, maxScrollExtent).toDouble();

      if ((_dotScrollController.offset - offset).abs() <= 0.5) return;

      if (jump) {
        _dotScrollController.jumpTo(offset);
        return;
      }

      _dotScrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  int _currentDotVirtualIndex({
    required double itemExtent,
    required double viewportWidth,
  }) {
    if (!_dotScrollController.hasClients || itemExtent <= 0) {
      return _dotVirtualIndex;
    }

    final centeredOffset =
        _dotScrollController.offset + (viewportWidth / 2) - (itemExtent / 2);
    return (centeredOffset / itemExtent).round();
  }

  int _nearestDotVirtualIndex({
    required int selectedIndex,
    required int count,
    required int currentVirtualIndex,
  }) {
    if (count <= 0) return 0;

    final baseIndex =
        currentVirtualIndex - _positiveModulo(currentVirtualIndex, count);
    final candidates = <int>[
      baseIndex + selectedIndex - count,
      baseIndex + selectedIndex,
      baseIndex + selectedIndex + count,
    ];

    return candidates.reduce((best, candidate) {
      final bestDistance = (best - currentVirtualIndex).abs();
      final candidateDistance = (candidate - currentVirtualIndex).abs();
      return candidateDistance < bestDistance ? candidate : best;
    });
  }

  int _positiveModulo(int value, int modulo) {
    if (modulo == 0) return 0;
    final result = value % modulo;
    return result < 0 ? result + modulo : result;
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
    if (latestMovie.isEmpty) {
      return Positioned.fill(child: Container(color: const Color(0xff191A24)));
    }

    final mediaSize = MediaQuery.sizeOf(context);
    final cacheWidth = _cacheExtent(mediaSize.width, maxPhysicalPixels: 1080);
    final cacheHeight = _cacheExtent(mediaSize.height, maxPhysicalPixels: 1620);

    return BlocSelector<HomeUiCubit, HomeUiState, int>(
      selector: (state) => state.currentIndex,
      builder: (context, selectedIndex) {
        final safeIndex = selectedIndex
            .clamp(0, latestMovie.length - 1)
            .toInt();
        final url = latestMovie[safeIndex].posterUrl;

        return Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Image(
              key: ValueKey(url),
              image: _optimizedPosterProvider(
                url,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
              ),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xff191A24)),
            ),
          ),
        );
      },
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
    final enableInfiniteScroll = count > 1;
    final carouselInstanceKey = '$carouselKey-$buildGen';

    if (_lastCarouselKey != carouselKey) {
      _lastCarouselKey = carouselKey;
      _setCurrentPageIfChanged(0.0, force: true);
    }

    _scheduleCarouselReady(buildGen);
    final carouselH = math.min(heroHeight * 0.42, 340.h);
    final posterHeight = carouselH;
    final posterWidth = posterHeight * _bannerPosterAspectRatio;
    final posterCacheWidth = _cacheExtent(posterWidth, maxPhysicalPixels: 900);
    final posterCacheHeight = _cacheExtent(
      posterHeight,
      maxPhysicalPixels: 1350,
    );

    return SizedBox(
      height: carouselH + 5.h,
      child: PrimaryScrollController.none(
        child: CarouselSlider.builder(
          key: ValueKey(carouselInstanceKey), //  key mới mỗi khi data đổi
          carouselController: indexCarouselController!,
          options: CarouselOptions(
            height: carouselH,
            viewportFraction: .65,
            autoPlay: true,
            animateToClosest: true,
            initialPage: 0,
            enableInfiniteScroll: enableInfiniteScroll,
            enlargeCenterPage: true,
            clipBehavior: Clip.none,
            pageViewKey: PageStorageKey('page-$carouselInstanceKey'),
            onPageChanged: (index, reason) {
              if (buildGen != _carouselGen) return;
              _setCurrentPageIfChanged(index.toDouble(), force: true);
              _setCurrentIndexIfChanged(index);
            },
            onScrolled: (value) {
              if (value == null ||
                  !_carouselReady ||
                  buildGen != _carouselGen) {
                return;
              }
              _setCurrentPageIfChanged(_normalizeCarouselPage(value, count));
            },
          ),
          itemCount: count,
          itemBuilder: (context, index, _) {
            return _HomeCarouselItem(
              movie: latestMovie[index],
              index: index,
              count: count,
              posterWidth: posterWidth,
              posterCacheWidth: posterCacheWidth,
              posterCacheHeight: posterCacheHeight,
              currentPageListenable: _currentPageNotifier,
              imageProviderBuilder: _optimizedPosterProvider,
              errorBuilder: () => _buildBannerShimmer(),
            );
          },
        ),
      ),
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
  late final FetchFillterCubit _filterCubit;

  @override
  void initState() {
    super.initState();
    _filterCubit =
        FetchFillterCubit(
          getMoviesByFilterUsecase: sl<GetMoviesByFilterUsecase>(),
        )..fetchMovies(
          FillterMovieReq(
            typeList: widget.countrySlug,
            fillterType: Filltertype.country,
          ),
        );
  }

  @override
  void dispose() {
    _filterCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _filterCubit,
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
                      key: PageStorageKey<String>(
                        'country-movies-${widget.countrySlug}',
                      ),
                      padding: EdgeInsets.only(left: 10.w),
                      scrollDirection: Axis.horizontal,
                      addAutomaticKeepAlives: true,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 10.w),
                      itemCount: itemsList.length,
                      cacheExtent: 500,
                      itemBuilder: (context, index) {
                        final item = itemsList[index];
                        return _ItemLatestMovie(
                          key: ValueKey(item.slug),
                          items: item,
                        );
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
  const _ItemLatestMovie({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // 1. Parse chuỗi ngôn ngữ sang List các Enum
    final List<MediaTagType> langTags = items.lang.toMediaTags();
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final posterCacheWidth = math.min((140.w * pixelRatio).round(), 600);
    final posterCacheHeight = math.min((200.h * pixelRatio).round(), 900);

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
                      child: Image(
                        key: ValueKey('${items.slug}:${items.posterUrl}'),
                        image: ResizeImage(
                          FastCachedImageProvider(items.posterUrl),
                          width: posterCacheWidth,
                          height: posterCacheHeight,
                        ),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
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
              child: AppAutoScrollText(
                items.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
            AppAutoScrollText(
              items.originName,
              textAlign: TextAlign.center,
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

typedef _PosterImageProviderBuilder =
    ImageProvider Function(
      String url, {
      required int cacheWidth,
      int? cacheHeight,
    });

class _HomeCarouselItem extends StatelessWidget {
  final ItemEntity movie;
  final int index;
  final int count;
  final double posterWidth;
  final int posterCacheWidth;
  final int posterCacheHeight;
  final ValueListenable<double> currentPageListenable;
  final _PosterImageProviderBuilder imageProviderBuilder;
  final Widget Function() errorBuilder;

  const _HomeCarouselItem({
    required this.movie,
    required this.index,
    required this.count,
    required this.posterWidth,
    required this.posterCacheWidth,
    required this.posterCacheHeight,
    required this.currentPageListenable,
    required this.imageProviderBuilder,
    required this.errorBuilder,
  });

  static const double _posterAspectRatio = 2 / 3;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: currentPageListenable,
      builder: (context, currentPage, child) {
        var diff = index - currentPage;
        diff = diff - count * (diff / count).round();
        diff = diff.clamp(-1.0, 1.0);

        final angle = diff * (math.pi * 0.1);
        return Center(
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: RepaintBoundary(
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
          child: Container(
            width: posterWidth,
            margin: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3.w),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: AspectRatio(
              aspectRatio: _posterAspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image(
                  key: ValueKey('carousel-${movie.slug}-${movie.posterUrl}'),
                  image: imageProviderBuilder(
                    movie.posterUrl,
                    cacheWidth: posterCacheWidth,
                    cacheHeight: posterCacheHeight,
                  ),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => errorBuilder(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerEpisodeTarget {
  final int serverIndex;
  final int episodeIndex;
  final String episodeLink;

  const _PlayerEpisodeTarget({
    required this.serverIndex,
    required this.episodeIndex,
    required this.episodeLink,
  });
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
