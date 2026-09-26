import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum SoundEventType { reloadStart, reloadEnd }

extension SoundEventTypeExtension on SoundEventType {
  String get fileName {
    return switch (this) {
      SoundEventType.reloadStart => 'reload_start',
      SoundEventType.reloadEnd => 'reload_end',
    };
  }

  // AssetSource tự động thêm tiền tố "assets/".
  String get audioPoolAssetPath => 'musics/sfx/$fileName.mp3';

  String get iOSSystemSoundAssetPath => 'assets/musics/sfx/$fileName.caf';
}

abstract interface class SoundEffectPlayer {
  Future<void> initialize();

  Future<void> play(SoundEventType effectType);

  Future<void> dispose();
}

final class SoundEffectPlayerImpl implements SoundEffectPlayer {
  SoundEffectPlayerImpl({SoundEffectPlayer? delegate})
    : _delegate = delegate ?? _createPlatformPlayer();

  final SoundEffectPlayer _delegate;

  static SoundEffectPlayer _createPlatformPlayer() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return _IosSystemSoundEffectPlayer();
    }
    return _AudioPoolSoundEffectPlayer();
  }

  @override
  Future<void> initialize() => _delegate.initialize();

  @override
  Future<void> play(SoundEventType effectType) => _delegate.play(effectType);

  @override
  Future<void> dispose() => _delegate.dispose();
}

final class _IosSystemSoundEffectPlayer implements SoundEffectPlayer {
  static const MethodChannel _channel = MethodChannel(
    'com.kinit.movieapp/ui_sfx',
  );

  Future<void>? _initialization;
  Future<void> _operation = Future<void>.value();

  @override
  Future<void> initialize() {
    return _initialization ??= _channel.invokeMethod<void>('initialize', {
      'sounds': {
        for (final effectType in SoundEventType.values)
          effectType.name: effectType.iOSSystemSoundAssetPath,
      },
    });
  }

  @override
  Future<void> play(SoundEventType effectType) {
    _operation = _operation.then((_) async {
      try {
        await initialize();
        await _channel.invokeMethod<void>('play', {'sound': effectType.name});
      } catch (error, stackTrace) {
        // SFX là tính năng phụ, không được làm refresh thất bại.
        debugPrint('[SoundEffect][iOS] Failed to play $effectType: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });

    return _operation;
  }

  @override
  Future<void> dispose() async {
    await _operation;
    try {
      await _channel.invokeMethod<void>('dispose');
    } catch (error, stackTrace) {
      debugPrint('[SoundEffect][iOS] Failed to dispose: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

final class _AudioPoolSoundEffectPlayer implements SoundEffectPlayer {
  final Map<SoundEventType, AudioPool> _pools = {};

  Future<void>? _initialization;
  Future<void> _operation = Future<void>.value();
  StopFunction? _stopCurrentSound;

  // UI SFX không chiếm audio focus của phim/nhạc.
  final AudioContext _audioContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  @override
  Future<void> initialize() {
    return _initialization ??= _initializePools();
  }

  Future<void> _initializePools() async {
    final createdPools = <SoundEventType, AudioPool>{};

    try {
      for (final effectType in SoundEventType.values) {
        createdPools[effectType] = await AudioPool.create(
          source: AssetSource(effectType.audioPoolAssetPath),
          minPlayers: 1,
          maxPlayers: 1,
          playerMode: PlayerMode.lowLatency,
          audioContext: _audioContext,
        );
      }

      _pools.addAll(createdPools);
    } catch (_) {
      await Future.wait(createdPools.values.map((pool) => pool.dispose()));
      rethrow;
    }
  }

  @override
  Future<void> play(SoundEventType effectType) {
    _operation = _operation.then((_) async {
      try {
        await initialize();

        // Không cho reloadStart và reloadEnd phát chồng lên nhau.
        final stopCurrentSound = _stopCurrentSound;
        _stopCurrentSound = null;
        if (stopCurrentSound != null) {
          await stopCurrentSound();
        }

        _stopCurrentSound = await _pools[effectType]!.start(volume: 1);
      } catch (error, stackTrace) {
        // SFX là tính năng phụ, không được làm refresh thất bại.
        debugPrint('[SoundEffect] Failed to play $effectType: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });

    return _operation;
  }

  @override
  Future<void> dispose() async {
    await _operation;

    final stopCurrentSound = _stopCurrentSound;
    _stopCurrentSound = null;
    if (stopCurrentSound != null) {
      await stopCurrentSound();
    }

    await Future.wait(_pools.values.map((pool) => pool.dispose()));
    _pools.clear();
  }
}
