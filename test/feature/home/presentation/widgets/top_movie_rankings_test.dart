import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/common/components/app_auto_scroll_text.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/home/presentation/widgets/top_movie_rankings.dart';
import 'package:movie_app/feature/movie_engagement/data/movie_engagement_repository.dart';
import 'package:stroke_text/stroke_text.dart';

void main() {
  testWidgets('renders view and liked movie rankings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TopMovieRankings(repository: _FakeRankingRepository()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Top Phim yêu thích'), findsOneWidget);
    expect(find.text('TOP 30 Phim Lẻ Hot'), findsOneWidget);
    expect(find.text('TOP 30 của Liquid Phim'), findsOneWidget);
    expect(find.text('THÍCH NHIỀU NHẤT'), findsOneWidget);
    expect(find.text('Phim tổng'), findsOneWidget);
    expect(find.text('Phim lẻ'), findsOneWidget);
    expect(find.text('Phim yêu thích'), findsOneWidget);
    expect(find.byType(AppAutoScrollText), findsWidgets);
    expect(find.byType(StrokeText), findsNWidgets(2));
    expect(find.text('Full HD'), findsNothing);
    expect(find.text('PĐ'), findsNWidgets(8));
    expect(find.text('T.1'), findsNWidgets(2));
    expect(find.byType(ClipPath), findsNWidgets(8));
    final renderedCards = tester.widgetList<InkWell>(find.byType(InkWell));
    expect(renderedCards, isNotEmpty);
    expect(renderedCards.every((widget) => widget.onLongPress != null), isTrue);

    // Cho delay của TextScroll chạy xong rồi tháo widget để không để lại timer
    // của animation trong môi trường test giả lập.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('gives two-digit ranks enough width to stay on one line', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(2400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TopMovieRankings(
              repository: _FakeRankingRepository(movieCount: 12),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final rankTen = find.byKey(const ValueKey('rank-number-10'));
    expect(rankTen, findsNWidgets(2));
    for (final element in rankTen.evaluate()) {
      expect((element.renderObject! as RenderBox).size.width, 68);
    }

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _FakeRankingRepository implements MovieEngagementRepository {
  const _FakeRankingRepository({this.movieCount = 4});

  final int movieCount;

  @override
  Future<MovieEngagementMetrics> getMetrics(String movieSlug) {
    throw UnimplementedError();
  }

  @override
  Future<List<RankedMovie>> getTopMovies({
    int limit = 30,
    String? movieType,
  }) async => List.generate(
    movieCount,
    (index) => RankedMovie(
      slug: '${movieType ?? 'overall'}-$index',
      name: index == 0
          ? movieType == null
                ? 'Phim tổng'
                : 'Phim lẻ'
          : 'Phim ${index + 1}',
      originName: 'Original title ${index + 1}',
      posterUrl: '',
      episodeCurrent: 'Tập ${index + 1}',
      quality: 'Full HD',
      lang: 'Vietsub',
      year: 2026,
      movieType: movieType ?? 'series',
      viewCount: 100 - index,
      likeCount: 20,
    ),
  );

  @override
  Future<List<RankedMovie>> getTopLikedMovies({int limit = 30}) async =>
      List.generate(
        4,
        (index) => RankedMovie(
          slug: 'liked-$index',
          name: index == 0 ? 'Phim yêu thích' : 'Phim thích ${index + 1}',
          originName: 'Liked original title ${index + 1}',
          posterUrl: '',
          thumbUrl: '',
          episodeCurrent: 'Tập ${index + 1}',
          quality: 'Full HD',
          lang: 'Vietsub',
          year: 2026,
          movieType: 'series',
          viewCount: 100 - index,
          likeCount: 40 - index,
        ),
      );

  @override
  Future<void> recordView(MovieModel movie) {
    throw UnimplementedError();
  }
}
