import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/library/presentation/widgets/library_movie_card.dart';

void main() {
  test('starts a new date group only when the local calendar day changes', () {
    final march19Morning = DateTime(2026, 3, 19, 8);
    final march19Night = DateTime(2026, 3, 19, 23);
    final march18 = DateTime(2026, 3, 18, 23);

    expect(startsNewLibraryDateGroup(march19Morning, null), isTrue);
    expect(startsNewLibraryDateGroup(march19Night, march19Morning), isFalse);
    expect(startsNewLibraryDateGroup(march18, march19Night), isTrue);
  });

  testWidgets('shows the library activity day and month on the poster', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            height: 280,
            child: LibraryMovieCard(
              slug: 'movie-slug',
              name: 'Tên phim',
              originName: 'Movie name',
              posterUrl: '',
              episodeCurrent: 'Tập 1',
              quality: 'HD',
              lang: 'Vietsub',
              year: 2026,
              activityDate: DateTime(2026, 8, 19),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('library-date-badge')), findsOneWidget);
    expect(find.text('19'), findsOneWidget);
    expect(find.text('tháng 8'), findsOneWidget);
  });

  testWidgets('hides the date badge for another movie from the same day', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            height: 280,
            child: LibraryMovieCard(
              slug: 'same-day-movie',
              name: 'Phim cùng ngày',
              originName: 'Same day movie',
              posterUrl: '',
              episodeCurrent: 'Tập 1',
              quality: 'HD',
              lang: 'Vietsub',
              year: 2026,
              activityDate: DateTime(2026, 8, 19),
              showDateBadge: false,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('library-date-badge')), findsNothing);
    expect(find.text('19'), findsNothing);
    expect(find.text('tháng 8'), findsNothing);
  });

  testWidgets('draws only the watched fraction without a full progress track', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            height: 280,
            child: LibraryMovieCard(
              slug: 'low-progress-movie',
              name: 'Phim mới xem',
              originName: 'Low progress movie',
              posterUrl: '',
              episodeCurrent: 'Tập 1',
              quality: 'HD',
              lang: 'Vietsub',
              year: 2026,
              activityDate: DateTime(2026, 8, 19),
              progress: .01,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsNothing);
    final fillSize = tester.getSize(
      find.byKey(const ValueKey('library-progress-fill')),
    );
    expect(fillSize.width, 2);
    expect(fillSize.height, 3);
  });
}
