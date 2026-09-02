import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/player_overlay_controller.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';

extension PlayerOverlayLauncher on BuildContext {
  void openMoviePlayer(MoviePlayerArgs args) {
    if (args.bypassSeriesResumePrompt || !_isSeries(args)) {
      _openPlayer(args);
      return;
    }

    UserWatchHistory? history;
    try {
      final library = read<UserLibraryCubit>();
      if (!library.state.isAuthenticated) {
        _openPlayer(args);
        return;
      }
      for (final item in library.state.history) {
        if (item.slug == args.slug && item.lastEpisodeIndex != null) {
          history = item;
          break;
        }
      }
    } catch (_) {
      _openPlayer(args);
      return;
    }

    final target = history == null
        ? null
        : _resolveHistoryTarget(args, history);
    if (history == null || target == null || !mounted) {
      _openPlayer(args);
      return;
    }
    unawaited(_promptForSeriesResume(this, args, history, target));
  }
}

void _openPlayer(MoviePlayerArgs args) {
  PlayerOverlayController.instance.open(args, minimizeEnabled: false);
}

Future<void> _promptForSeriesResume(
  BuildContext context,
  MoviePlayerArgs args,
  UserWatchHistory history,
  _PlaybackTarget target,
) async {
  final continueWatching = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) => AppAlertDialog(
      icon: const Icon(Iconsax.video_play, color: Colors.white, size: 30),
      title: 'Tiếp tục xem?',
      content:
          'Bạn đang xem ${history.lastEpisodeName ?? 'tập ${target.episodeIndex + 1}'}. '
          'Bạn muốn xem tiếp tập này hay xem lại từ tập 1?',
      cancelButtonTitle: 'Xem lại từ đầu',
      buttonTitle: 'Xem tiếp',
    ),
  );
  if (continueWatching == null) return;

  if (!continueWatching) {
    final firstTarget = _firstEpisodeTarget(args);
    _openPlayer(
      firstTarget == null
          ? args.copyWith(resumeFromHistory: false)
          : args.copyWith(
              initialEpisodeLink: firstTarget.episodeLink,
              initialEpisodeIndex: firstTarget.episodeIndex,
              initialServer: firstTarget.serverName,
              initialServerIndex: firstTarget.serverIndex,
              resumeFromHistory: false,
              bypassSeriesResumePrompt: true,
            ),
    );
    return;
  }

  _openPlayer(
    args.copyWith(
      initialEpisodeLink: target.episodeLink,
      initialEpisodeIndex: target.episodeIndex,
      initialServer: target.serverName,
      initialServerIndex: target.serverIndex,
      resumeFromHistory: true,
      bypassSeriesResumePrompt: true,
    ),
  );
}

bool _isSeries(MoviePlayerArgs args) {
  if (args.movie.episode_current.trim().toLowerCase() == 'full') return false;
  return args.episodes.any((server) => server.server_data.length > 1);
}

_PlaybackTarget? _firstEpisodeTarget(MoviePlayerArgs args) {
  for (var serverIndex = 0; serverIndex < args.episodes.length; serverIndex++) {
    final server = args.episodes[serverIndex];
    if (server.server_data.isEmpty) continue;
    final episode = server.server_data.first;
    final link = episode.link_m3u8.isNotEmpty
        ? episode.link_m3u8
        : episode.link_embed;
    if (link.isEmpty) continue;
    return _PlaybackTarget(
      serverIndex: serverIndex,
      episodeIndex: 0,
      episodeLink: link,
      serverName: server.server_name,
    );
  }
  return null;
}

_PlaybackTarget? _resolveHistoryTarget(
  MoviePlayerArgs args,
  UserWatchHistory history,
) {
  if (args.episodes.isEmpty) return null;

  var serverIndex = history.lastServerIndex ?? 0;
  final serverName = history.lastServerName?.trim() ?? '';
  if (serverName.isNotEmpty) {
    final namedIndex = args.episodes.indexWhere(
      (server) => server.server_name == serverName,
    );
    if (namedIndex >= 0) serverIndex = namedIndex;
  }
  serverIndex = serverIndex.clamp(0, args.episodes.length - 1).toInt();

  final server = args.episodes[serverIndex];
  if (server.server_data.isEmpty) return null;

  var episodeIndex = history.lastEpisodeIndex ?? 0;
  final episodeName = history.lastEpisodeName?.trim() ?? '';
  if (episodeName.isNotEmpty) {
    final namedIndex = server.server_data.indexWhere(
      (episode) => episode.name.trim() == episodeName,
    );
    if (namedIndex >= 0) episodeIndex = namedIndex;
  }
  episodeIndex = episodeIndex.clamp(0, server.server_data.length - 1).toInt();

  final episode = server.server_data[episodeIndex];
  final link = episode.link_m3u8.isNotEmpty
      ? episode.link_m3u8
      : episode.link_embed;
  if (link.isEmpty) return null;
  return _PlaybackTarget(
    serverIndex: serverIndex,
    episodeIndex: episodeIndex,
    episodeLink: link,
    serverName: server.server_name,
  );
}

class _PlaybackTarget {
  const _PlaybackTarget({
    required this.serverIndex,
    required this.episodeIndex,
    required this.episodeLink,
    required this.serverName,
  });

  final int serverIndex;
  final int episodeIndex;
  final String episodeLink;
  final String serverName;
}
