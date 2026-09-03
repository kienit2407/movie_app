import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';

class MovieExtraInfo extends StatelessWidget {
  final MovieModel movie;

  const MovieExtraInfo({super.key, required this.movie});

  String _directorName(BuildContext context) {
    if (movie.director != null && movie.director!.isNotEmpty) {
      return movie.director!.map((d) => d.toString()).join(', ');
    }
    return context.l10n.commonUpdating;
  }

  String _releaseDate(BuildContext context) {
    final dateValue = movie.created?.time;
    return DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(dateValue ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
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
                  url: movie.thumb_url,
                  fit: BoxFit.cover,
                  cacheWidth: 1080,
                  cacheHeight: 720,
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        color: AppColor.bgApp.withOpacity(.1),
                        border: Border(
                          top: BorderSide(color: Colors.grey.withOpacity(.5)),
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 180,
                              width: 120,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: FastCachedImage(
                                  url: movie.poster_url,
                                  fit: BoxFit.cover,
                                  cacheWidth: 600,
                                  cacheHeight: 900,
                                  loadingBuilder: (context, loadingProgress) {
                                    return _buildSkeletonForPoster();
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildSkeletonForPoster();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
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
                        decoration: BoxDecoration(
                          color: AppColor.bgApp.withOpacity(.3),
                          border: Border(
                            top: BorderSide(color: Colors.grey.withOpacity(.5)),
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            topLeft: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBullet(
                              _directorName(context),
                              context.l10n.detailDirectorLabel,
                            ),
                            const SizedBox(height: 8),
                            _buildBullet(
                              _releaseDate(context),
                              context.l10n.detailCreatedDateLabel,
                            ),
                            const SizedBox(height: 8),
                            _buildBullet(
                              movie.year.toString(),
                              context.l10n.detailProductionYearLabel,
                            ),
                            const SizedBox(height: 8),
                            _buildBullet(
                              movie.country[0].name,
                              context.l10n.detailCountryLabel,
                            ),
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

  Widget _buildSkeletonForPoster() {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Shimmer.fromColors(
        baseColor: const Color(0xff272A39),
        highlightColor: const Color(0xff4A4E69),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonForThumbnail() {
    return Shimmer.fromColors(
      baseColor: const Color(0xff272A39),
      highlightColor: const Color(0xff4A4E69),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBullet(String content, String title) => Row(
    children: [
      Text(
        '$title ',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
      Expanded(
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    ],
  );
}
