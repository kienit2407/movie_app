import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/common/components/app_auto_scroll_text.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/episode_map.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/core/config/utils/show_detail_movie_dialog.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/feature/detail_movie/presentation/widgets/view_count_section.dart';
import 'package:movie_app/feature/movie_engagement/data/movie_engagement_repository.dart';
import 'package:stroke_text/stroke_text.dart';

class TopMovieRankings extends StatefulWidget {
  const TopMovieRankings({
    super.key,
    this.refreshGeneration = 0,
    this.repository,
  });

  final int refreshGeneration;
  final MovieEngagementRepository? repository;

  @override
  State<TopMovieRankings> createState() => _TopMovieRankingsState();
}

class _TopMovieRankingsState extends State<TopMovieRankings> {
  late final MovieEngagementRepository _repository;
  late Future<_RankingsData> _future;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseMovieEngagementRepository();
    _future = _load();
  }

  @override
  void didUpdateWidget(TopMovieRankings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshGeneration != widget.refreshGeneration) {
      _future = _load();
    }
  }

  Future<_RankingsData> _load() async {
    final values = await Future.wait([
      _repository.getTopMovies(),
      _repository.getTopMovies(movieType: 'single'),
      _repository.getTopLikedMovies(),
    ]);
    return _RankingsData(
      overall: values[0],
      single: values[1],
      liked: values[2],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RankingsData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LikedRankingSection(
              title: context.l10n.rankingTopFavorites,
              items: data?.liked ?? const [],
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              hasError: snapshot.hasError,
            ),
            const SizedBox(height: 28),
            _RankingSection(
              title: context.l10n.rankingTopLiquidPhim,
              items: data?.overall ?? const [],
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              hasError: snapshot.hasError,
            ),
            const SizedBox(height: 28),
            _RankingSection(
              title: context.l10n.rankingTopHotMovies,
              items: data?.single ?? const [],
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              hasError: snapshot.hasError,
            ),
          ],
        );
      },
    );
  }
}

class _RankingSection extends StatelessWidget {
  const _RankingSection({
    required this.title,
    required this.items,
    required this.isLoading,
    required this.hasError,
  });

  final String title;
  final List<RankedMovie> items;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RankingHeader(title: title, subtitle: context.l10n.rankingMostViewed),
        const SizedBox(height: 14),
        SizedBox(
          height: 290,
          child: isLoading
              ? const _RankingSkeleton()
              : items.isEmpty
              ? _EmptyRanking(hasError: hasError)
              : ListView.separated(
                  key: PageStorageKey<String>('ranking-$title'),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 0),
                  itemBuilder: (context, index) => _RankingMovieCard(
                    key: ValueKey('$title-${items[index].slug}'),
                    rank: index + 1,
                    movie: items[index],
                  ),
                ),
        ),
      ],
    );
  }
}

class _LikedRankingSection extends StatelessWidget {
  const _LikedRankingSection({
    required this.title,
    required this.items,
    required this.isLoading,
    required this.hasError,
  });

  final String title;
  final List<RankedMovie> items;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RankingHeader(title: title, subtitle: context.l10n.rankingMostLiked),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: isLoading
              ? const _LikedRankingSkeleton()
              : items.isEmpty
              ? _EmptyRanking(
                  hasError: hasError,
                  emptyMessage: context.l10n.rankingEmptyLikes,
                )
              : ListView.separated(
                  key: PageStorageKey<String>('ranking-liked-$title'),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _LikedMovieCard(
                    key: ValueKey('liked-${items[index].slug}'),
                    movie: items[index],
                  ),
                ),
        ),
      ],
    );
  }
}

class _RankingHeader extends StatelessWidget {
  const _RankingHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Flexible(
            child: SharderText(
              gradient: const LinearGradient(
                colors: [
                  Color(0xffFEFBF3),
                  Color(0xffFCD697),
                  Color(0xffF9BD56),
                ],
              ),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 20, color: Colors.white24),
          const SizedBox(width: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingMovieCard extends StatelessWidget {
  const _RankingMovieCard({super.key, required this.rank, required this.movie});

  final int rank;
  final RankedMovie movie;

  @override
  Widget build(BuildContext context) {
    final langTags = movie.lang.toMediaTags();
    final episode = movie.episodeCurrent.trim();
    final hasTwoDigits = rank >= 10;
    final rankWidth = hasTwoDigits ? 68.0 : 42.0;
    final rankFontSize = hasTwoDigits ? 42.0 : 46.0;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (136 * pixelRatio).round().clamp(1, 600);
    final cacheHeight = (204 * pixelRatio).round().clamp(1, 900);
    return SizedBox(
      width: 170,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          AppRoutes.movieDetail.replaceAll(
            ':slug',
            Uri.encodeComponent(movie.slug),
          ),
        ),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showAnimatedDialog<void>(
            context: context,
            dialog: ShowDetailMovieDialog(slug: movie.slug),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 204,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 22,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: ClipPath(
                      clipBehavior: Clip.antiAlias,
                      clipper: _SlantedPosterClipper(
                        slopesDownToRight: rank.isOdd,
                      ),
                      child: movie.posterUrl.isEmpty
                          ? const ColoredBox(
                              color: Color(0xff292B38),
                              child: Icon(Icons.movie_outlined),
                            )
                          : FastCachedImage(
                              url: movie.posterUrl,
                              fit: BoxFit.cover,
                              cacheWidth: cacheWidth,
                              cacheHeight: cacheHeight,
                              fadeInDuration: const Duration(milliseconds: 120),
                            ),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    right: 4,
                    bottom: 5,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final tag in langTags)
                          _RankingChip(text: tag.label, color: tag.color),
                        if (episode.isNotEmpty &&
                            episode.toLowerCase() != 'full')
                          _RankingChip(
                            text: EpisodeFormatter.toShort(episode),
                            color: Colors.redAccent,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  key: ValueKey('rank-number-$rank'),
                  width: rankWidth,
                  height: 52,
                  child: rank <= 3
                      ? Text(
                          '$rank',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: const Color(0xffE5C07B),
                            height: .95,
                            fontSize: rankFontSize,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            shadows: const [
                              Shadow(
                                color: Color(0xffE5C07B),
                                offset: Offset.zero,
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        )
                      : StrokeText(
                          text: '$rank',
                          textAlign: TextAlign.center,
                          strokeColor: const Color(0xffE5C07B),
                          strokeWidth: 1.6,
                          textStyle: TextStyle(
                            color: Colors.transparent,
                            height: .95,
                            fontSize: rankFontSize,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAutoScrollText(
                        movie.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AppAutoScrollText(
                        movie.originName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AppAutoScrollText(
                        [
                          // Thêm điều kiện khác 'full' (không phân biệt hoa/thường)
                          if (movie.episodeCurrent.isNotEmpty &&
                              movie.episodeCurrent.toLowerCase() != 'full')
                            movie.episodeCurrent,
                          context.l10n.detailViews(
                            formatCompactCount(movie.viewCount),
                          ),
                        ].join(' • '),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LikedMovieCard extends StatelessWidget {
  const _LikedMovieCard({super.key, required this.movie});

  final RankedMovie movie;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final backdropUrl = movie.thumbUrl.isNotEmpty
        ? movie.thumbUrl
        : movie.posterUrl;
    final backdropCacheWidth = (310 * pixelRatio).round().clamp(1, 1000);
    final backdropCacheHeight = (145 * pixelRatio).round().clamp(1, 600);
    final posterCacheWidth = (78 * pixelRatio).round().clamp(1, 400);
    final posterCacheHeight = (118 * pixelRatio).round().clamp(1, 600);
    final langLabel = movie.lang
        .toMediaTags()
        .map((tag) => tag.label)
        .join('+');
    final episode = movie.episodeCurrent.trim();
    final posterBadge = [
      if (langLabel.isNotEmpty) langLabel,
      if (episode.isNotEmpty) EpisodeFormatter.toShort(episode),
    ].join('. ');

    return SizedBox(
      width: 310,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          AppRoutes.movieDetail.replaceAll(
            ':slug',
            Uri.encodeComponent(movie.slug),
          ),
        ),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showAnimatedDialog<void>(
            context: context,
            dialog: ShowDetailMovieDialog(slug: movie.slug),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 145,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Color(0xff414444).withOpacity(.6),
                    width: .5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (backdropUrl.isEmpty)
                          const ColoredBox(color: Color(0xff292B38))
                        else
                          FastCachedImage(
                            url: backdropUrl,
                            fit: BoxFit.cover,
                            cacheWidth: backdropCacheWidth,
                            cacheHeight: backdropCacheHeight,
                            fadeInDuration: const Duration(milliseconds: 120),
                          ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xcc10111A)],
                              stops: [.48, 1],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //phần poster và thông tin phim
            Positioned(
              left: 14,
              top: 88,
              width: 90,
              height: 126,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xff10111A),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: Color(0xff414444).withOpacity(.6),
                    width: .5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 14,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (movie.posterUrl.isEmpty)
                          const ColoredBox(
                            color: Color(0xff292B38),
                            child: Icon(Icons.movie_outlined, size: 22),
                          )
                        else
                          FastCachedImage(
                            url: movie.posterUrl,
                            fit: BoxFit.cover,
                            cacheWidth: posterCacheWidth,
                            cacheHeight: posterCacheHeight,
                            fadeInDuration: const Duration(milliseconds: 120),
                          ),
                        if (posterBadge.isNotEmpty)
                          Positioned(
                            left: 5,
                            right: 5,
                            bottom: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: .82),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                posterBadge,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 110,
              right: 10,
              top: 151,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAutoScrollText(
                    movie.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppAutoScrollText(
                    movie.originName,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 7),
                  AppAutoScrollText(
                    [
                      if (movie.year > 0) '${movie.year}',
                      context.l10n.detailLikes(
                        formatCompactCount(movie.likeCount),
                      ),
                    ].join(' • '),
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingChip extends StatelessWidget {
  const _RankingChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SlantedPosterClipper extends CustomClipper<Path> {
  const _SlantedPosterClipper({required this.slopesDownToRight});

  final bool slopesDownToRight;

  @override
  Path getClip(Size size) {
    const slant = 11.0;
    const radius = 13.0;
    final leftTop = slopesDownToRight ? 0.0 : slant;
    final rightTop = slopesDownToRight ? slant : 0.0;

    return Path()
      ..moveTo(radius, leftTop)
      ..lineTo(size.width - radius, rightTop)
      ..quadraticBezierTo(size.width, rightTop, size.width, rightTop + radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, leftTop + radius)
      ..quadraticBezierTo(0, leftTop, radius, leftTop)
      ..close();
  }

  @override
  bool shouldReclip(covariant _SlantedPosterClipper oldClipper) =>
      oldClipper.slopesDownToRight != slopesDownToRight;
}

class _RankingSkeleton extends StatelessWidget {
  const _RankingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, _) => Container(
        width: 166,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .055),
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }
}

class _LikedRankingSkeleton extends StatelessWidget {
  const _LikedRankingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, _) => SizedBox(
        width: 310,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 145,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .055),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 88,
              width: 78,
              height: 122,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xff292B38),
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRanking extends StatelessWidget {
  const _EmptyRanking({required this.hasError, this.emptyMessage});

  final bool hasError;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        hasError
            ? context.l10n.rankingLoadFailed
            : emptyMessage ?? context.l10n.rankingEmptyViews,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}

class _RankingsData {
  const _RankingsData({
    required this.overall,
    required this.single,
    required this.liked,
  });

  final List<RankedMovie> overall;
  final List<RankedMovie> single;
  final List<RankedMovie> liked;
}
