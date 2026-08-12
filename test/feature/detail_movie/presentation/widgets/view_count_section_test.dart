import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/detail_movie/presentation/widgets/view_count_section.dart';
import 'package:movie_app/feature/movie_engagement/data/movie_engagement_repository.dart';

void main() {
  testWidgets('shows API views and Supabase likes with compact formatting', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ViewCountSection(
            movie: _movie,
            repository: const _FakeEngagementRepository(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('20 lượt xem'), findsOneWidget);
    expect(find.text('12.5N lượt thích'), findsOneWidget);
  });

  test('formats Vietnamese compact counts', () {
    expect(formatCompactCount(999), '999');
    expect(formatCompactCount(1000), '1N');
    expect(formatCompactCount(1500000), '1.5Tr');
  });
}

class _FakeEngagementRepository implements MovieEngagementRepository {
  const _FakeEngagementRepository();

  @override
  Future<MovieEngagementMetrics> getMetrics(String movieSlug) async =>
      const MovieEngagementMetrics(viewCount: 1200000, likeCount: 12500);

  @override
  Future<List<RankedMovie>> getTopMovies({int limit = 30, String? movieType}) {
    throw UnimplementedError();
  }

  @override
  Future<List<RankedMovie>> getTopLikedMovies({int limit = 30}) {
    throw UnimplementedError();
  }

  @override
  Future<void> recordView(MovieModel movie) {
    throw UnimplementedError();
  }
}

final _movie = MovieModel(
  tmdb: null,
  imdb: null,
  created: null,
  modified: null,
  id: 'movie-1',
  name: 'Movie',
  slug: 'movie-1',
  origin_name: '',
  content: '',
  type: 'single',
  status: '',
  poster_url: '',
  thumb_url: '',
  is_copyright: false,
  sub_docquyen: false,
  chieurap: false,
  trailer_url: '',
  time: '',
  episode_current: 'Full',
  eposode_total: '',
  quality: 'HD',
  lang: 'Vietsub',
  notify: '',
  showtimes: '',
  year: 2026,
  view: 20,
  actor: const [],
  director: const [],
  category: const [],
  country: const [],
);
