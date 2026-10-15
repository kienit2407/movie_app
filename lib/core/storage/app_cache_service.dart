import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

final class AppCacheService {
  const AppCacheService();

  static const MethodChannel _storageChannel = MethodChannel(
    'com.kinit.movieapp/app_storage',
  );
  static const String _imageBoxName = 'cachedImages';
  static const String _imageKeyBoxName = 'cachedImagesKeys';

  /// Returns all data created by the app, including preferences, databases,
  /// downloaded files and cache. The installed app binary is not included.
  Future<int> getAppDataSizeBytes() async {
    final bytes = await _storageChannel.invokeMethod<int>(
      'getAppDataSizeBytes',
    );
    return bytes == null || bytes < 0 ? 0 : bytes;
  }

  /// Returns the on-disk size of the image cache managed by
  /// [FastCachedImageConfig].
  Future<int> getImageCacheSizeBytes() async {
    if (!Hive.isBoxOpen(_imageBoxName)) return 0;

    final imageBox = Hive.lazyBox<dynamic>(_imageBoxName);
    if (imageBox.isEmpty) return 0;

    final imageBoxBytes = await _getLazyBoxFileSize(_imageBoxName);
    final imageKeyBoxBytes = await _getLazyBoxFileSize(_imageKeyBoxName);
    return imageBoxBytes + imageKeyBoxBytes;
  }

  Future<void> clearImageCache() {
    return FastCachedImageConfig.clearAllCachedImages(showLog: false);
  }

  Future<int> _getLazyBoxFileSize(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) return 0;

    final path = Hive.lazyBox<dynamic>(boxName).path;
    if (path == null) return 0;

    final file = File(path);
    try {
      return await file.exists() ? await file.length() : 0;
    } on FileSystemException {
      return 0;
    }
  }
}

String formatBytes(int bytes) {
  const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes < 0 ? 0.0 : bytes.toDouble();
  var unitIndex = 0;

  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }

  if (unitIndex == 0) return '${value.round()} ${units[unitIndex]}';
  return '${value.toStringAsFixed(1)} ${units[unitIndex]}';
}
