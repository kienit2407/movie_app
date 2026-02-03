import 'dart:math' as math;
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_state.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movie_app/common/components/lost_network.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/core/config/utils/package_infor.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/common/helpers/sort_map.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_state.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/feature/detail_movie/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/cached_image.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/list_gadient.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/usecase/get_movies_by_filter_usecase.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_state.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/home/presentation/widgets/blur_effect.dart';
import 'package:movie_app/feature/home/presentation/widgets/comprehensive_filter_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/country_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/genre_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/home_skeleton.dart';
import 'package:movie_app/feature/home/presentation/widgets/overlay_gadient.dart';
import 'package:movie_app/feature/home/presentation/widgets/polk_effect.dart';
import 'package:movie_app/feature/home/presentation/widgets/recommend_movie_widget.dart';
import 'package:movie_app/feature/home/presentation/widgets/year_bottom_sheet.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';
import 'package:movie_app/feature/search/presentation/pages/search_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late CarouselSliderController
  indexCarouselController; //do carousel là một control cần dữ liệu và context nên nó phải được tạo sau khi widget được mounted, nó cần dữ liệu từ api nên cần trước. Chính vì cần trước nên nó phải được khởi tạo sau. Nhằm đảm bảo nó không bị lỗi]
  int currentIndex = 0;
  double _currentPage = 0.0;
  double itemCount = 0;
  double normalize = 0;
  final ScrollController _scrollController = ScrollController();
  int itemCountStandart = 20;
  double _chipOpacity = 1.0;
  double _chipOffset = 0.0;
  bool isSelectedGenre = false;
  bool _isLoading = false;
  String? selectedValue;
  final ValueNotifier<double> _currentPageNotifier = ValueNotifier<double>(0.0);
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';
  @override
  void initState() {
    _loadPackageInfo();
    indexCarouselController = CarouselSliderController();
    // _currentPageNotifier = ValueNotifier<double>(0.0);
    super.initState();

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
    _currentPageNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfor.getPackageInfo();
    if (mounted) {
      setState(() {
        appName = packageInfo.appName;
        packageName = packageInfo.packageName;
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Take height size of device
    // final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
        toolbarHeight: 90,
        foregroundColor: Colors.white,
        title: Column(
          spacing: 10,
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
                const SizedBox(width: 15),
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
                // Positioned(
                //   top: 14,
                //   right: 14,
                //   child: Container(
                //     alignment: Alignment.center,
                //     width: 10,
                //     height: 10,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.red,
                //     ),
                //     child: Text(
                //       '1',
                //       style: TextStyle(fontSize: 6, color: Colors.white),
                //     ),
                //   ),
                // ),
              ],
            ),
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  opacity: _chipOpacity,
                  child: Transform.translate(
                    offset: Offset(0, -_chipOffset),
                    child: Row(
                      spacing: 10,
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
                          isSelected: isSelectedGenre,
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
          context.read<CarouselDisplayCubit>().getLatestMovie();
        },
        child: BlocBuilder<CarouselDisplayCubit, CarouselDisplayState>(
          builder: (context, state) {
            if (state is CarouselLoading) {
              return Center(child: HomeSkeleton());
            } else if (state is CarouselFalure) {
              return Center(child: const LostNetworkPage());
            } else if (state is CarouselSuccess) {
              return _buildContent(); // Hiển thị dữ liệu khi đã tải xong
            } else {
              return Center(child: Text("Không có dữ liệu"));
            }
          },
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
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 100),
          physics: ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildCarouselPoster(screenHeight, screenWidth),
              const SizedBox(height: 10),
              MovieSectionWithScroll(),
              const SizedBox(height: 30),
              _lastedMovie(),
              const SizedBox(height: 30),
              _buildVersionInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lastedMovie() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        // padding: const EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
            SizedBox(height: 20),
            CountryMovieSection(
              title: "Phim Trung Quốc",
              gradient: LinearGradient(
                colors: [Color(0xffA088BD), Color.fromARGB(255, 216, 213, 220)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              countrySlug: 'trung-quoc',
            ),
            SizedBox(height: 20),
            CountryMovieSection(
              title: "Phim Mỹ - UK",
              gradient: LinearGradient(
                colors: [Color(0xffEAC66B), Color.fromARGB(255, 210, 204, 191)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              countrySlug: 'au-my',
            ),
          ],
        ),
      ),
    );
  }

  // Widget _itemLatestMovie({required ItemEntity items}) {
  //   return GestureDetector(
  //     onTap: () {
  //       AppNavigator.push(context, MovieDetailPage(slug: items[index].slug));
  //     },
  //     onLongPress: () {
  //       HapticFeedback.mediumImpact();
  //       showAnimatedDialog(
  //         context: context,
  //         dialog: ShowDetailMovieDialog(slug: items.slug),
  //       );
  //     },
  //     child: SizedBox(
  //       width: 140,
  //       height: 260,
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Container(
  //             height: 200,
  //             decoration: BoxDecoration(
  //               image: DecorationImage(
  //                 image: CachedNetworkImageProvider(
  //                   AppUrl.convertImageAddition(items.posterUrl),
  //                 ),
  //                 fit: BoxFit.cover,
  //               ),
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(color: Colors.white, width: 2),
  //             ),
  //             child: Stack(
  //               children: [
  //                 // Rating badge
  //                 Positioned(
  //                   top: 5,
  //                   left: 5,
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 6,
  //                       vertical: 3,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: AppColor.secondColor,
  //                       borderRadius: BorderRadius.circular(6),
  //                     ),
  //                     child: Text(
  //                       items.tmdb.voteAverage.toStringAsFixed(1),
  //                       style: const TextStyle(
  //                         fontSize: 10,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   right: 0,
  //                   bottom: 0,
  //                   left: 0,
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       _itemChip(
  //                         content: items.lang.toConvertLang(),
  //                         isLeft: true,
  //                       ),
  //                       _itemChip(content: items.quality, isGadient: true),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           SizedBox(height: 10),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 10),
  //             child: Text(
  //               items.name,
  //               maxLines: 1,
  //               overflow: TextOverflow.ellipsis,
  //               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  //             ),
  //           ),
  //           Text(
  //             items.originName,
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             style: TextStyle(
  //               fontSize: 10,
  //               fontWeight: FontWeight.w400,
  //               color: Colors.grey,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _itemChip({
  //   required String content,
  //   bool isGadient = false,
  //   double? size,
  //   bool isLeft = false,
  // }) {
  //   return Container(
  //     // foregroundDecoration: BoxDecoration(), s//-> cái này trang tí trên container
  //     padding: EdgeInsets.all(5),
  //     decoration: BoxDecoration(
  //       //-> cái này thì bên dưới
  //       color: isGadient ? null : Colors.white,
  //       borderRadius: isLeft
  //           ? BorderRadius.only(topLeft: Radius.circular(5))
  //           : BorderRadius.only(topRight: Radius.circular(5)),
  //       gradient: isGadient
  //           ? LinearGradient(
  //               colors: [Color(0xffFDF9EB), Color(0xffE8CF6F)],
  //               begin: Alignment.bottomLeft,
  //               end: Alignment.topRight,
  //             )
  //           : null,
  //     ),
  //     child: Center(
  //       child: Text(
  //         content,
  //         style: TextStyle(
  //           fontSize: size ?? 10,
  //           fontWeight: FontWeight.w600,
  //           color: AppColor.bgApp,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCarouselPoster(double screenHeight, double screenWidth) {
    return BlocConsumer<CarouselDisplayCubit, CarouselDisplayState>(
      listener: (context, state) {
        if (state is CarouselSuccess) {
          setState(() {
            currentIndex = 0;
          });
          _currentPageNotifier.value = 0.0;
          indexCarouselController.jumpToPage(0);
        }
      },
      builder: (context, data) {
        if (data is CarouselSuccess) {
          return SizedBox(
            height: screenHeight * .89,
            width: screenWidth,
            child: Stack(
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
                _buildInforSection(screenHeight, data.latestMovie),
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

  Widget _buildInforSection(double screenHeight, List<ItemEntity> latestMovie) {
    return Positioned(
      right: 0,
      left: 0,
      bottom: 0,
      top: screenHeight * .185,
      child: Column(
        children: [
          // const SizedBox(height: 20),
          _buildCarousel(screenHeight, latestMovie),
          const SizedBox(height: 8),
          _buildCategory(latestMovie[currentIndex].category),
          const SizedBox(height: 20),
          _buildInforMovie(latestMovie),
          const SizedBox(height: 15),
          _buildDotIndicator(latestMovie),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Iconsax.play_circle, 'Xem Phim', () async {
                  await _navigateToPlayer(latestMovie[currentIndex].slug);
                }),
                _buildActionButton(Iconsax.info_circle, 'Thông Tin', () {
                  // HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MovieDetailPage(slug: latestMovie[currentIndex].slug),
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
      height: MediaQuery.of(context).size.height * .04,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 90),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 5,
          children: List.generate(category.length, (index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(category[index].name, style: TextStyle(fontSize: 9)),
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
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            latestMovie[currentIndex].name,
            textAlign: TextAlign.justify,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            textAlign: TextAlign.justify,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            latestMovie[currentIndex].originName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xfff85032),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            spacing: 10,
            children: [
              Wrap(
                direction: Axis.horizontal,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  _buildInforChip(
                    borderColor: Color(0xfff85032),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5,
                      children: [
                        const Text(
                          'iMdB',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xfff85032),
                          ),
                        ),
                        Text(
                          latestMovie[currentIndex].tmdb.voteAverage
                              .toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
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
                      latestMovie[currentIndex].quality,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildInforChip(
                    child: Text(
                      latestMovie[currentIndex].year.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildInforChip(
                    child: Text(
                      (latestMovie[currentIndex].episodeCurrent == 'Full')
                          ? latestMovie[currentIndex].time.toFormatEpisode()
                          : latestMovie[currentIndex].time,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildInforChip(
                    backgroundColor: Colors.white,
                    child: Text(
                      latestMovie[currentIndex].episodeCurrent,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // if (latestMovie[currentIndex].chieurap == false)
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
                  if (latestMovie[currentIndex].subDocquyen == true)
                    _buildInforChip(
                      isGadient: true,
                      borderColor: Colors.transparent,
                      child: const Text(
                        'Sub Độc Quyền',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  _buildInforChip(
                    child: Text(
                      latestMovie[currentIndex].lang,
                      style: TextStyle(
                        fontSize: 10,
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
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white),
        color: isSelected ? Colors.white : Colors.transparent,
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 8),
          // foregroundColor: isSelected ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: showIcon ? 5 : 0,
          children: [
            Text(
              content,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
            showIcon
                ? Icon(
                    icon,
                    size: 15,
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
        MaterialPageRoute(
          builder: (context) => MoviePlayerPage(
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
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            maximumSize: Size.fromWidth(200),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
          onPressed: () {
            onTap();
            HapticFeedback.mediumImpact();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Icon(icon, size: 25),
              Text(
                content,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator(List<ItemEntity> latestMovie) {
    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 30),
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(itemCountStandart, (index) {
            bool isSelected = currentIndex == index;
            return GestureDetector(
              onTap: () {
                // indexCarouselController.animateToPage(index);
                indexCarouselController.jumpToPage(index);
              },
              child: AnimatedContainer(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 300),
                width: isSelected ? 30 : 25,
                height: isSelected ? 30 : 25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      AppUrl.convertImageDirect(latestMovie[index].posterUrl),
                    ),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
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
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? Colors.white),
        borderRadius: BorderRadius.circular(7),
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
    final url = AppUrl.convertImageDirect(latestMovie[currentIndex].posterUrl);
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: CachedNetworkImage(
          key: ValueKey(url),
          imageUrl: url,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 200),
          placeholder: (_, __) => const SizedBox(), // hoặc blur/gradient
          errorWidget: (_, __, ___) => const SizedBox(),
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

  Widget _buildCarousel(double screenHeight, List<ItemEntity> latestMovie) {
    final count = math.min(latestMovie.length, 20);
    if (count == 0) return const SizedBox.shrink();

    final carouselKey = latestMovie.take(count).map((e) => e.slug).join('|');

    return ClipRRect(
      child: SizedBox(
        height: screenHeight * 0.36, //chiều cao chứa carousel
        child: CarouselSlider.builder(
          key: ValueKey(carouselKey), // ✅ data đổi => carousel reset sạch
          carouselController: indexCarouselController,
          options: CarouselOptions(
            // autoPlayCurve: Curves.bounceInOut,
            height: screenHeight * 0.35,
            viewportFraction: .65,
            // autoPlayCurve: Curves.easeInOut,
            autoPlay: true,
            animateToClosest: true,

            initialPage: 0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
            onScrolled: (value) {
              if (value == null) return;
              final double count = itemCountStandart.toDouble();
              final double normalize = value % count;

              // không setState
              _currentPageNotifier.value = normalize;
            },
          ),
          itemCount: itemCountStandart,
          itemBuilder: (BuildContext context, int index, int realiindex) {
            // final double itemCount = itemCountStandart.toDouble();
            // double diff = index - _currentPage;
            // diff = diff - itemCount * (diff / itemCount).round();
            // // Clamp để max angle cho item liền kề (±1)
            // diff = diff.clamp(-1.0, 1.0);
            // // Angle: - để khớp chiều (bạn có thể đảo nếu sai)
            // final double angle = diff * (math.pi * 0.1);
            return ValueListenableBuilder(
              valueListenable: _currentPageNotifier,
              builder: (context, currentPage, child) {
                final double itemCount = itemCountStandart.toDouble();

                double diff = index - currentPage;
                diff = diff - itemCount * (diff / itemCount).round();
                diff = diff.clamp(-1.0, 1.0);

                final double angle = diff * (math.pi * 0.1);
                return GestureDetector(
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
                  child: Center(
                    child: Transform.rotate(
                      angle: angle,
                      child: CachedImageContainer(
                        imageUrl: AppUrl.convertImageDirect(
                          latestMovie[index].posterUrl,
                        ),
                        boxFit: BoxFit.cover,
                        margin: EdgeInsets.symmetric(horizontal: 27),
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
  Widget _buildVersionInfo() {
    if (version.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Text(
            'Version: $version ($buildNumber)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            '$appName - $packageName',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

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

          return Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: SharderText(
                      gradient: widget.gradient,
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 20,
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
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        'Xem tất cả',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
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
              const SizedBox(height: 10),
              if (itemsList.isEmpty)
                const _CountrySkeletonList()
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height * .3,
                  child: AnimationLimiter(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(left: 15),
                      scrollDirection: Axis.horizontal,
                      addAutomaticKeepAlives: true,
                      separatorBuilder: (context, index) => SizedBox(width: 10),
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
        width: 140,
        height: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
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
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          items.tmdb.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      // right: 0,
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
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                items.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              items.originName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
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

// class _ItemChip extends StatelessWidget {
//   final String content;
//   final bool isGadient;
//   final double? size;
//   final bool isLeft;

//   const _ItemChip({
//     required this.content,
//     this.isGadient = false,
//     this.size,
//     this.isLeft = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: isGadient ? null : Colors.white,
//         borderRadius: isLeft
//             ? BorderRadius.only(topLeft: Radius.circular(5))
//             : BorderRadius.only(topRight: Radius.circular(5)),
//         gradient: isGadient
//             ? LinearGradient(
//                 colors: [Color(0xffe73827), Color.fromARGB(255, 254, 136, 115)],
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//               )
//             : null,
//       ),
//       child: Center(
//         child: Text(
//           content,
//           style: TextStyle(
//             fontSize: size ?? 10,
//             fontWeight: FontWeight.w600,
//             color: AppColor.bgApp,
//           ),
//         ),
//       ),
//     );
//   }
// }

class _CountrySkeletonList extends StatelessWidget {
  const _CountrySkeletonList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .3,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: 5,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 100,
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
            ),
          );
        },
      ),
    );
  }
}
