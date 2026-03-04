import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/blocking_back_page.dart';
import 'package:movie_app/core/config/utils/cover_map.dart';
import 'package:movie_app/core/mini_player_manager.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';

class EpisodesSliver extends StatefulWidget {
  final List<EpisodesModel> episodes;
  final MovieModel movie;
  final String movieType;
  final Function(int episodeIndex, String episodeLink)? onEpisodeSelected;

  const EpisodesSliver({
    super.key,
    required this.episodes,
    required this.movieType,
    this.onEpisodeSelected,
    required this.movie,
  });

  @override
  State<EpisodesSliver> createState() => _EpisodesSliverState();
}

class _EpisodesSliverState extends State<EpisodesSliver> {
  String? _selectedServer;
  final TextEditingController _searchController = TextEditingController();
  int _selectedServerIndex = 0;

  EpisodesModel get _currentServerModel =>
      widget.episodes[_selectedServerIndex];
  List<ServerData> get _currentServerData => _currentServerModel.server_data;

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
      final raw = list[i].name;
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

    if (MiniPlayerManager.isVisible.value) {
      MiniPlayerManager.dismissMiniPlayer();
    }

    Navigator.push(
      context,
      NoBackSwipeRoute(
        builder: (_) => MoviePlayerPage(
          movie: widget.movie,
          episodes: widget.episodes,
          movieName: widget.movie.name,
          slug: widget.movie.slug,
          initialEpisodeIndex: episodeIndex,
          initialServer: _currentServerModel.server_name,
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

    return isFullMovie
        ? _buildFullMovieServersSliver()
        : _buildSeriesEpisodesSliver();
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
                  if (ep.server_data.isEmpty) return;

                  final data = ep.server_data.first;
                  final link = data.link_m3u8.isNotEmpty
                      ? data.link_m3u8
                      : data.link_embed;
                  widget.onEpisodeSelected?.call(index, link);
                  if (MiniPlayerManager.isVisible.value) {
                    MiniPlayerManager.dismissMiniPlayer();
                  }
                  Navigator.push(
                    context,
                    NoBackSwipeRoute(
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
            crossAxisSpacing: 5,
            childAspectRatio: 16 / 9,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  MultiSliver _buildSeriesEpisodesSliver() {
    final isSingle = widget.movieType == 'single';
    final itemsToShow = isSingle ? widget.episodes : _currentServerData;

    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            height: 50,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              scrollDirection: Axis.horizontal,
              itemCount: widget.episodes.length,
              itemBuilder: (context, index) {
                final serverInfo = CoverMap.getConfigFromServerName(
                  widget.episodes[index].server_name,
                );
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
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Nhập tập',
                        hintStyle: TextStyle(
                          color: Colors.white30,
                          fontSize: 10,
                          height: 1.0,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 6, right: 6),
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 28,
                          minHeight: 32,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverGrid(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = itemsToShow[index];

            final label = isSingle
                ? (item as EpisodesModel).server_name
                : (item as ServerData).name;

            return GestureDetector(
              onTap: () {
                final selectedModel = _currentServerModel;
                if (selectedModel.server_data.isEmpty) return;

                final episodeData = selectedModel.server_data[index];
                final link = episodeData.link_m3u8.isNotEmpty
                    ? episodeData.link_m3u8
                    : episodeData.link_embed;

                widget.onEpisodeSelected?.call(index, link);

                Navigator.push(
                  context,
                  NoBackSwipeRoute(
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
