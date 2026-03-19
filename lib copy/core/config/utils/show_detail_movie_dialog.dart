import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/home/data/models/detail_movie_model.dart';
import 'package:movie_app/feature/home/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/home/presentation/bloc/detail_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/detail_movie_state.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShowDetailMovieDialog extends StatelessWidget {
  const ShowDetailMovieDialog({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DetailMovieCubit(sl<GetDetailMovieUsecase>())..getDetailMovie(slug),
      child: const _DialogContent(),
    );
  }
}

class _DialogContent extends StatefulWidget {
  const _DialogContent();

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  YoutubePlayerController? _youtubeController;
  String? _youtubeVideoId;

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  String? _extractYouTubeId(String url) {
    if (url.trim().isEmpty) return null;
    try {
      final trimmedUrl = url.trim();
      final uri = Uri.tryParse(trimmedUrl);
      if (uri == null) return null;

      if (uri.host.contains('youtube.com')) {
        if (uri.queryParameters.containsKey('v')) {
          return uri.queryParameters['v'];
        }
        if (uri.pathSegments.isNotEmpty) {
          final embedIndex = uri.pathSegments.indexOf('embed');
          if (embedIndex != -1 && embedIndex + 1 < uri.pathSegments.length) {
            return uri.pathSegments[embedIndex + 1].split('?').first;
          }
          final vIndex = uri.pathSegments.indexOf('v');
          if (vIndex != -1 && vIndex + 1 < uri.pathSegments.length) {
            return uri.pathSegments[vIndex + 1].split('?').first;
          }
          final shortsIndex = uri.pathSegments.indexOf('shorts');
          if (shortsIndex != -1 && shortsIndex + 1 < uri.pathSegments.length) {
            return uri.pathSegments[shortsIndex + 1].split('?').first;
          }
        }
      } else if (uri.host.contains('youtu.be')) {
        if (uri.pathSegments.isNotEmpty) {
          return uri.pathSegments.first.split('?').first;
        }
      }

      final regExp = RegExp(
        r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(trimmedUrl);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    } catch (e) {
      debugPrint('Error extracting video ID: $e');
    }
    return null;
  }

  void _initializeYouTubePlayer(String trailerUrl) {
    if (_youtubeController != null) return;

    final videoId = _extractYouTubeId(trailerUrl);
    debugPrint('Trailer URL: $trailerUrl');
    debugPrint('Extracted YouTube ID: $videoId');

    if (videoId != null && videoId.length == 11) {
      _youtubeVideoId = videoId;

      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          showLiveFullscreenButton: true,
        ),
      );

      debugPrint('YoutubeController created');

      // Add listener to debug player state
      _youtubeController!.addListener(() {
        if (_youtubeController!.value.isReady) {
          debugPrint('Player is ready');
        }
        if (_youtubeController!.value.playerState == PlayerState.playing) {
          debugPrint('Player is playing');
        }
      });

      // Trigger rebuild to show the player
      if (mounted) {
        setState(() {});
      }
    } else {
      debugPrint('Invalid video ID or extraction failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
            return _buildDialog(state);
          }
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 500,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Đang tải...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialog(DetailMovieSuccessed state) {
    final movie = state.detailMovieModel.movie;
    final episodes = state.detailMovieModel.episodes;
    final hasTrailer = _youtubeVideoId != null && _youtubeController != null;

    debugPrint(
      '_buildDialog - hasTrailer: $hasTrailer, videoId: $_youtubeVideoId, controller: $_youtubeController',
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(movie, hasTrailer),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
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
                      const SizedBox(height: 12),
                      _buildInfoChips(movie),
                      const SizedBox(height: 16),
                      if (movie.category.isNotEmpty) ...[
                        _buildCategories(movie.category),
                        const SizedBox(height: 16),
                      ],
                      if (movie.content.isNotEmpty) ...[
                        Text(
                          'Nội dung',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _cleanHtmlTags(movie.content),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildActionButtons(movie, episodes),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MovieModel movie, bool hasTrailer) {
    final String posterUrl = movie.thumb_url.isNotEmpty
        ? movie.thumb_url
        : movie.poster_url;
    final String displayUrl = posterUrl.startsWith('http')
        ? posterUrl
        : AppUrl.convertImageAddition(posterUrl);

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: hasTrailer && _youtubeController != null
                ? YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.red,
                  )
                : FastCachedImage(url: displayUrl, fit: BoxFit.cover),
          ),
        ),
        if (!hasTrailer)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
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
        ),
        if (movie.tbdm != null && !hasTrailer)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.secondColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    movie.tbdm!.vote_average.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!hasTrailer)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xffe73827), Color(0xffFE8873)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                movie.quality,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChips(MovieModel movie) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _infoChip(Icons.calendar_today, movie.year.toString()),
        if (movie.time.isNotEmpty) _infoChip(Icons.access_time, movie.time),
        _infoChip(Icons.language, movie.lang.toUpperCase()),
        _infoChip(Icons.video_library, movie.episode_current),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<CategoryModel> categories) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: categories.take(5).map((cat) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColor.secondColor.withOpacity(0.8),
                AppColor.secondColor.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            cat.name,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(MovieModel movie, List<EpisodesModel> episodes) {
    final bool hasEpisodes =
        episodes.isNotEmpty && episodes.first.server_data.isNotEmpty;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (hasEpisodes) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đang phát: ${movie.origin_name}'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColor.secondColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phim chưa có tập nào'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasEpisodes
                      ? [const Color(0xffe73827), const Color(0xffFE8873)]
                      : [Colors.grey, Colors.grey.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: hasEpisodes
                    ? [
                        BoxShadow(
                          color: const Color(0xffe73827).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
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
                      fontSize: 14,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chi tiết: ${movie.origin_name}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
    return htmlString.replaceAll(exp, '').trim();
  }
}
