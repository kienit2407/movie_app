import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/audio/sound_effect_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.kinit.movieapp/ui_sfx');

  test('uses the native System Sound channel on iOS', () async {
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      messenger.setMockMethodCallHandler(channel, null);
    });

    final player = SoundEffectPlayerImpl();
    await player.initialize();
    await player.play(SoundEventType.reloadStart);
    await player.dispose();

    expect(calls.map((call) => call.method), ['initialize', 'play', 'dispose']);

    final initializeArguments = calls.first.arguments as Map<Object?, Object?>;
    final sounds = initializeArguments['sounds'] as Map<Object?, Object?>;
    expect(
      sounds,
      containsPair(
        SoundEventType.reloadStart.name,
        'assets/musics/sfx/reload_start.caf',
      ),
    );
    expect(
      sounds,
      containsPair(
        SoundEventType.reloadEnd.name,
        'assets/musics/sfx/reload_end.caf',
      ),
    );

    expect(calls[1].arguments, {'sound': SoundEventType.reloadStart.name});
  });
}
