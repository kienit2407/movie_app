import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/cached_image.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/feature/home/data/models/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/fetch_fillter_state.dart';

class AllMoviePage extends StatefulWidget {
  const AllMoviePage({super.key, required this.fillterReq});
  final FillterGenreMovieReq fillterReq;

  @override
  State<AllMoviePage> createState() => _AllMoviePageState();
}

class _AllMoviePageState extends State<AllMoviePage> {
  final ScrollController _scrollController = ScrollController();
  List<ItemEntity> allItems =[];
  bool _isLoadingMore = false;
  @override
  void initState() {
    initializeData();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void initializeData() {
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
    final currentScrollPosition = _scrollController.offset;
    if (currentScrollPosition >= maxScroll) {
      _loadMore();
    }
  }

  void _loadMore() {
    context.read<FetchFillterCubit>().loadMore(widget.fillterReq);
    setState(() {
      _isLoadingMore = true;
    });
  }

  void _onRefresh() {
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 52, 196, 163).withOpacity(.3),
                Color.fromARGB(255, 52, 196, 163).withOpacity(.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          style: IconButton.styleFrom(backgroundColor: Colors.white12),
          onPressed: () {
            AppNavigator.pop(context);
          },
          icon: Icon(Iconsax.arrow_left_2_copy, color: Colors.white),
        ),
      ),
      body: BlocConsumer<FetchFillterCubit, FetchFillterState>(
        listener: (context, state) {
          if (state is FetchFillterLoadingMore) {
            _isLoadingMore = true;
          } else {
            _isLoadingMore = false;
          }
          if(state is FetchFillterSuccess) {
            final FillterMovieGenreEntity fillterMovieEntity = state.fillterMovieGenreEntity;
              setState(() {
                allItems.addAll(fillterMovieEntity.items);
              });
          }
        },
        builder: (context, fetchFillterState) {
          
          return _builBody(fetchFillterState);
        },
      ),
    );
  }
  Widget _builBody (FetchFillterState state) {
    return RefreshIndicator.adaptive(
              color: Colors.white,
              onRefresh: () async => _onRefresh(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //title Page
                  // SharderText(
                  //   gradient: LinearGradient(
                  //     colors: [Color(0xff6FB2A3), Colors.white],
                  //     begin: Alignment.centerLeft,
                  //     end: Alignment.centerRight,
                  //   ),
                  //   child: Text(
                  //     state,
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),

                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true, // Luôn hiển thị thanh scroll
                      thickness: 3,
                      radius: Radius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: _buildGrid(allItems),
                      ),
                    ),
                  ),
                ],
              ),
            );
  }
  Widget _buildGrid(List<ItemEntity> itemEntity) {
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        maxCrossAxisExtent:
            150, //chiều rộng tối đa của mỗi item. -> cái này nó sẽ tự tính toán theo màn hình có thể chứa bao nhiêu item -> cross theo chiều ngang đối với các listview có dạng dọc
        // crossAxisSpacing: , gap giữa các item theo chiều ngang
        childAspectRatio: 2 / 3, // tỉ lệ giữa width và height
      ),
      // shrinkWrap: true, // // co lại vừa với content. Nhưng dùng expanded thì item nó sẽ spread out và không cần renđẻ theo shrinkWrap vì nếu 1000 item đi thì nó sẽ bọc và phải render ra 1000 item và tính toán
      itemCount: itemEntity.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 500,
      itemBuilder: (context, index) {
        return SizedBox(
          child: Stack(
            children: [
              CachedImageContainer(
                imageUrl: AppUrl.convertImageAddition(
                  itemEntity[index].posterUrl,
                ),
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
                    itemEntity[index].tmdb.voteAverage.toStringAsFixed(1),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
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
                      content: itemEntity[index].lang.toConvertLang(),
                      isLeft: true,
                    ),
                    _itemChip(
                      content: itemEntity[index].quality,
                      isGadient: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
