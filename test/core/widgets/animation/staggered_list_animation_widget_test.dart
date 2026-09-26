import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/widgets/animation/staggered_list_animation_no_pop_widget.dart';
import 'package:movie_app/core/widgets/animation/staggered_list_animation_widget.dart';

void main() {
  testWidgets('waits for the index delay before starting the animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StaggeredListAnimationWidget(
          index: 2,
          baseDelay: Duration(milliseconds: 200),
          staggerDelay: Duration(milliseconds: 50),
          child: Text('Notification'),
        ),
      ),
    );

    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);

    await tester.pump(const Duration(milliseconds: 99));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);

    await tester.pump(const Duration(milliseconds: 1));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<Opacity>(find.byType(Opacity)).opacity,
      greaterThan(0),
    );
  });

  testWidgets('shows content immediately when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: StaggeredListAnimationWidget(
            index: 8,
            child: Text('Notification'),
          ),
        ),
      ),
    );

    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
  });

  testWidgets('NoPop shows an already animated item immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StaggeredListAnimationNoPopWidget(
          index: 8,
          shouldAnimate: false,
          child: Text('Notification'),
        ),
      ),
    );

    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
  });
}
