import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/utils/blocking_back_page.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';

class MovieDetailActionButtons extends StatefulWidget {
  final MovieModel movie;
  final List<EpisodesModel> episodes;
  final String selectedEpisodeLink;
  final int currentEpisodeIndex;
  final TabController tabController;
  final ScrollController scrollController;
  final GlobalKey tabBarMarkerKey;
  final VoidCallback onScrollToTabBar;

  const MovieDetailActionButtons({
    super.key,
    required this.movie,
    required this.episodes,
    required this.selectedEpisodeLink,
    required this.currentEpisodeIndex,
    required this.tabController,
    required this.scrollController,
    required this.tabBarMarkerKey,
    required this.onScrollToTabBar,
  });

  @override
  State<MovieDetailActionButtons> createState() =>
      _MovieDetailActionButtonsState();
}

class _MovieDetailActionButtonsState extends State<MovieDetailActionButtons> {
  late String _selectedLink;
  late int _currentEpIndex;

  @override
  void initState() {
    super.initState();
    _selectedLink = widget.selectedEpisodeLink;
    _currentEpIndex = widget.currentEpisodeIndex;
  }

  @override
  void didUpdateWidget(MovieDetailActionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEpisodeLink != oldWidget.selectedEpisodeLink) {
      _selectedLink = widget.selectedEpisodeLink;
    }
    if (widget.currentEpisodeIndex != oldWidget.currentEpisodeIndex) {
      _currentEpIndex = widget.currentEpisodeIndex;
    }
  }

  void _navigateToPlayer(
    int serverIndex,
    int episodeIndex,
    String episodeLink,
  ) {
    if (widget.episodes.isEmpty) return;
    Navigator.of(context).push(
      NoBackSwipeRoute(
        builder: (_) => MoviePlayerPage(
          slug: widget.movie.slug,
          movieName: widget.movie.name,
          thumbnailUrl: widget.movie.poster_url,
          episodes: widget.episodes,
          movie: widget.movie,
          initialEpisodeLink: episodeLink,
          initialEpisodeIndex: episodeIndex,
          initialServer: widget.episodes[serverIndex].server_name,
          initialServerIndex: serverIndex,
        ),
      ),
    );
  }

  void _playFirstEpisode() {
    if (widget.episodes.isEmpty) return;
    if (widget.episodes[0].server_data.isEmpty) return;
    int serverIndex = 0;
    int episodeIndex = 0;
    String episodeLink = widget.episodes[0].server_data[0].link_m3u8.isNotEmpty
        ? widget.episodes[0].server_data[0].link_m3u8
        : widget.episodes[0].server_data[0].link_embed;
    _navigateToPlayer(serverIndex, episodeIndex, episodeLink);
  }

  void _playLatestEpisode() {
    if (widget.episodes.isEmpty) return;

    int? currentEpisodeNum;
    final episodeCurrent = widget.movie.episode_current;

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
      for (int s = 0; s < widget.episodes.length; s++) {
        final serverEpisodes = widget.episodes[s].server_data;
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
      _playFirstEpisode();
      return;
    }

    _navigateToPlayer(serverIndex, episodeIndex, episodeLink);
  }

  Widget _buildPlayButton({
    required String text,
    required VoidCallback onTap,
    bool isPrimary = true,
    int flex = 2,
  }) {
    final isFullMovie = widget.movie.episode_current == 'Full';

    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: isPrimary
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
            color: isPrimary ? null : Colors.white.withOpacity(0.1),
            boxShadow: isPrimary
                ? const [
                    BoxShadow(
                      color: Color(0xFFC77DFF),
                      blurRadius: 12,
                      offset: Offset(0, 0),
                      spreadRadius: -2,
                    ),
                  ]
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isFullMovie
                  ? const Icon(Iconsax.play_circle)
                  : const SizedBox.shrink(),
              Text(
                text,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFullMovie = widget.movie.episode_current == 'Full';

    if (widget.episodes.isNotEmpty && _selectedLink.isEmpty) {
      final firstEpisode = widget.episodes.first;
      if (firstEpisode.server_data.isNotEmpty) {
        final firstData = firstEpisode.server_data.first;
        final link = firstData.link_m3u8.isNotEmpty
            ? firstData.link_m3u8
            : firstData.link_embed;
        if (link.isNotEmpty) {
          _currentEpIndex = 0;
          _selectedLink = link;
        }
      }
    }

    return Row(
      spacing: 5,
      children: [
        if (!isFullMovie)
          _buildPlayButton(
            text: 'Xem tập mới',
            onTap: () => _playLatestEpisode(),
            flex: 1,
          ),
        _buildPlayButton(
          text: 'Xem phim',
          onTap: () => _playFirstEpisode(),
          flex: isFullMovie ? 2 : 1,
        ),
        if (isFullMovie) const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.tabController.index != 0) {
                widget.tabController.animateTo(0);
              }
              widget.onScrollToTabBar();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.7)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.menu_1, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Tập Phim',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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
}
