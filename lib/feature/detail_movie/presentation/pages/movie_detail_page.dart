import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/blocking_back_page.dart';
import 'package:movie_app/core/config/utils/cover_map.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_state.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:movie_app/common/helpers/watch_progress_storage.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/usecase/get_movies_by_filter_usecase.dart';
import 'package:movie_app/feature/home/presentation/widgets/polk_effect.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Key? key;
  final GlobalKey _tabBarMarkerKey = GlobalKey();
  _SliverTabBarDelegate(this._tabBar, {this.key});

  @override
  double get minExtent => _tabBar.preferredSize.height + 6; // +6 padding
  @override
  double get maxExtent => _tabBar.preferredSize.height + 6;
  // static const double _tabBarPinnedHeight =
  //     kTextTabBarHeight + 6; // 48 + 6 = 54
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff272A39), Color(0xff191A24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.12))),
      ),
      padding: const EdgeInsets.only(left: 16),
      alignment: Alignment.centerLeft,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return true;
  }
}

class _CastSliver extends StatelessWidget {
  final List<String> actors;
  const _CastSliver({required this.actors});

  @override
  Widget build(BuildContext context) {
    if (actors.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Không có thông tin diễn viên',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final actorName = actors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white10,
                child: const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  actorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Text(
                'Diễn viên',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }, childCount: actors.length),
    );
  }
}

class _RecommendationsSliver extends StatefulWidget {
  const _RecommendationsSliver();

  @override
  State<_RecommendationsSliver> createState() => _RecommendationsSliverState();
}

class _RecommendationsSliverState extends State<_RecommendationsSliver> {
  int _firstBatchCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchFillterCubit>().stream.listen((state) {
        if (state is FetchFillterLoaded && _firstBatchCount == 0) {
          if (mounted) {
            setState(() {
              _firstBatchCount = state.items.length;
            });
          }
        }
      });
    });
  }

  Widget _buildIndicator() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      height: 30,
      width: double.infinity,
      // padding: const EdgeInsets.all(8.0),
      // margin: const EdgeInsets.only(bottom: 100, top: 100),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(width: 8),
          Text('Loading'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFillterCubit, FetchFillterState>(
      builder: (context, state) {
        if (state is FetchFillterLoading) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              maxCrossAxisExtent: 150,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return Shimmer.fromColors(
                baseColor: const Color(0xff272A39).withOpacity(.2),
                highlightColor: const Color(0xff191A24).withOpacity(.2),
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
            }, childCount: 9),
          );
        }
        if (state is FetchFillterFailure) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Không thể tải đề xuất',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          );
        }
        if (state is FetchFillterLoaded) {
          final movies = state.items;
          if (movies.isEmpty) {
            return const SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Không có đề xuất',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            );
          }

          return MultiSliver(
            children: [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = movies[index];

                  if (index < _firstBatchCount) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      columnCount: 3,
                      child: ScaleAnimation(
                        curve: Curves.easeOut,
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: _RecommendationItem(itemEntity: item),
                          ),
                        ),
                      ),
                    );
                  }

                  return _RecommendationItem(itemEntity: item);
                }, childCount: movies.length),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _EpisodesSliver extends StatefulWidget {
  final List<EpisodesModel> episodes;
  final MovieModel movie;
  final String movieType;
  final Function(int episodeIndex, String episodeLink)? onEpisodeSelected;

  const _EpisodesSliver({
    required this.episodes,
    required this.movieType,
    this.onEpisodeSelected,
    required this.movie,
  });

  @override
  State<_EpisodesSliver> createState() => _EpisodesSliverState();
}

class _EpisodesSliverState extends State<_EpisodesSliver> {
  String? _selectedServer;
  final TextEditingController _searchController = TextEditingController();
  int _selectedServerIndex = 0;

  EpisodesModel get _currentServerModel =>
      widget.episodes[_selectedServerIndex];
  List<ServerData> get _currentServerData => _currentServerModel.server_data;
  // int _playingEpisodeIndex = -1;

  @override
  void initState() {
    super.initState();
    if (widget.episodes.isNotEmpty) {
      _selectedServerIndex = 0;
      _selectedServer = widget.episodes.first.server_name;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _findEpisodeIndexByNumber(List<ServerData> list, int targetEp) {
    for (int i = 0; i < list.length; i++) {
      final raw = list[i].name; // ví dụ: "Tập 123" hoặc "123"
      final match = RegExp(r'\d+').firstMatch(raw);
      final num = int.tryParse(match?.group(0) ?? '');
      if (num == targetEp) return i;
    }
    return -1;
  }

  void _submitEpisode() {
    final epNum = int.tryParse(_searchController.text.trim());
    if (epNum == null) return;

    final dataList = _currentServerData;
    final episodeIndex = _findEpisodeIndexByNumber(dataList, epNum);

    if (episodeIndex == -1) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(
          title: 'Chú ý',
          content: 'Không tìm thấy tập $epNum trên server hiện tại.',
          buttonTitle: 'Đóng',
        ),
      );
      return;
    }

    final episodeData = dataList[episodeIndex];
    final link = episodeData.link_m3u8.isNotEmpty
        ? episodeData.link_m3u8
        : episodeData.link_embed;

    widget.onEpisodeSelected?.call(episodeIndex, link);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoviePlayerPage(
          movie: widget.movie,
          episodes: widget.episodes,
          movieName: widget.movie.name,
          slug: widget.movie.slug,
          initialEpisodeIndex: episodeIndex,
          initialServer: _currentServerModel.server_name, //  server đang chọn
          thumbnailUrl: widget.movie.thumb_url,
          initialEpisodeLink: link,
          initialServerIndex: _selectedServerIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.episodes.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Chưa có tập phim nào',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      );
    }

    final isSingle = widget.movieType == 'single';
    
    final isFullMovie = widget.movie.episode_current == 'Full';

    final itemsToShow = isSingle ? widget.episodes : _currentServerData;

    return isFullMovie
        ? _buildFullMovieServersSliver() // UI full
        : _buildSeriesEpisodesSliver(itemsToShow, isSingle); // UI series
  }

  MultiSliver _buildFullMovieServersSliver() {
    return MultiSliver(
      children: [
        SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final ep = widget.episodes[index];
            final serverName = CoverMap.getConfigFromServerName(ep.server_name);

            return Material(
              color: Colors.transparent,
              elevation: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (widget.onEpisodeSelected == null) return;
                  if (ep.server_data.isEmpty) return;

                  // Full thường chọn link từ phần tử đầu tiên của server_data
                  final data = ep.server_data.first;
                  final link = data.link_m3u8.isNotEmpty
                      ? data.link_m3u8
                      : data.link_embed;
                  widget.onEpisodeSelected!(index, link);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return MoviePlayerPage(
                          movie: widget.movie,
                          episodes: widget.episodes,
                          movieName: widget.movie.name,
                          slug: widget.movie.slug,
                          initialEpisodeIndex: index,
                          initialServer: ep.server_name,
                          thumbnailUrl: widget.movie.thumb_url,
                          initialEpisodeLink: link,
                          initialServerIndex: index,
                        );
                      },
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10),
                          ),
                          child: FastCachedImage(
                            url: AppUrl.convertImageDirect(
                              widget.movie.poster_url,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                serverName['color'],
                                serverName['color'].withValues(alpha: 0.98),
                                serverName['color'].withValues(alpha: 0.0),
                              ],
                              stops: const [0.0, 0.60, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    serverName['icon'],
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    serverName['title'],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.movie.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Xem bản này',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }, childCount: widget.episodes.length),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 16 / 9,
          ),
        ),

        // thêm chút “dư” để scroll được (nếu bạn muốn)
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  MultiSliver _buildSeriesEpisodesSliver(
    List<dynamic> itemsToShow,
    bool isSingle,
  ) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            height: 50,
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [Color(0xff272A39), Color(0xff191A24)],
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              // ),
              // border: Border(
              //   top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              // ),
            ),
            child: ListView.separated(
              // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              scrollDirection: Axis.horizontal,
              itemCount: widget.episodes.length,
              itemBuilder: (context, index) {
                // Lấy thông tin server từ Map của bạn
                final serverInfo = CoverMap.getConfigFromServerName(
                  widget.episodes[index].server_name,
                );

                // Kiểm tra xem Server này có đang được chọn ĐỂ HIỂN THỊ TẬP PHIM không
                // final isSelected = _selectedServerIndex == index;
                final isSelected = _selectedServerIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedServerIndex = index;
                      _selectedServer = widget.episodes[index].server_name;
                      _searchController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      // Nếu chọn thì sáng màu, không thì mờ
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        serverInfo['title'],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: const Color(0xff1A1A22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    isSingle ? 'Server' : ' Tập 1 - ${itemsToShow.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      textAlignVertical: TextAlignVertical.center,
                      onSubmitted: (_) => _submitEpisode(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.0,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Nhập tập',
                        hintStyle: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          height: 1.0,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 6, right: 6),
                          child: Icon(
                            Iconsax.search_normal_1_copy,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 32,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // grid tập như bạn đang làm
        SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = itemsToShow[index];

            final label = isSingle
                ? (item as EpisodesModel).server_name
                : (item as ServerData).name;

            return GestureDetector(
              onTap: () {
                final selectedModel = _currentServerModel; // server đang chọn theo _selectedServerIndex
                if (selectedModel.server_data.isEmpty) return;

                final episodeData = selectedModel.server_data[index];
                final link = episodeData.link_m3u8.isNotEmpty
                    ? episodeData.link_m3u8
                    : episodeData.link_embed;

                // update UI bên detail (nếu bạn muốn highlight / lưu lại)
                widget.onEpisodeSelected?.call(index, link);

                // mở player luôn -> đúng nghĩa "chuyển tập"
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MoviePlayerPage(
                      movie: widget.movie,
                      episodes: widget.episodes,
                      movieName: widget.movie.name,
                      slug: widget.movie.slug,
                      initialEpisodeIndex: index,
                      initialServer: selectedModel.server_name,
                      initialServerIndex: _selectedServerIndex,
                      thumbnailUrl: widget.movie.thumb_url,
                      initialEpisodeLink: link,
                    ),
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xff272A39),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }, childCount: itemsToShow.length),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isSingle ? 2 : 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: isSingle ? 3.5 : 2.0,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final ItemEntity itemEntity;
  const _RecommendationItem({required this.itemEntity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigator.push(context, MovieDetailPage(slug: itemEntity.slug));
      },
      onLongPress: () {
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FastCachedImage(
                        url: itemEntity.posterUrl.startsWith('http')
                            ? itemEntity.posterUrl
                            : AppUrl.convertImageAddition(itemEntity.posterUrl),
                        fit: BoxFit.cover,
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
                        color: AppColor.secondColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        itemEntity.tmdb.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
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
                        _buildItemChip(
                          content: itemEntity.lang.toConvertLang(),
                          isLeft: true,
                        ),
                        _buildItemChip(
                          content: itemEntity.quality,
                          isGadient: true,
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
}

Widget _buildItemChip({
  required String content,
  bool isGadient = false,
  double? size,
  bool isLeft = false,
}) {
  return Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: isGadient ? null : Colors.white,
      borderRadius: isLeft
          ? const BorderRadius.only(topLeft: Radius.circular(5))
          : const BorderRadius.only(topRight: Radius.circular(5)),
      gradient: isGadient
          ? const LinearGradient(
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
          decoration: TextDecoration.none,
        ),
      ),
    ),
  );
}

class MovieDetailPage extends StatelessWidget {
  final String slug;
  final DetailMovieModel? initialDetail;
  final Duration? startAt;

  const MovieDetailPage({
    super.key,
    required this.slug,
    this.initialDetail,
    this.startAt,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = DetailMovieCubit(sl<GetDetailMovieUsecase>());
            if (initialDetail != null) {
              cubit.setDetailMovie(initialDetail!);
            } else {
              cubit.getDetailMovie(slug);
            }
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => FetchFillterCubit(
            getMoviesByFilterUsecase: sl<GetMoviesByFilterUsecase>(),
          ),
        ),
      ],
      child: _MovieDetailPageContent(startAt: startAt),
    );
  }
}

class _MovieDetailPageContent extends StatefulWidget {
  final Duration? startAt;
  const _MovieDetailPageContent({this.startAt});

  @override
  State<_MovieDetailPageContent> createState() =>
      _MovieDetailPageContentState();
}

class _MovieDetailPageContentState extends State<_MovieDetailPageContent>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _youtubeController;
  late final TabController _tabController;
  bool _isPlayerError = false;
  bool _isPlayerReady = false;
  bool _isMuted = false;
  bool _isDescriptionExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _tabBarKey = GlobalKey();
  final GlobalKey _beforeTabBarKey = GlobalKey();
  final GlobalKey _tabBarMarkerKey = GlobalKey();
  int _currentEpisodeIndex = 0;
  String _currentServer = '';
  String _selectedEpisodeLink = '';

  double _tabBarOffset = 0;
  bool _tabBarOffsetCalculated = false;

  bool _isRecommendationLoaded = false;
  static const double _tabBarPinnedHeight =
      kTextTabBarHeight + 6; // 48 + 6 = 54
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // if (!_tabController.indexIsChanging) {
      //   _scrollToTabBar();
      // }
      final state = context.read<DetailMovieCubit>().state;
      if (state is DetailMovieSuccessed) {
        if (_tabController.index == 2 && !_isRecommendationLoaded) {
          _fetchRecommendations();
        }
      }
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('=== PostFrameCallback: Checking state... ===');
      final cubitState = context.read<DetailMovieCubit>().state;
      debugPrint('=== State type: ${cubitState.runtimeType} ===');

      if (cubitState is DetailMovieSuccessed) {
        final episodes = cubitState.detailMovieModel.episodes ?? [];
        debugPrint(
          '=== Episodes count: ${episodes.length}, isEmpty: ${episodes.isEmpty} ===',
        );
        debugPrint(
          '=== _selectedEpisodeLink before check: $_selectedEpisodeLink ===',
        );

        if (episodes.isNotEmpty && _selectedEpisodeLink.isEmpty) {
          final firstEpisode = episodes.first;
          debugPrint(
            '=== First episode: ${firstEpisode.server_name}, server_data length: ${firstEpisode.server_data.length} ===',
          );

          if (firstEpisode.server_data.isNotEmpty) {
            final firstData = firstEpisode.server_data.first;
            final link = firstData.link_m3u8.isNotEmpty
                ? firstData.link_m3u8
                : firstData.link_embed;
            debugPrint(
              '=== Setting first episode link: $link (m3u8: ${firstData.link_m3u8}, embed: ${firstData.link_embed}) ===',
            );
            setState(() {
              _currentEpisodeIndex = 0;
              _selectedEpisodeLink = link;
            });
            debugPrint(
              '=== After setState - _selectedEpisodeLink: $_selectedEpisodeLink ===',
            );
          } else {
            debugPrint('=== ERROR: server_data is empty! ===');
          }
        } else {
          debugPrint(
            '=== Skipping auto-select: episodes empty or link already selected ===',
          );
        }
      } else {
        debugPrint('=== State is not DetailMovieSuccessed ===');
      }
    });
  }

  void _scrollToTabBarPinned() {
    final ctx = _tabBarMarkerKey.currentContext;
    if (ctx == null || !_scrollController.hasClients) return;

    Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToTabBar() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_tabBarKey.currentContext == null || !_scrollController.hasClients)
        return;

      Scrollable.ensureVisible(
        _tabBarKey.currentContext!,
        alignment: 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onScroll() {
    if (!_isBottom) return;

    final state = context.read<DetailMovieCubit>().state;
    if (state is! DetailMovieSuccessed) return;

    if (_tabController.index == 2) {
      final filterState = context.read<FetchFillterCubit>().state;
      if (filterState is FetchFillterLoaded &&
          !filterState.hasReachedMax &&
          !filterState.isLoadingMore) {
        _fetchRecommendations(isLoadMore: true);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _fetchRecommendations({bool isLoadMore = false}) {
    final state = context.read<DetailMovieCubit>().state;
    if (state is DetailMovieSuccessed) {
      final movie = state.detailMovieModel.movie;
      if (movie.category.isNotEmpty) {
        context.read<FetchFillterCubit>().fetchMovies(
          FillterMovieReq(
            typeList: movie.category.first.slug,
            fillterType: Filltertype.genre,
            limit: '12',
          ),
          isLoadMore: isLoadMore,
        );
        _isRecommendationLoaded = true;
      }
    }
  }

  void _onEpisodeSelected(int episodeIndex, String episodeLink) {
    debugPrint(
      '=== _onEpisodeSelected CALLED: index=$episodeIndex, link=$episodeLink ===',
    );
    setState(() {
      _currentEpisodeIndex = episodeIndex;
      // Scroll to top
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      _selectedEpisodeLink = episodeLink;
    });
  }

  Widget _buildTabContent(MovieModel movie, List<EpisodesModel> episodes) {
    switch (_tabController.index) {
      case 0:
        return MultiSliver(
          children: [
            _EpisodesSliver(
              episodes: episodes,
              movieType: movie.type,
              movie: movie,
              onEpisodeSelected: (index, link) =>
                  _onEpisodeSelected(index, link),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: const SizedBox(height: 50),
            ),
          ],
        );
      case 1:
        return _CastSliver(
          actors: (movie.actor ?? []).map((e) => e.toString()).toList(),
        );
      case 2:
        return const _RecommendationsSliver();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String? _extractYouTubeId(String url) {
    if (url.trim().isEmpty) return null;
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri == null) return null;
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'] ??
            (uri.pathSegments.contains('embed') ? uri.pathSegments.last : null);
      } else if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      }
    } catch (_) {}
    return null;
  }

  void _initializeYouTubePlayer(String trailerUrl) {
    if (_youtubeController != null) return;
    final videoId = _extractYouTubeId(trailerUrl);
    if (videoId != null) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _youtubeController =
            YoutubePlayerController(
              initialVideoId: videoId,
              flags: YoutubePlayerFlags(
                startAt: widget.startAt?.inSeconds ?? 0,
                autoPlay: true,
                mute: false,
                enableCaption: false,
                showLiveFullscreenButton: false,
                forceHD: false,
                disableDragSeek: true,
                loop: true,
              ),
            )..addListener(() {
              if (mounted && _youtubeController != null) {
                if (_youtubeController!.value.errorCode != 0) {
                  if (!_isPlayerError) {
                    setState(() => _isPlayerError = true);
                  }
                }
              }
            });
        if (mounted) setState(() {});
      });
    } else {
      setState(() => _isPlayerError = true);
    }
  }

  void _toggleMute() {
    if (_youtubeController == null) return;
    if (_isMuted) {
      _youtubeController!.unMute();
    } else {
      _youtubeController!.mute();
    }
    setState(() => _isMuted = !_isMuted);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.bgApp,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<DetailMovieCubit, DetailMovieState>(
            listener: (context, state) {
              if (state is DetailMovieSuccessed) {
                final movie = state.detailMovieModel.movie;

                if (movie.trailer_url.isNotEmpty) {
                  _initializeYouTubePlayer(movie.trailer_url);
                }
              }
            },
            builder: (context, state) {
              if (state is DetailMovieSuccessed) {
                return _buildBody(
                  state.detailMovieModel.movie,
                  state.detailMovieModel.episodes,
                );
              } else if (state is DetailMovieLoading) {
                return _buildLoadingSkeleton();
              }
              return const Center(
                child: Text(
                  "Lỗi tải phim",
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    MovieModel movie, [
    List<EpisodesModel> episodes = const [],
  ]) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            key: _beforeTabBarKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(movie),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _buildButtons(movie, episodes),
                      const SizedBox(height: 24),
                      _buildTitleSection(movie),
                      const SizedBox(height: 16),
                      _buildInfoChips(movie),
                      const SizedBox(height: 16),
                      if (movie.category.isNotEmpty) ...[
                        _buildCategories(movie.category),
                        const SizedBox(height: 20),
                      ],
                      _buildExtraInfor(movie),
                      const SizedBox(height: 16),
                      if (movie.content.isNotEmpty) ...[
                        _buildDescription(movie),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(key: _tabBarMarkerKey, height: 1)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.only(bottom: 6),
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorColor: AppColor.secondColor,
              labelColor: AppColor.secondColor,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              labelPadding: const EdgeInsets.only(right: 24),
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: 'Tập phim'),
                Tab(text: 'Diễn viên'),
                Tab(text: 'Đề xuất'),
              ],
            ),
            key: _tabBarKey, // <<< thêm dòng này
          ),
        ),
        // SliverToBoxAdapter(key: _tabBarKey, child: const SizedBox(height: 1)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          sliver: _buildTabContent(movie, episodes),
        ),
        // SliverFillRemaining(
        //   hasScrollBody: false,
        //   child: SizedBox.expand(
        //     child: Padding(
        //       padding: EdgeInsets.only(
        //         bottom: MediaQuery.of(context).padding.bottom + 12,
        //       ),
        //       child: const SizedBox.shrink(),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildHeader(MovieModel movie) {
    final hasTrailer = movie.trailer_url.trim().isNotEmpty;
    final String posterUrl = movie.thumb_url.isNotEmpty
        ? movie.thumb_url
        : movie.poster_url;
    final displayUrl = posterUrl.startsWith('http')
        ? posterUrl
        : AppUrl.convertImageAddition(posterUrl);

    final showSkeleton = hasTrailer && !_isPlayerReady && !_isPlayerError;
    final showPlayer =
        hasTrailer && _youtubeController != null && !_isPlayerError;
    final showThumbnail =
        (!hasTrailer || _isPlayerError) && displayUrl.isNotEmpty;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (showThumbnail)
                FastCachedImage(url: displayUrl, fit: BoxFit.cover),

              if (showPlayer)
                YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  onReady: () {
                    if (mounted) {
                      _youtubeController?.play();
                      setState(() => _isPlayerReady = true);
                    }
                  },
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(isExpanded: true),
                    RemainingDuration(),
                  ],
                ),

              if (showSkeleton)
                Shimmer.fromColors(
                  baseColor: Color(0xff272A39).withOpacity(.2),
                  highlightColor: Color(0xff191A24).withOpacity(.2),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),

        if (!showPlayer)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColor.bgApp],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

        if (showPlayer) ...[
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],

        Positioned(
          top: 10,
          left: 10,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(MovieModel movie) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.origin_name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          movie.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.secondColor,
          ),
        ),
      ],
    );
  }

  // Widget _polkEffect() {
  //   return PolkBackGround(
  //     dotColor: AppColor.bgApp.withOpacity(.5),
  //     dotRadius: .5,
  //     spacing: 4,
  //   );
  // }

  Widget _buildInfoChips(MovieModel movie) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildInforChip(
          borderColor: const Color(0xfff85032),
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
                movie.tmdb?.vote_average?.toStringAsFixed(1) ?? "N/A",
                style: const TextStyle(
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
            movie.quality,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        _buildInforChip(
          child: Text(
            movie.year.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        if (movie.time.isNotEmpty)
          _buildInforChip(
            child: Text(
              (movie.episode_current == 'Full')
                  ? movie.time.toFormatEpisode()
                  : movie.time,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        if (movie.chieurap == true)
          _buildInforChip(
            isGadient: true,
            borderColor: Colors.transparent,
            child: const Text(
              'Chiếu Rạp',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        if (movie.sub_docquyen == true)
          _buildInforChip(
            isGadient: true,
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
          backgroundColor: Colors.white,
          child: Text(
            movie.episode_current,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        _buildInforChip(
          child: Text(
            movie.lang,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInforChip({
    Color? borderColor,
    bool isGadient = false,
    Widget? child,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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

  Widget _buildCategories(List<CategoryModel> categories) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 5,
      runSpacing: 5,
      children: List.generate(categories.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            categories[index].name,
            style: const TextStyle(fontSize: 9, color: Colors.white),
          ),
        );
      }),
    );
  }

  Widget _buildExtraInfor(MovieModel movie) {
    String directorName = 'Đang cập nhật';
    if (movie.director != null && movie.director!.isNotEmpty) {
      directorName = movie.director!.map((d) => d.toString()).join(', ');
    }
    final dateValue = movie.created?.time;

    final releaseDate = DateFormat(
      'dd/MM/yyyy',
    ).format(dateValue ?? DateTime.now());
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 300,
                width: double.infinity,
                child: FastCachedImage(
                  url: AppUrl.convertImageDirect(movie.thumb_url),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, loadingProgress) {
                    return _buildSkeletonForThumbnail();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildSkeletonForThumbnail();
                  },
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColor.bgApp.withOpacity(.2),
                  AppColor.bgApp.withOpacity(.2),
                  AppColor.bgApp,
                  AppColor.bgApp,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // _polkEffect(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.6),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.1),
                  AppColor.bgApp.withOpacity(.6),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),

                      // height: 180,
                      decoration: BoxDecoration(
                        color: AppColor.bgApp.withOpacity(.1),
                        border: Border(
                          top: BorderSide(color: Colors.grey.withOpacity(.5)),
                          // right: BorderSide(
                          //   color: Colors.grey.withOpacity(.5),
                          // ),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      // child: BackdropFilter(
                      //   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      //   child: Container(color: Colors.transparent),
                      // ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Căn đáy để Poster và Text thẳng hàng dưới
                          children: [
                            // 1. POSTER
                            Container(
                              height: 180,
                              width:
                                  120, // Nên set width cụ thể để Expanded bên cạnh tính toán đúng
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  // Thêm bóng đổ cho Poster nổi lên
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  6,
                                ), // Trừ đi border width
                                child: FastCachedImage(
                                  url: AppUrl.convertImageDirect(
                                    movie.poster_url,
                                  ),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, loadingProgress) {
                                    return _buildSkeletonForposter();
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildSkeletonForposter();
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 15,
                            ), // Khoảng cách giữa Poster và Text
                            // 2. PHẦN THÔNG TIN (SỬA Ở ĐÂY)
                            // Bắt buộc phải có Expanded ở đây để giới hạn chiều rộng cho Column
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      topLeft: Radius.circular(30),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),

                        // height: 180,
                        decoration: BoxDecoration(
                          color: AppColor.bgApp.withOpacity(.3),
                          border: Border(
                            top: BorderSide(color: Colors.grey.withOpacity(.5)),
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            topLeft: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBullet(directorName, 'Đạo diễn:'),
                            const SizedBox(height: 8),
                            _buildBullet(releaseDate, 'Ngày tạo:'),
                            const SizedBox(height: 8),
                            _buildBullet(
                              movie.year.toString(),
                              'Năm sản xuất:',
                            ),
                            const SizedBox(height: 8),
                            _buildBullet(movie.country[0].name, 'Quốc gia:'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildSkeletonForThumbnail() {
    // Bọc AspectRatio để đảm bảo nó luôn có hình dáng poster phim (2:3)
    return Shimmer.fromColors(
      baseColor: Color(0xff272A39),
      highlightColor: Color(0xff4A4E69), // Màu sáng hơn để thấy hiệu ứng
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black, // Bắt buộc phải có màu để Shimmer phủ lên
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBullet(String content, String title) => Row(
    children: [
      Text(
        '$title ',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
      // Bây giờ Expanded này mới hoạt động đúng
      Expanded(
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white, // Sáng hơn chút cho dễ đọc
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    ],
  );

  Widget _buildButtons(MovieModel movie, List<EpisodesModel> episodes) {
    // final movieType = movie.type.toLowerCase();

    if (episodes.isNotEmpty && _selectedEpisodeLink.isEmpty) {
      final firstEpisode = episodes.first;
      debugPrint(
        '=== Auto-select check: server_name=${firstEpisode.server_name}, server_data.length=${firstEpisode.server_data.length} ===',
      );
      if (firstEpisode.server_data.isNotEmpty) {
        final firstData = firstEpisode.server_data.first;
        debugPrint(
          '=== First server data: m3u8="${firstData.link_m3u8}", embed="${firstData.link_embed}" ===',
        );
        final link = firstData.link_m3u8.isNotEmpty
            ? firstData.link_m3u8
            : firstData.link_embed;
        if (link.isNotEmpty) {
          debugPrint('=== Auto-selecting episode in _buildButtons: $link ===');
          _currentEpisodeIndex = 0;
          _selectedEpisodeLink = link;
        } else {
          debugPrint('=== ERROR: Both m3u8 and embed are empty! ===');
        }
      } else {
        debugPrint('=== ERROR: server_data is empty! ===');
      }
    }

    debugPrint(
      '=== _buildButtons: episodes=${episodes.length}, selectedLink=$_selectedEpisodeLink, currentIndex=$_currentEpisodeIndex ===',
    );
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();

              if (episodes.isNotEmpty && _selectedEpisodeLink.isEmpty) {
                final firstEpisode = episodes.first;
                debugPrint(
                  '=== Auto-select in onTap: server_name=${firstEpisode.server_name}, server_data.length=${firstEpisode.server_data.length} ===',
                );
                if (firstEpisode.server_data.isNotEmpty) {
                  final firstData = firstEpisode.server_data.first;
                  debugPrint(
                    '=== First server data in onTap: m3u8="${firstData.link_m3u8}", embed="${firstData.link_embed}" ===',
                  );
                  final link = firstData.link_m3u8.isNotEmpty
                      ? firstData.link_m3u8
                      : firstData.link_embed;
                  if (link.isNotEmpty) {
                    debugPrint('=== Auto-selecting in onTap: $link ===');
                    _currentEpisodeIndex = 0;
                    _selectedEpisodeLink = link;
                  } else {
                    debugPrint(
                      '=== ERROR in onTap: Both m3u8 and embed are empty! ===',
                    );
                  }
                } else {
                  debugPrint('=== ERROR in onTap: server_data is empty! ===');
                }
              }

              debugPrint(
                '=== Button tapped: episodes=${episodes.length}, selectedLink=$_selectedEpisodeLink, currentIndex=$_currentEpisodeIndex ===',
              );

              if (episodes.isNotEmpty && _selectedEpisodeLink.isNotEmpty) {
                debugPrint(
                  '=== Navigating to player with link: $_selectedEpisodeLink, index: $_currentEpisodeIndex ===',
                );
                Navigator.of(context).push(
                  NoBackSwipeRoute(
                    builder: (_) => MoviePlayerPage(
                      movie: movie,
                      slug: movie.slug,
                      movieName: movie.name,
                      thumbnailUrl: movie.thumb_url.isNotEmpty
                          ? movie.thumb_url
                          : movie.poster_url,
                      episodes: episodes,
                      initialEpisodeLink: _selectedEpisodeLink,
                      initialEpisodeIndex: _currentEpisodeIndex,
                      initialServer: episodes.first.server_name,
                      initialServerIndex: 0,
                    ),
                  ),
                );
                // AppNavigator.push(
                //   context,
                //   NoBackSwipeRoute(
                //     builder: (_) => MoviePlayerPage(
                //       movie: movie,
                //       slug: movie.slug,
                //       movieName: movie.name,
                //       thumbnailUrl: movie.thumb_url.isNotEmpty
                //           ? movie.thumb_url
                //           : movie.poster_url,
                //       episodes: episodes,
                //       initialEpisodeLink: _selectedEpisodeLink,
                //       initialEpisodeIndex: _currentEpisodeIndex,
                //       initialServer: episodes.first.server_name,
                //     ),
                //   ),
                // );
              } else {
                debugPrint(
                  '=== Cannot navigate: episodes empty or link empty ===',
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.play_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Xem Phim',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_tabController.index != 0) {
                _tabController.animateTo(0);
              }
              _scrollToTabBarPinned();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.menu_1, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Tập Phim',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _cleanHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

    // 1. Xóa thẻ HTML
    String textWithoutTags = htmlString.replaceAll(exp, '');
    String textWithoutTagsSecond = textWithoutTags
        .replaceAll('&nbsp;', ' ')
        .trim();
    String textWithoutTagsThird = textWithoutTagsSecond
        .replaceAll('&#39;', ' ')
        .trim();

    // 2. Thay thế &nbsp; bằng dấu cách
    return textWithoutTagsThird.replaceAll('&quot;', ' ').trim();
  }

  bool _shouldShowButton(String content) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: content,
        style: const TextStyle(fontSize: 12, height: 1.5),
      ),
      textDirection: Directionality.of(context),
      maxLines: 4,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32);

    return textPainter.didExceedMaxLines;
  }

  Widget _buildDescription(MovieModel movie) {
    final cleanContent = _cleanHtmlTags(movie.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới thiệu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: Text(
            cleanContent,
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        if (_shouldShowButton(cleanContent))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(
                _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                style: TextStyle(
                  color: AppColor.secondColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Color(0xff272A39).withOpacity(.2),
      highlightColor: Color(0xff191A24).withOpacity(.2),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(6, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            height: 18,
                            width: 60 + (index * 10),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: List.generate(4, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            height: 14,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
