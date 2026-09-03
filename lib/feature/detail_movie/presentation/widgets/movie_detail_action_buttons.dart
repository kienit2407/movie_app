import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/core/player_overlay_launcher.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

enum _SeriesPlayAction { firstEpisode, latestEpisode }

class MovieDetailActionButtons extends StatefulWidget {
  final MovieModel movie;
  final List<EpisodesModel> episodes;
  final String selectedEpisodeLink;
  final int currentEpisodeIndex;
  final TabController tabController;
  final ScrollController scrollController;
  final GlobalKey tabBarMarkerKey;
  final VoidCallback onScrollToTabBar;
  final VoidCallback? onBeforePlay;

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
    this.onBeforePlay,
  });

  @override
  State<MovieDetailActionButtons> createState() =>
      _MovieDetailActionButtonsState();
}

class _MovieDetailActionButtonsState extends State<MovieDetailActionButtons> {
  late String _selectedLink;

  @override
  void initState() {
    super.initState();
    _selectedLink = widget.selectedEpisodeLink;
  }

  @override
  void didUpdateWidget(MovieDetailActionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEpisodeLink != oldWidget.selectedEpisodeLink) {
      _selectedLink = widget.selectedEpisodeLink;
    }
  }

  void _navigateToPlayer(
    int serverIndex,
    int episodeIndex,
    String episodeLink, {
    bool resumeFromHistory = true,
    bool bypassSeriesResumePrompt = false,
  }) {
    if (widget.episodes.isEmpty) return;
    widget.onBeforePlay?.call();
    context.openMoviePlayer(
      MoviePlayerArgs(
        widget.movie.slug,
        widget.movie.poster_url,
        episodeLink,
        episodeIndex,
        widget.episodes[serverIndex].server_name,
        widget.movie.name,
        widget.episodes,
        widget.movie,
        initialServerIndex: serverIndex,
        resumeFromHistory: resumeFromHistory,
        bypassSeriesResumePrompt: bypassSeriesResumePrompt,
      ),
    );
  }

  void _playFirstEpisode({
    bool resumeFromHistory = true,
    bool bypassSeriesResumePrompt = false,
  }) {
    if (widget.episodes.isEmpty) return;
    if (widget.episodes[0].server_data.isEmpty) return;
    int serverIndex = 0;
    int episodeIndex = 0;
    String episodeLink = widget.episodes[0].server_data[0].link_m3u8.isNotEmpty
        ? widget.episodes[0].server_data[0].link_m3u8
        : widget.episodes[0].server_data[0].link_embed;
    _navigateToPlayer(
      serverIndex,
      episodeIndex,
      episodeLink,
      resumeFromHistory: resumeFromHistory,
      bypassSeriesResumePrompt: bypassSeriesResumePrompt,
    );
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
              final candidateLink = ep.link_m3u8.isNotEmpty
                  ? ep.link_m3u8
                  : ep.link_embed;
              if (candidateLink.isEmpty) continue;
              serverIndex = s;
              episodeIndex = e;
              episodeLink = candidateLink;
              break;
            }
          }
        }
        if (episodeLink != null) break;
      }
    }

    if (episodeLink == null) {
      _playFirstEpisode(bypassSeriesResumePrompt: true);
      return;
    }

    _navigateToPlayer(
      serverIndex,
      episodeIndex,
      episodeLink,
      bypassSeriesResumePrompt: true,
    );
  }

  Widget _buildPlayButton({
    required String text,
    required VoidCallback onTap,
    VoidCallback? onLatestEpisodeTap,
    bool isPrimary = true,
    int flex = 2,
  }) {
    final button = Container(
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
          const Icon(Iconsax.play_circle),
          Text(
            text,
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (onLatestEpisodeTap != null)
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        ],
      ),
    );

    return Expanded(
      flex: flex,
      child: onLatestEpisodeTap == null
          ? GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap();
              },
              child: button,
            )
          : PopupMenuButton<_SeriesPlayAction>(
              tooltip: text,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              color: const Color(0xff242531),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.white.withValues(alpha: .09)),
              ),
              onOpened: HapticFeedback.mediumImpact,
              onSelected: (action) {
                HapticFeedback.selectionClick();
                switch (action) {
                  case _SeriesPlayAction.firstEpisode:
                    onTap();
                    break;
                  case _SeriesPlayAction.latestEpisode:
                    onLatestEpisodeTap();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _SeriesPlayAction.firstEpisode,
                  child: Row(
                    children: [
                      const Icon(Iconsax.play_circle, size: 20),
                      const SizedBox(width: 10),
                      Text(context.l10n.detailWatchMovie),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _SeriesPlayAction.latestEpisode,
                  child: Row(
                    children: [
                      const Icon(Iconsax.next, size: 20),
                      const SizedBox(width: 10),
                      Text(context.l10n.detailWatchLatestEpisode),
                    ],
                  ),
                ),
              ],
              child: button,
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
          _selectedLink = link;
        }
      }
    }

    return Row(
      spacing: 5,
      children: [
        _buildPlayButton(
          text: context.l10n.detailWatchMovie,
          onTap: () => _playFirstEpisode(),
          onLatestEpisodeTap: isFullMovie ? null : _playLatestEpisode,
          flex: 2,
        ),
        const SizedBox(width: 12),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.menu_1, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.detailEpisodesTab,
                    style: const TextStyle(
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
