import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/storage/app_cache_service.dart';

void main() {
  test('returns zero when the image cache has not been initialized', () async {
    const service = AppCacheService();

    expect(await service.getImageCacheSizeBytes(), 0);
  });

  group('formatBytes', () {
    test('formats bytes and binary units', () {
      expect(formatBytes(0), '0 B');
      expect(formatBytes(1024), '1.0 KB');
      expect(formatBytes(1024 * 1024), '1.0 MB');
      expect(formatBytes(1536 * 1024), '1.5 MB');
      expect(formatBytes(2 * 1024 * 1024 * 1024), '2.0 GB');
    });

    test('clamps negative values to zero', () {
      expect(formatBytes(-1), '0 B');
    });
  });
}
