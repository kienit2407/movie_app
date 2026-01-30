import 'package:dio/dio.dart';

/// Model đại diện cho một stream trong file M3U8
class HlsStream {
  final String url;
  final String? resolution;
  final int? bandwidth;

  HlsStream({
    required this.url,
    this.resolution,
    this.bandwidth,
  });

  @override
  String toString() => 'HlsStream(url: $url, resolution: $resolution, bandwidth: $bandwidth)';
}

/// Helper để parse M3U8 và kiểm tra có nhiều streams không
class HlsHelper {
  /// Parse M3U8 file và trả về danh sách streams
  static Future<List<HlsStream>> parseM3U8(String m3u8Url) async {
    try {
      final dio = Dio();
      final response = await dio.get(m3u8Url);
      
      if (response.statusCode != 200) {
        return [];
      }

      final content = response.data as String;
      final streams = <HlsStream>[];
      
      // Parse M3U8 format
      final lines = content.split('\n');
      String? currentStreamUrl;
      String? currentResolution;
      int? currentBandwidth;
      
      for (final line in lines) {
        final trimmed = line.trim();
        
        // Bỏ qua dòng comment hoặc trống
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          // Parse stream info
          if (trimmed.startsWith('#EXT-X-STREAM-INF')) {
            currentResolution = _extractResolution(trimmed);
            currentBandwidth = _extractBandwidth(trimmed);
          }
          continue;
        }
        
        // URL của stream
        if (!trimmed.startsWith('#')) {
          currentStreamUrl = trimmed;
          
          // Xử lý URL relative
          if (!currentStreamUrl!.startsWith('http')) {
            final uri = Uri.parse(m3u8Url);
            currentStreamUrl = '${uri.scheme}://${uri.host}${currentStreamUrl.startsWith('/') ? '' : '/'}$currentStreamUrl';
          }
          
          // Thêm vào danh sách nếu có thông tin
          if (currentResolution != null || currentBandwidth != null) {
            streams.add(HlsStream(
              url: currentStreamUrl!,
              resolution: currentResolution,
              bandwidth: currentBandwidth,
            ));
          }
          
          // Reset cho stream tiếp theo
          currentStreamUrl = null;
          currentResolution = null;
          currentBandwidth = null;
        }
      }
      
      return streams;
    } catch (e) {
      print('Error parsing M3U8: $e');
      return [];
    }
  }

  /// Kiểm tra M3U8 có hỗ trợ multiple streams không
  static Future<bool> hasMultipleStreams(String m3u8Url) async {
    final streams = await parseM3U8(m3u8Url);
    return streams.length > 1;
  }

  /// Lấy streams và map với quality strings (480p, 720p, 1080p, 4K)
  static Future<Map<String, String>> getQualityUrls(String m3u8Url) async {
    final streams = await parseM3U8(m3u8Url);
    final qualityUrls = <String, String>{};
    
    for (final stream in streams) {
      final quality = _normalizeQuality(stream.resolution, stream.bandwidth);
      if (quality != null) {
        qualityUrls[quality] = stream.url;
      }
    }
    
    return qualityUrls;
  }

  static String? _normalizeQuality(String? resolution, int? bandwidth) {
    // Chuẩn hóa resolution thành quality string
    if (resolution == null && bandwidth == null) return null;
    
    // Từ resolution (ví dụ: 1920x1080 -> 1080p)
    if (resolution != null) {
      final parts = resolution.toLowerCase().split('x');
      if (parts.length == 2) {
        try {
          final height = int.parse(parts[1]);
          if (height >= 2160) return '4K';
          if (height >= 1080) return '1080p';
          if (height >= 720) return '720p';
          if (height >= 480) return '480p';
        } catch (e) {
          // Ignore parse error
        }
      }
    }
    
    // Từ bandwidth (ví dụ: 800000 -> 800kbps)
    if (bandwidth != null) {
      if (bandwidth >= 5000000) return '4K';
      if (bandwidth >= 3000000) return '1080p';
      if (bandwidth >= 1500000) return '720p';
      if (bandwidth >= 800000) return '480p';
    }
    
    return null;
  }

  static String? _extractResolution(String line) {
    // #EXT-X-STREAM-INF:RESOLUTION=1920x1080
    final match = RegExp(r'RESOLUTION=(\d+x\d+)').firstMatch(line);
    return match?.group(1);
  }

  static int? _extractBandwidth(String line) {
    // #EXT-X-STREAM-INF:BANDWIDTH=800000
    final match = RegExp(r'BANDWIDTH=(\d+)').firstMatch(line);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
}
