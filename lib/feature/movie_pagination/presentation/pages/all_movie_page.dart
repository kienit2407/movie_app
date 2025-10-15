import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
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
  final random = Random();
  late final Map<LinearGradient, Color> _selectedGradient;
  // Timer? _debounceTimer;
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState(); // phải để lên đầu vì cái nào sau nó sẽ đươc build trước
    _selectedGradient = StaticData.randomeGadientTitlePage[
      random.nextInt(StaticData.randomeGadientTitlePage.length)];
    allItems.clear();
    initializeData();
    _scrollController.addListener(_onScroll);
  }

  void initializeData() {
    if (_isLoadingMore) return;
    context.read<FetchFillterCubit>().fetchFillterGenre(
      widget.fillterReq,
    ); // -> khởi tạo dữ liệu
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    // nếu đang loading và hết data thì band now không cho passs -> nếu k có cái này thì nó sẽ gọi call api liên tục vì theo listener scroll của user và nếu user kéo quá nhanh
    final maxScroll = _scrollController
        .position
        .maxScrollExtent; // CÁCH TÍNH CỦA SCROLL NÀY VÍ DỤ: 100 tiem và cao 150 thì maxitem
    final currentScrollPosition = _scrollController.position.pixels;
    if (currentScrollPosition >= maxScroll && !_isLoadingMore) {
      // // Debounce để chỉ gọi _loadMore sau 300ms
      // _debounceTimer?.cancel();
      // _debounceTimer = Timer(Duration(milliseconds: 30), () {
      //   _loadMore();
      // });
      _loadMore();
    }
  }
  
  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    context.read<FetchFillterCubit>().loadApi(widget.fillterReq);
  }

  void _onRefresh() {
    setState(() {
      _isLoadingMore = false;
      allItems.clear();
    });
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColor = _selectedGradient.keys.single;
    final appBarColor = _selectedGradient.values.single;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60) ,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX:20,
              sigmaY: 20
            ),
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
            decoration: BoxDecoration(
              gradient:gradientColor
            ),
          ),
          BlocConsumer<FetchFillterCubit, FetchFillterState>(
            listener: (context, state) {
              if (state is FetchFillterLoadingMore) {
                _isLoadingMore = true;
              } else {
                _isLoadingMore = false;
              }
              if (state is FetchFillterSuccess) {
                final FillterMovieGenreEntity fillterMovieEntity =
                    state.fillterMovieGenreEntity;
                allItems.addAll(fillterMovieEntity.items);
              }
            },
            builder: (context, builderState) {
              if(builderState is FetchFillterSuccess) {
                return _builContent(builderState);
              }
              return SizedBox();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _builContent(FetchFillterSuccess state) {
    return RefreshIndicator.adaptive(
      color: Colors.white,
      onRefresh: () async => _onRefresh(),
      child: Scrollbar(
        controller: _scrollController,
        interactive: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomScrollView(
            
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: const SizedBox(height: kToolbarHeight + 80,),
              ),
              SliverToBoxAdapter(
                child: ZoomIn(
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
                      
                      begin:Alignment.centerRight,
                      end: Alignment.centerLeft
                    ),
                    child: Text(state.fillterMovieGenreEntity.titlePage,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                )
              ),
              SliverToBoxAdapter(
                child: const SizedBox(height: 10,),
              ),
              _buildGrid(allItems), //có nên để danh sách ở local không
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 300),
                  height: _isLoadingMore ? 80 : 0, // Chiều cao nhỏ cho indicator
                  padding: const EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(bottom: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoadingMore
                          ? CircularProgressIndicator.adaptive()
                          : SizedBox(),
                      Text('Loading'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<ItemEntity> itemEntity) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,

        maxCrossAxisExtent:
            200, //chiều rộng tối đa của mỗi item. -> cái này nó sẽ tự tính toán theo màn hình có thể chứa bao nhiêu item -> cross theo chiều ngang đối với các listview có dạng dọc
        // crossAxisSpacing: , gap giữa các item theo chiều ngang
        childAspectRatio: 2 / 3.4, // tỉ lệ giữa width và height
      ),
      // shrinkWrap: true, // // co lại vừa với content. Nhưng dùng expanded thì item nó sẽ spread out và không cần renđẻ theo shrinkWrap vì nếu 1000 item đi thì nó sẽ bọc và phải render ra 1000 item và tính toán
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = itemEntity[index];
          final shouldAnimate = !animatedItems.contains(item.id);
          if (shouldAnimate) {
            animatedItems.add(item.id); // Đánh dấu đã animate
          }
          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 3,
            duration: const Duration(milliseconds: 400),
            child: shouldAnimate
                ? ScaleAnimation(
                    curve: Curves.easeOut,
                    child: SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(child: _buildItem(item)),
                    ),
                  )
                : _buildItem(item),
          );
        },

        addRepaintBoundaries: true,
        childCount: itemEntity.length,
      ),
    );
  }

  Widget _buildItem(ItemEntity itemEntity) {
    BuildContext? dialogContext;
    return GestureDetector(
      key: ValueKey(itemEntity.id),
      onLongPressStart: (details) async {
        dialogContext = await showAnimatedDialog(
          context: context,
          dialog: ShowDetailMovieDialog(slug: itemEntity.slug),
        );
      },

      onLongPressEnd: (details) {
        Navigator.of(dialogContext!).pop(); // Đóng dialog
      },
      child: SizedBox(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: [
                  CachedImageContainer(
                    imageUrl: AppUrl.convertImageAddition(itemEntity.posterUrl),
                    boxFit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
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
