import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class IosNowPlayingService {
  IosNowPlayingService._();

  static const MethodChannel _channel = MethodChannel('movie_player/pip');

  static bool get isSupportedPlatform => Platform.isIOS;

  static Future<void> configureSession() async {
    if (!isSupportedPlatform) return;

    try {
      await _channel.invokeMethod<void>('configureMediaSession');
    } catch (error) {
      debugPrint('[IosNowPlayingService] configure failed: $error');
    }
  }

  static Future<void> update({
    required String title,
    required String subtitle,
    required Duration duration,
    required Duration position,
    required bool isPlaying,
    String? assetUrl,
  }) async {
    if (!isSupportedPlatform) return;

    try {
      await _channel.invokeMethod<void>('updateNowPlaying', {
        'title': title,
        'subtitle': subtitle,
        'duration': duration.inMilliseconds / 1000.0,
        'position': position.inMilliseconds / 1000.0,
        'isPlaying': isPlaying,
        'assetUrl': assetUrl,
      });
    } catch (error) {
      debugPrint('[IosNowPlayingService] update failed: $error');
    }
  }

  static Future<void> clear() async {
    if (!isSupportedPlatform) return;

    try {
      await _channel.invokeMethod<void>('clearNowPlaying');
    } catch (error) {
      debugPrint('[IosNowPlayingService] clear failed: $error');
    }
  }
}
