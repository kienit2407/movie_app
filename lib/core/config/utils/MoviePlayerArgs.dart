import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

class MoviePlayerArgs {
  // final String slug;

  // nếu đi từ Detail (đã có đủ)
  final String slug;
  final String movieName;
  final String? thumbnailUrl;
  final List<EpisodesModel> episodes;
  final MovieModel movie;
  final String? initialEpisodeLink;
  final int initialEpisodeIndex;
  final String initialServer;

  // nếu đi từ Home (chỉ có ít)
  final int? initialEpisodeNo; // vd 23
  final String? initialEpisodeSlug; // vd tap-23
  final String? initialServerName;

  const MoviePlayerArgs(
    this.slug,
    this.thumbnailUrl,
    this.initialEpisodeLink,
    this.initialEpisodeIndex,
    this.initialServer,
    this.movieName,
    this.episodes,
    this.movie, {

    this.initialEpisodeNo,
    this.initialEpisodeSlug,
    this.initialServerName,
  });

  bool get hasFullData =>
      movie != null && episodes != null && episodes!.isNotEmpty;
}
