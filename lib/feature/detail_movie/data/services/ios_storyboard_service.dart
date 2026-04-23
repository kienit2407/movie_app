import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class IosStoryboardService {
  IosStoryboardService._();

  static final IosStoryboardService instance = IosStoryboardService._();

  static const MethodChannel _channel = MethodChannel(
    'movie_player/storyboard',
  );

  final Map<String, String?> _memoryCache = {};
  final Map<String, Future<String?>> _inflight = {};

  Future<String?> getThumbnailForPosition({
    required String videoUrl,
    required Duration position,
    int stepMs = 10000,
    int maxWidth = 160,
    int maxHeight = 90,
  }) async {
    if (!Platform.isIOS) return null;

    final bucketMs = _bucketize(position.inMilliseconds, stepMs);
    final key = _cacheKey(
      videoUrl: videoUrl,
      bucketMs: bucketMs,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    final cached = _memoryCache[key];
    if (cached != null && File(cached).existsSync()) {
      return cached;
    }

    final running = _inflight[key];
    if (running != null) {
      return running;
    }

    final future = _fetchNative(
      videoUrl: videoUrl,
      bucketMs: bucketMs,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    _inflight[key] = future;

    final result = await future;
    _inflight.remove(key);

    if (result != null) {
      _memoryCache[key] = result;
    }

    return result;
  }

  Future<String?> _fetchNative({
    required String videoUrl,
    required int bucketMs,
    required int maxWidth,
    required int maxHeight,
  }) async {
    try {
      final path = await _channel.invokeMethod<String>('thumbnailAt', {
        'url': videoUrl,
        'timeMs': bucketMs,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      });

      return path;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[IOS Storyboard] ${e.code}: ${e.message}');
      return null;
    }
  }

  int _bucketize(int ms, int stepMs) {
    if (stepMs <= 0) return ms;
    return (ms ~/ stepMs) * stepMs;
  }

  String _cacheKey({
    required String videoUrl,
    required int bucketMs,
    required int maxWidth,
    required int maxHeight,
  }) {
    return '${videoUrl.hashCode}_${bucketMs}_${maxWidth}x${maxHeight}';
  }

  void clearMemoryCache() {
    _memoryCache.clear();
  }
}