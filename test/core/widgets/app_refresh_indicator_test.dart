import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/audio/sound_effect_player.dart';
import 'package:movie_app/core/widgets/app_refresh_indicator.dart';

void main() {
  testWidgets('plays reload sounds around the actual refresh future', (
    tester,
  ) async {
    final refreshCompleter = Completer<void>();
    final soundEffectPlayer = _FakeSoundEffectPlayer();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppRefreshIndicator(
            soundEffectPlayer: soundEffectPlayer,
            edgeOffset: 120,
            displacement: 16,
            onRefresh: () => refreshCompleter.future,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 1000)],
            ),
          ),
        ),
      ),
    );

    final refreshIndicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    expect(refreshIndicator.edgeOffset, 120);
    expect(refreshIndicator.displacement, 16);

    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final progressIndicator = find.byType(RefreshProgressIndicator);
    expect(progressIndicator, findsOneWidget);
    expect(tester.getTopLeft(progressIndicator).dy, greaterThan(120));
    expect(soundEffectPlayer.played, [SoundEventType.reloadStart]);

    refreshCompleter.complete();
    await tester.pumpAndSettle();

    expect(soundEffectPlayer.played, [
      SoundEventType.reloadStart,
      SoundEventType.reloadEnd,
    ]);
  });
}

final class _FakeSoundEffectPlayer implements SoundEffectPlayer {
  final List<SoundEventType> played = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> play(SoundEventType effectType) async {
    played.add(effectType);
  }

  @override
  Future<void> dispose() async {}
}
