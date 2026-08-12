import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MovieEngagementMetrics {
  const MovieEngagementMetrics({
    required this.viewCount,
    required this.likeCount,
    this.updatedAt,
  });

  final int viewCount;
  final int likeCount;
  final DateTime? updatedAt;

  factory MovieEngagementMetrics.fromMap(Map<String, dynamic> map) =>
      MovieEngagementMetrics(
        viewCount: (map['view_count'] as num?)?.toInt() ?? 0,
        likeCount: (map['like_count'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(
          map['updated_at']?.toString() ?? '',
        )?.toLocal(),
      );
}

class RankedMovie {
  const RankedMovie({
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    this.thumbUrl = '',
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    required this.movieType,
    required this.viewCount,
    required this.likeCount,
  });

  final String slug;
  final String name;
  final String originName;
  final String posterUrl;
  final String thumbUrl;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final int year;
  final String movieType;
  final int viewCount;
  final int likeCount;

  factory RankedMovie.fromMap(Map<String, dynamic> map) => RankedMovie(
    slug: map['movie_slug']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    originName: map['origin_name']?.toString() ?? '',
    posterUrl: map['poster_url']?.toString() ?? '',
    thumbUrl: map['thumb_url']?.toString() ?? '',
    episodeCurrent: map['episode_current']?.toString() ?? '',
    quality: map['quality']?.toString() ?? '',
    lang: map['lang']?.toString() ?? '',
    year: (map['year'] as num?)?.toInt() ?? 0,
    movieType: map['movie_type']?.toString() ?? '',
    viewCount: (map['view_count'] as num?)?.toInt() ?? 0,
    likeCount: (map['like_count'] as num?)?.toInt() ?? 0,
  );
}

abstract interface class MovieEngagementRepository {
  Future<MovieEngagementMetrics> getMetrics(String movieSlug);

  Future<List<RankedMovie>> getTopMovies({int limit = 30, String? movieType});

  Future<List<RankedMovie>> getTopLikedMovies({int limit = 30});

  Future<void> recordView(MovieModel movie);
}

class SupabaseMovieEngagementRepository implements MovieEngagementRepository {
  SupabaseMovieEngagementRepository({SupabaseClient? client})
    : _providedClient = client;

  final SupabaseClient? _providedClient;

  SupabaseClient get _client => _providedClient ?? Supabase.instance.client;

  @override
  Future<MovieEngagementMetrics> getMetrics(String movieSlug) async {
    final response = await _client
        .from('movie_engagement')
        .select('view_count, like_count, updated_at')
        .eq('movie_slug', movieSlug)
        .maybeSingle();
    if (response == null) {
      return const MovieEngagementMetrics(viewCount: 0, likeCount: 0);
    }
    return MovieEngagementMetrics.fromMap(response);
  }

  @override
  Future<List<RankedMovie>> getTopMovies({
    int limit = 30,
    String? movieType,
  }) async {
    final rows = movieType == null
        ? await _client
              .from('movie_engagement')
              .select()
              .order('view_count', ascending: false)
              .order('like_count', ascending: false)
              .limit(limit)
        : await _client
              .from('movie_engagement')
              .select()
              .eq('movie_type', movieType)
              .order('view_count', ascending: false)
              .order('like_count', ascending: false)
              .limit(limit);
    return rows
        .map((row) => RankedMovie.fromMap(row))
        .where((movie) => movie.slug.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<RankedMovie>> getTopLikedMovies({int limit = 30}) async {
    final rows = await _client
        .from('movie_engagement')
        .select()
        .gt('like_count', 0)
        .order('like_count', ascending: false)
        .order('view_count', ascending: false)
        .limit(limit);
    return rows
        .map((row) => RankedMovie.fromMap(row))
        .where((movie) => movie.slug.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> recordView(MovieModel movie) => _client.rpc<void>(
    'record_movie_view',
    params: {
      'p_movie_slug': movie.slug,
      'p_name': movie.name,
      'p_origin_name': movie.origin_name,
      'p_poster_url': movie.poster_url,
      'p_thumb_url': movie.thumb_url,
      'p_episode_current': movie.episode_current,
      'p_quality': movie.quality,
      'p_lang': movie.lang,
      'p_year': movie.year,
      'p_movie_type': movie.type,
    },
  );
}
