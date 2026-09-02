import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/common/components/app_toast.dart';

void main() {
  testWidgets('shows the shared toast with the expected style', (tester) async {
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
    expect(boxDecoration.color, Colors.black.withValues(alpha: .5));
    expect(boxDecoration.borderRadius, BorderRadius.circular(22));

    final toastCenter = tester.getCenter(message);
    expect(toastCenter.dy, closeTo(300, 40));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(message, findsNothing);
  });

  testWidgets('does not block taps on content behind the toast', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 80,
                  right: 80,
                  child: FilledButton(
                    key: const ValueKey('button-behind-toast'),
                    onPressed: () => tapCount++,
                    child: const Text('Nút phía sau'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FilledButton(
                    onPressed: () => AppToast.show(
                      context,
                      'Thông báo vẫn cho phép thao tác',
                      duration: const Duration(seconds: 2),
                    ),
                    child: const Text('Hiện toast'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Hiện toast'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Thông báo vẫn cho phép thao tác'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('button-behind-toast')));
    await tester.pump();
    expect(tapCount, 1);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
