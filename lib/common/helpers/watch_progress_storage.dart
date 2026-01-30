import 'package:hive_ce/hive.dart';
import 'package:movie_app/common/models/watch_progress_model.dart';

class WatchProgressStorage {
  static const String _progressBoxName = 'watchProgress';
  static const String _lastWatchedBoxName = 'lastWatchedEpisode'; // Box mới
  static const int _maxItems = 100;

  Box<WatchProgressModel>? _progressBox;
  Box? _lastWatchedBox;

  Future<Box<WatchProgressModel>> _openProgressBox() async {
    _progressBox ??= await Hive.openBox<WatchProgressModel>(_progressBoxName);
    return _progressBox!;
  }

  Future<Box> _openLastWatchedBox() async {
    _lastWatchedBox ??= await Hive.openBox(_lastWatchedBoxName);
    return _lastWatchedBox!;
  }

  // Key duy nhất cho từng tập: slug + server + episode
  String _key(String movieId, int serverIndex, int episodeIndex) =>
      '$movieId|s$serverIndex|e$episodeIndex';

  // 1. Lưu vị trí xem của TẬP HIỆN TẠI
  Future<void> saveProgressV2({
    required String movieId,
    required int serverIndex,
    required int episodeIndex,
    required String episodeName,
    required int positionMs,
    required int durationMs,
  }) async {
    final box = await _openProgressBox();
    final lastBox = await _openLastWatchedBox();

    final progress = WatchProgressModel(
      movieId: movieId,
      episodeName: episodeName,
      positionMs: positionMs,
      durationMs: durationMs,
      lastUpdated: DateTime.now(),
    );

    // Lưu progress của tập này
    await box.put(_key(movieId, serverIndex, episodeIndex), progress);

    // Lưu đánh dấu đây là tập xem gần nhất của phim này
    await lastBox.put(movieId, {
      'serverIndex': serverIndex,
      'episodeIndex': episodeIndex,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await _cleanupOldEntries();
  }

  // 2. Lấy vị trí xem của một tập cụ thể
  Future<WatchProgressModel?> getProgressV2({
    required String movieId,
    required int serverIndex,
    required int episodeIndex,
  }) async {
    final box = await _openProgressBox();
    return box.get(_key(movieId, serverIndex, episodeIndex));
  }

  // 3. Lấy thông tin tập xem gần nhất (cho nút "Xem tiếp" ở Home/Detail)
  Future<Map<String, dynamic>?> getLastWatchedEpisode(String movieId) async {
    final box = await _openLastWatchedBox();
    final data = box.get(movieId);
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  Future<void> _cleanupOldEntries() async {
    final box = await _openProgressBox();
    if (box.length <= _maxItems) return;

    final entries = box.toMap().entries.toList()
      ..sort((a, b) => a.value.lastUpdated.compareTo(b.value.lastUpdated));

    final toDelete = entries.length - _maxItems;
    for (int i = 0; i < toDelete; i++) {
      await box.delete(entries[i].key);
    }
  }
}
