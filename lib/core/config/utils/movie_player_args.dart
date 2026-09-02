import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

class MoviePlayerArgs {
  final String slug;
  final String movieName;
  final String? thumbnailUrl;
  final List<EpisodesModel> episodes;
  final MovieModel movie;
  final String? initialEpisodeLink;
  final int initialEpisodeIndex;
  final String initialServer;
  final int initialServerIndex;
  final bool resumeFromHistory;
  final bool bypassSeriesResumePrompt;

  final int? initialEpisodeNo;
  final String? initialEpisodeSlug;
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
    this.initialServerIndex = 0,
    this.resumeFromHistory = true,
    this.bypassSeriesResumePrompt = false,
    this.initialEpisodeNo,
    this.initialEpisodeSlug,
    this.initialServerName,
  });

  bool get hasFullData => movie != null && episodes.isNotEmpty;

  MoviePlayerArgs copyWith({
    String? initialEpisodeLink,
    int? initialEpisodeIndex,
    String? initialServer,
    int? initialServerIndex,
    bool? resumeFromHistory,
    bool? bypassSeriesResumePrompt,
  }) => MoviePlayerArgs(
    slug,
    thumbnailUrl,
    initialEpisodeLink ?? this.initialEpisodeLink,
    initialEpisodeIndex ?? this.initialEpisodeIndex,
    initialServer ?? this.initialServer,
    movieName,
    episodes,
    movie,
    initialServerIndex: initialServerIndex ?? this.initialServerIndex,
    resumeFromHistory: resumeFromHistory ?? this.resumeFromHistory,
    bypassSeriesResumePrompt:
        bypassSeriesResumePrompt ?? this.bypassSeriesResumePrompt,
    initialEpisodeNo: initialEpisodeNo,
    initialEpisodeSlug: initialEpisodeSlug,
    initialServerName: initialServerName,
  );
}
