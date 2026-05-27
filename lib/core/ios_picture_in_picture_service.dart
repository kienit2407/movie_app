import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class IosPictureInPictureService {
  IosPictureInPictureService._();

  static const MethodChannel _channel = MethodChannel('movie_player/pip');

  static bool get isSupportedPlatform => Platform.isIOS;

  static Future<bool> isAvailable() async {
    if (!isSupportedPlatform) return false;
    return await _channel.invokeMethod<bool>('isAvailable') ?? false;
  }

  static Future<bool> attach(VideoPlayerController controller) async {
    if (!isSupportedPlatform || !controller.value.isInitialized) return false;
    return await _channel.invokeMethod<bool>('attach') ?? false;
  }

  static Future<bool> start() async {
    if (!isSupportedPlatform) return false;
    return await _channel.invokeMethod<bool>('start') ?? false;
  }

  static Future<void> stop() async {
    if (!isSupportedPlatform) return;
    await _channel.invokeMethod<void>('stop');
  }

  static Future<void> detach() async {
    if (!isSupportedPlatform) return;
    await _channel.invokeMethod<void>('detach');
  }
}
