import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/common/components/app_toast.dart';

void main() {
  testWidgets('shows the shared toast at the top with the expected style', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => AppToast.show(
                  context,
                  'Video không khả dụng',
                  duration: const Duration(seconds: 2),
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    final message = find.text('Video không khả dụng');
    expect(message, findsOneWidget);

    final text = tester.widget<Text>(message);
    expect(text.textAlign, TextAlign.center);
    expect(text.style?.color, Colors.white);
    expect(text.style?.fontSize, 16);

    final decoration = tester.widget<DecoratedBox>(
      find.ancestor(of: message, matching: find.byType(DecoratedBox)).first,
    );
    final boxDecoration = decoration.decoration as BoxDecoration;
    expect(boxDecoration.color, const Color(0xE66B747C));
    expect(boxDecoration.borderRadius, BorderRadius.circular(22));

    final toastCenter = tester.getCenter(message);
    expect(toastCenter.dy, lessThan(160));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(message, findsNothing);
  });
}
