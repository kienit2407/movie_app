import 'dart:math' as math;
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:movie_app/app_data.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/fake_api.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/cached_image.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/list_gadient.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_state.dart';
import 'package:movie_app/feature/home/presentation/bloc/latest_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/latest_movie_state.dart';
import 'package:movie_app/feature/home/presentation/widgets/blur_effect.dart';
import 'package:movie_app/feature/home/presentation/widgets/country_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/genre_bottom_sheet.dart';
import 'package:movie_app/feature/home/presentation/widgets/overlay_gadient.dart';
import 'package:movie_app/feature/home/presentation/widgets/polk_effect.dart';

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
  int itemCountStandart = 10;
  double _chipOpacity = 1.0;
  double _chipOffset = 0.0;
  bool isSelectedGenre = false;
  
  @override
  void initState() {
    indexCarouselController = CarouselSliderController();
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
  Widget build(BuildContext context) {
    //Take height size of device
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                Image.asset(AppImage.splashLogo, scale: 1.5),
                Spacer(),
                IconButton.outlined(
                  onPressed: () {},
                  icon: Icon(Iconsax.filter),
                ),
                const SizedBox(width: 15),
                Stack(
                  children: [
                    IconButton.outlined(
                      onPressed: () {},
                      icon: Icon(Iconsax.notification),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        alignment: Alignment.center,
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(fontSize: 6, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
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
                          isSelected: isSelectedGenre
                        ),
                        _buildChipButton(
                          onPressed: () => CountryBottomSheet.show(context),
                          'Quốc gia',
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
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 100),
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildCarouselPoster(screenHeight, screenWidth),
            _movieTheme(),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  gradient: LinearGradient(
                    colors: [Color(0xff282B38), AppColor.bgApp],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _lastedMovie(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lastedMovie() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: List.generate(3, (index) {
          return _itemLatestMovieCountry(
            content: 'Phim Hàn Quốc Mới Nhất',
            gadient: ListGadient.listGadient[index],
          );
        }),
      ),
    );
  }

  Widget _itemLatestMovieCountry({
    required String? content,
    required Gradient gadient,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SharderText(
                gradient: gadient,
                child: Text(
                  'Phim Hàn Quốc mới nhất',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(Iconsax.arrow_right_3_copy),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.of(context).size.height * .3,
          child: AnimationLimiter(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // shrinkWrap: true, // sử dụng cái này thì nó sẽ đo chiều cao của list nếu 100 item thì nó sẽ nặng và lagy -> chậm
              //thay vì dùng nó để tránh lõi khi nhét list view vào colum thì dùng Expanded listview sẽ chiếm hết phần trống flutter chỉ việc render trong viewport
              addAutomaticKeepAlives:true, // từ động giữ state của widget con khi cúng ra khở màn hình và rebuild khong cần thiết
              // addRepaintBoundaries: false, // cái này nó giảm vẽ lại nhưng nêis widget con ít thày đôi khi không cầ sử dụng
              // addSemanticIndexes: true,
              // primary: true,
              separatorBuilder: (context, index) => SizedBox(width: 10),
              itemCount: AppData.posterList.length,
              cacheExtent: 500, //khởng pixel render trước khi thấy viewport
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 800),
                  child: SlideAnimation(
                    verticalOffset: 50,
                    curve: Curves.easeInOut,
                    child: FadeInAnimation(
                      curve: Curves.easeInOut,
                      child: _itemLatestMovie(
                        imgeUrl: AppData.posterList[index],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemLatestMovie({String? imgeUrl}) {
    return SizedBox(
      width: 140,
      height: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  imgeUrl ??
                      'https://static.nutscdn.com/vimg/300-0/d0f979ab72160593e538fcc702b7e749.jp',
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _itemChip(content: 'Tập 20', isLeft: true),
                      _itemChip(content: 'FHD', isGadient: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Bạn Gái Tôi Trở Thành Con Trai Rồi!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'Hiến ngư',
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
    );
  }

  Widget _itemChip({
    required String content,
    bool isGadient = false,
    double? size,
    bool isLeft = false,
  }) {
    return Container(
      // foregroundDecoration: BoxDecoration(), s//-> cái này trang tí trên container
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        //-> cái này thì bên dưới
        color: isGadient ? null : Colors.white,
        borderRadius: isLeft
            ? BorderRadius.only(topLeft: Radius.circular(5))
            : BorderRadius.only(topRight: Radius.circular(5)),
        gradient: isGadient
            ? LinearGradient(
                colors: [Color(0xffFDF9EB), Color(0xffE8CF6F)],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              )
            : null,
      ),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            fontSize: size ?? 10,
            fontWeight: FontWeight.w600,
            color: AppColor.bgApp,
          ),
        ),
      ),
    );
  }

  Widget _movieTheme() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'What are you watching ?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: Icon(Iconsax.arrow_right_3_copy),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: List.generate(6, (index) {
              return _movieThemeItem(
                ListGadient.listGadient[index % ListGadient.listGadient.length],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _movieThemeItem(Gradient gadient) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .12,
      width: 150,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                // lớp nền
                borderRadius: BorderRadius.circular(10),
                gradient: gadient,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 100,
              margin: EdgeInsets.only(left: 10),
              child: Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Marvel',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Watch More',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                      Icon(Iconsax.arrow_right_3_copy, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselPoster(double screenHeight, double screenWidth) {
    return BlocBuilder<LatestMovieCubit, LatestMovieState>(
      builder: (context, data) {
        if (data is LatestMovieLoading) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        if (data is LatestMovieFalure) {
          print(data.message);
        }
        if (data is LatestMovieSuccess) {
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
                _polkEffect(),
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
      top: screenHeight * .20,
      child: Column(
        children: [
          // const SizedBox(height: 20),
          _buildCarousel(screenHeight, latestMovie),
          const SizedBox(height: 10),
          _buildCategory(latestMovie[currentIndex].category),
          const SizedBox(height: 10),
          _buildInforMovie(latestMovie),
          const SizedBox(height: 15),
          _buildDotIndicator(latestMovie),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(Iconsax.play_circle, 'Watch Now'),
                _buildActionButton(Iconsax.info_circle, 'Information'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCategory (List<CategoryEntity> category) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(category.length, (index){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.1),
            borderRadius: BorderRadius.circular(5),
          
          ),
          child: Text(category[index].name,
            style: TextStyle(
              fontSize: 10,

            ),
          ),
        );
      })
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
        const SizedBox(height: 20),
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

  Widget _buildActionButton(IconData icon, String content) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe73827), Color.fromARGB(255, 254, 136, 115)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
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
          onPressed: () {},
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
        gradient: isGadient
            ? LinearGradient(
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
    return Positioned.fill(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              AppUrl.convertImageDirect(latestMovie[currentIndex].posterUrl),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _polkEffect() {
    return PolkBackGround(
      dotColor: AppColor.bgApp.withOpacity(.5),
      dotRadius: .5,
      spacing: 4,
    );
  }

  Widget _buildCarousel(double screenHeight, List<ItemEntity> latestMovie) {
    return ClipRRect(
      child: SizedBox(
        height: screenHeight * 0.36, //chiều cao chứa carousel
        child: CarouselSlider.builder(
          carouselController: indexCarouselController,
          options: CarouselOptions(
            height: screenHeight * 0.35,
            viewportFraction: .65,
            // autoPlayCurve: Curves.easeInOut,
            autoPlay: true,

            initialPage: 0,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
            onScrolled: (value) {
              if (value != null) {
                itemCount = itemCountStandart.toDouble();
                normalize = value % itemCount;
                setState(() {
                  _currentPage = normalize;
                });
              }
            },
          ),
          itemCount: itemCountStandart,
          itemBuilder: (BuildContext context, int index, int realiindex) {
            final double itemCount = itemCountStandart.toDouble();
            double diff = index - _currentPage;
            diff = diff - itemCount * (diff / itemCount).round();
            // Clamp để max angle cho item liền kề (±1)
            diff = diff.clamp(-1.0, 1.0);
            // Angle: - để khớp chiều (bạn có thể đảo nếu sai)
            final double angle = diff * (math.pi * 0.1);
            return GestureDetector(
              onTap: () {
                print(latestMovie[index].slug);
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
        ),
      ),
    );
  }
}

//với ui mà sử dụng được 1 man hình thì không ccanf tach ra thành file
// Padding(
//   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), -> padding cho bàn phím
//   child: ...,
// )
