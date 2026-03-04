import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/widgets/movie_info_chip.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';

class MovieInfoChips extends StatelessWidget {
  final MovieModel movie;

  const MovieInfoChips({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        MovieInfoChip(
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
        MovieInfoChip(
          isGradient: true,
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
        MovieInfoChip(
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
          MovieInfoChip(
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
          MovieInfoChip(
            isGradient: true,
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
          MovieInfoChip(
            isGradient: true,
            child: const Text(
              'Sub Độc Quyền',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        MovieInfoChip(
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
        MovieInfoChip(
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
}
