import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/lost_network.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/common/helpers/static_data.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/cached_image.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AllMoviePage extends StatefulWidget {
  const AllMoviePage({super.key, required this.fillterReq});
  final FillterMovieReq fillterReq;

  @override
  State<AllMoviePage> createState() => _AllMoviePageState();
}

class _AllMoviePageState extends State<AllMoviePage> {
  final ScrollController _scrollController = ScrollController();
  List<ItemEntity> allItems = [];
  Set<String> animatedItems = {};
  String? _titlePage;
  late final PagingController<int, ItemEntity> _pagingController;

  final random = Random();
  late final Map<LinearGradient, Color> _selectedGradient;
  // Timer? _debounceTimer;
  @override
  void initState() {
    super.initState(); // phải để lên đầu vì cái nào sau nó sẽ đươc build trước
    
    _selectedGradient =
        StaticData.randomeGadientTitlePage[random.nextInt(
          StaticData.randomeGadientTitlePage.length,
        )];

    // tiến hành call api
    _pagingController = PagingController(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) async {
        final response = await context.read<FetchFillterCubit>().fetchApi(
          widget.fillterReq,
          pageKey,
        );
        return response.items;
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColor = _selectedGradient.keys.single;
    final appBarColor = _selectedGradient.values.single;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: appBarColor.withOpacity(.7),
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              // flexibleSpace: Container(
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [
              //         Color.fromARGB(255, 52, 196, 163).withOpacity(.3),
              //         Color.fromARGB(255, 52, 196, 163).withOpacity(.3),
              //       ],
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //     ),
              //   ),
              // ),
              leading: IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white12),
                onPressed: () {
                  AppNavigator.pop(context);
                },
                icon: Icon(Iconsax.arrow_left_2_copy, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: gradientColor),
          ),
          _builContent(),
        ],
      ),
    );
  }

  Widget _builContent() {
    return RefreshIndicator.adaptive(
      color: Colors.white,
      onRefresh: () async => {},
      child: Scrollbar(
        controller: _scrollController,
        interactive: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomScrollView(
            cacheExtent: 1500.0,
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: const SizedBox(height: kToolbarHeight + 80),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<FetchFillterCubit, FetchFillterState>(
                  builder: (context, state) {
                    if (state is FetchFillterSuccess) {
                      return ZoomIn(
                        duration: Duration(milliseconds: 200),
                        child: SharderText(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xff1C1C1C),
                              Color(0xff1C1C1C),
                              Color(0xff1C1C1C),
                              Color(0xff727387),
                              Color(0xff1C1C1C),
                            ],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          child: Text(
                            state.titlePage,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 10)),
              PagingListener(
                controller: _pagingController,
                builder: (context, state, fetchNextPage) {
                  return MultiSliver(
                    children: [
                      PagedSliverGrid<int, ItemEntity>(
                        addAutomaticKeepAlives: true,
                        state: state,
                        fetchNextPage: fetchNextPage,
                        builderDelegate: PagedChildBuilderDelegate(
                          newPageProgressIndicatorBuilder: (context) =>
                              SizedBox(),
                          noMoreItemsIndicatorBuilder: (context) =>
                              LostNetworkPage(),
                          firstPageProgressIndicatorBuilder: (context) =>
                              Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                          itemBuilder: (context, item, index) {
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
                          },
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              maxCrossAxisExtent: 200,
                              childAspectRatio: 2 / 3.4,
                            ),
                      ),

                      if (state.hasNextPage == true)
                        SliverToBoxAdapter(child: _buildIndicator()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300),
      height: 60, // Chiều cao nhỏ cho indicator
      padding: const EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator.adaptive(), Text('Loading')],
      ),
    );
  }

  Widget _buildItem(ItemEntity itemEntity) {
    return GestureDetector(
      onTap: () {
        showAnimatedDialog(
          context: context, 
          dialog: ShowDetailMovieDialog(
            slug: itemEntity.slug
          )
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
                        color: AppColor.secondColor,
                        borderRadius: BorderRadius.circular(8),
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
                    right: 0,
                    bottom: 2,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _itemChip(
                          content: itemEntity.lang.toConvertLang(),
                          isLeft: true,
                        ),
                        _itemChip(content: itemEntity.quality, isGadient: true),
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
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            Text(
              itemEntity.originName,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 10, color: Colors.grey),
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
          ),
        ),
      ),
    );
  }
}
