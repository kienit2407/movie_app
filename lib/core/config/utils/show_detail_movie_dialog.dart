import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/blocking_back_page.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/detail_movie_state.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_detail_page.dart';
import 'package:movie_app/feature/detail_movie/presentation/pages/movie_player_page.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
  bool _isContentExpanded = false;
  bool _isMuted = false;
  bool _isPlayerError = false;
  bool _isPlayerReady = false;

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
      // Reset states
      _isPlayerError = false;
      _isPlayerReady = false;

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;

        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            controlsVisibleAtStart: true,
            mute: false,
            captionLanguage: 'en',
            loop: true,
            enableCaption: true,
            useHybridComposition: true,
            showLiveFullscreenButton: false,
            forceHD: false,
            disableDragSeek: true,
          ),
        );

        debugPrint('YoutubeController created');

        _youtubeController!.addListener(() {
          if (mounted && _youtubeController != null) {
            if (_youtubeController!.value.errorCode != 0) {
              debugPrint(
                'YouTube Error Code: ${_youtubeController!.value.errorCode}',
              );
              if (!_isPlayerError) {
                setState(() {
                  _isPlayerError = true;
                });
              }
            }
          }
        });

        if (mounted) {
          setState(() {});
        }
      });
    } else {
      debugPrint('Invalid video ID or extraction failed');
    }
  }

  void _toggleMute() {
    if (_youtubeController == null) return;

    if (_isMuted) {
      _youtubeController!.unMute();
      debugPrint('Unmuted');
    } else {
      _youtubeController!.mute();
      debugPrint('Muted');
    }

    setState(() {
      _isMuted = !_isMuted;
    });

    HapticFeedback.lightImpact();
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
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.bgApp,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Skeletonizer(
          enabled: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: Colors.white.withOpacity(0.1)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Bone.text(words: 3),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(4, (index) {
                          return Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(7),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(5, (index) {
                          return Container(
                            height: 24,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 16,
                        width: 60,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(height: 8),
                      Bone.multiText(lines: 4),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDialog(DetailMovieSuccessed state) {
    final movie = state.detailMovieModel.movie;
    final episodes = state.detailMovieModel.episodes;
    final hasTrailer = _youtubeVideoId != null && _youtubeController != null;

    debugPrint(
      '_buildDialog - hasTrailer: $hasTrailer, videoId: $_youtubeVideoId, controller: $_youtubeController',
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColor.bgApp,
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        alignment: Alignment.topCenter,
                        child: Text(
                          _cleanHtmlTags(movie.content),
                          maxLines: _isContentExpanded ? null : 4,
                          overflow: _isContentExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      if (_cleanHtmlTags(movie.content).length > 150)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isContentExpanded = !_isContentExpanded;
                              });
                            },
                            child: Text(
                              _isContentExpanded ? 'Thu gọn' : 'Xem thêm',
                              style: TextStyle(
                                color: AppColor.secondColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                    _buildActionButtons(state.detailMovieModel),
                  ],
                ),
              ),
            ],
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

    final bool showSkeleton = hasTrailer && !_isPlayerReady && !_isPlayerError;
    final bool showPlayer =
        hasTrailer && _youtubeController != null && !_isPlayerError;
    final bool showThumbnail = !hasTrailer || _isPlayerError;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                        setState(() {
                          _isPlayerReady = true;
                        });
                      }
                    },
                    bottomActions: [
                      CurrentPosition(),
                      ProgressBar(isExpanded: true),
                      RemainingDuration(),
                      PlaybackSpeedButton(),
                    ],
                  ),
                if (showSkeleton)
                  Skeletonizer(
                    enabled: true,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withOpacity(0.1),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!showPlayer)
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
        if (showPlayer) Positioned(top: 8, left: 8, child: _buildMuteButton()),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMuteButton() {
    return GestureDetector(
      onTap: _toggleMute,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isMuted ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

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
    return SizedBox(
      width: double.infinity,
      child: Wrap(
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
      ),
    );
  }

  Widget _buildActionButtons(DetailMovieModel detailModel) {
    final movie = detailModel.movie;
    final episodes = detailModel.episodes;
    final hasEpisodes =
        episodes.isNotEmpty && episodes[0].server_data.isNotEmpty;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (hasEpisodes) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  NoBackSwipeRoute(
                    builder: (_) => MoviePlayerPage(
                      slug: movie.slug,
                      movieName: movie.name,
                      thumbnailUrl: movie.poster_url,
                      episodes: episodes,
                      movie: movie,
                      initialServerIndex: 0,
                    ),
                  ),
                );
              } else {
                showAnimatedDialog(
                  context: context,
                  dialog: AppAlertDialog(
                    buttonTitle: 'Đóng',
                    content:
                        'Phim hiện chưa có tập để xem. Vui lòng thử lại sau nhé!',
                    title: 'Thông báo',
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasEpisodes
                      ? [
                          const Color(0xFFC77DFF), // Tím
                          const Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                          const Color(0xFFFFD275),
                        ]
                      : [Colors.grey, Colors.grey.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: hasEpisodes
                    ? [
                        BoxShadow(
                          color: Color(0xFFC77DFF),
                          blurRadius: 12,
                          offset: Offset(0, 0),
                          spreadRadius: -2,
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
              final position = _youtubeController?.value.position;
              Navigator.pop(context);
              AppNavigator.push(
                context,
                MovieDetailPage(
                  slug: movie.slug,
                  initialDetail: detailModel,
                  startAt: position,
                ),
              );
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
                  Icon(Iconsax.info_circle, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Chi tiết',
                    style: TextStyle(
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
}
