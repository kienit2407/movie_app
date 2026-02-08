import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/utils/cover_map.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EpisodeDrawer extends StatefulWidget {
  final MovieModel movie;
  final String movieName;
  final List<EpisodesModel> episodes;
  final int selectedServerIndex;
  final int currentEpisodeIndex;
  final String currentServer;
  final TextEditingController searchController;
  final Function(int, EpisodesModel) onPlayEpisode;
  final VoidCallback onSubmitEpisode;
  final Function(int) onSwitchServer;
  ScrollController? scrollController;
  final VoidCallback? onDrawerOpened;

  EpisodeDrawer({
    super.key,
    required this.movie,
    required this.movieName,
    required this.episodes,
    required this.selectedServerIndex,
    required this.currentEpisodeIndex,
    required this.currentServer,
    required this.searchController,
    required this.onPlayEpisode,
    required this.onSubmitEpisode,
    required this.onSwitchServer,
    this.scrollController, this.onDrawerOpened,
  });

  @override
  State<EpisodeDrawer> createState() => EpisodeDrawerState();
}

class EpisodeDrawerState extends State<EpisodeDrawer> {
  final List<GlobalKey> _episodeKeys = [];
  late final ScrollController _gridCtrl;

  @override
  void initState() {
    super.initState();
    _gridCtrl = widget.scrollController ?? ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentEpisode(animated: false);
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _gridCtrl.dispose();
    super.dispose();
  }

  void _ensureEpisodeKeys(int count) {
    if (_episodeKeys.length == count) return;
    _episodeKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));
  }
  void scrollToCurrentEpisode({bool animated = true}) => _scrollToCurrentEpisode(animated: animated);
  void _scrollToCurrentEpisode({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serverData =
          widget.episodes[widget.selectedServerIndex].server_data;
      if (serverData.isEmpty) return;

      _ensureEpisodeKeys(serverData.length); // đảm bảo đủ keys

      final idx = widget.currentEpisodeIndex.clamp(0, serverData.length - 1);
      final ctx = _episodeKeys[idx].currentContext;
      if (ctx == null) return;

      Scrollable.ensureVisible(
        ctx,
        duration: animated ? const Duration(milliseconds: 350) : Duration.zero,
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSeriesMovie = widget.movie.episode_current != 'Full';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSeriesMovie) ...[
          _buildListServerForSeriesMovie(),
          _textFieldEpisode(),
        ],
        Expanded(
          child: isSeriesMovie
              ? _buildListEpisodeForSeriesMovie()
              : _buildEpisodeListForSingle(),
        ),
      ],
    );
  }

  Widget _textFieldEpisode() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Tập 1 - ${widget.episodes[widget.selectedServerIndex].server_data.length}',
                  style: const TextStyle(
                    color: Color(0xff707070),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.white.withValues(alpha: 0.1),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    onSubmitted: (_) => widget.onSubmitEpisode(),
                    controller: widget.searchController,
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: 'Nhập tập',
                      hintStyle: const TextStyle(
                        color: Color(0xff9E9E9E),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: const Icon(
                        Iconsax.search_normal_1_copy,
                        color: Colors.white,
                        size: 16,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 32,
                        minHeight: 36,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Iconsax.arrow_right_3_copy,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: widget.onSubmitEpisode,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListEpisodeForSeriesMovie() {
    final serverData = widget.episodes[widget.selectedServerIndex].server_data;
    _ensureEpisodeKeys(serverData.length); //  BẮT BUỘC
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        child: GridView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100,
            mainAxisSpacing: 8,
            mainAxisExtent: 40,
            crossAxisSpacing: 8,
            childAspectRatio: 14 / 9,
          ),
          itemCount: serverData.length,
          itemBuilder: (context, index) {
            final key = _episodeKeys[index];
            final episode = serverData[index];
            final bool isActive = widget.currentEpisodeIndex == index;
            final currentServer = widget.episodes[widget.selectedServerIndex];

            return KeyedSubtree(
              key: key,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onPlayEpisode(index, currentServer),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xff272A39),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFC77DFF),
                                Color(0xFFFF9E9E),
                                Color(0xFFFFD275),
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isActive) ...[
                          const SizedBox(width: 3),
                          SizedBox(
                            width: 13,
                            height: 13,
                            child: Lottie.asset(
                              'assets/icons/now_playing.json',
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.color(const [
                                    '**',
                                  ], value: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            episode.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xff707070),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
    );
  }

  Widget _buildListServerForSeriesMovie() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff272A39), Color(0xff191A24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        scrollDirection: Axis.horizontal,
        itemCount: widget.episodes.length,
        itemBuilder: (context, index) {
          final serverInfo = CoverMap.getConfigFromServerName(
            widget.episodes[index].server_name,
          );
          final isSelected = widget.selectedServerIndex == index;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onSwitchServer(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    serverInfo['title'] ?? 'Server ${index + 1}',
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodeListForSingle() {
    return SafeArea(
      child: GridView.builder(
        controller: _gridCtrl,
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 16 / 9,
        ),
        itemCount: widget.episodes.length,
        itemBuilder: (context, index) {
          final serverName = CoverMap.getConfigFromServerName(
            widget.episodes[index].server_name,
          );
          final isPlaying = widget.selectedServerIndex == index;
          final isCurrentServer =
              widget.currentServer == widget.episodes[index].server_name;

          return Material(
            color: Colors.transparent,
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => widget.onSwitchServer(index),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.horizontal(
                          right: Radius.circular(10),
                        ),
                        child: FastCachedImage(
                          url: AppUrl.convertImageDirect(
                            widget.movie.poster_url,
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.movieName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 5,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isPlaying && isCurrentServer
                                        ? 'Đang phát'
                                        : 'Xem bản này',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  isPlaying && isCurrentServer
                                      ? const SizedBox(width: 4)
                                      : const SizedBox.shrink(),
                                  isPlaying && isCurrentServer
                                      ? SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: Lottie.asset(
                                            'assets/icons/now_playing.json',
                                            delegates: LottieDelegates(
                                              values: [
                                                ValueDelegate.color(const [
                                                  '**',
                                                ], value: Colors.black),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
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
        },
      ),
    );
  }

  Widget _buildSkeletonForposter() {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Shimmer.fromColors(
        baseColor: Color(0xff272A39),
        highlightColor: Color(0xff4A4E69),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
