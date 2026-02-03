import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/common/models/watch_history_entry.dart';

class WatchHistoryStorage {
  static const String _boxName = 'watchHistory';
  static const int _maxItems = 20;
  static const int _minItemsToCleanup = 10;

  Box<WatchHistoryEntry>? _box;

  Future<Box<WatchHistoryEntry>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<WatchHistoryEntry>(_boxName);
    }
    return _box!;
  }

  Future<void> addToHistory({
    required String slug,
    required String name,
    required String originName,
    required String posterUrl,
    String? thumbUrl,
    required String episodeCurrent,
    String? quality,
    String? lang,
    String? year,
    double? rating,
    required int positionMs,
    required int durationMs,
    String? type,
    String? categoryId,
    String? categoryName,
  }) async {
    final box = await _getBox();
    final now = DateTime.now();

    final entry = WatchHistoryEntry(
      slug: slug,
      name: name,
      originName: originName,
      posterUrl: posterUrl,
      thumbUrl: thumbUrl,
      episodeCurrent: episodeCurrent,
      quality: quality,
      lang: lang,
      year: year,
      rating: rating,
      watchedAt: now,
      positionMs: positionMs,
      durationMs: durationMs,
      type: type,
      categoryId: categoryId,
      categoryName: categoryName,
    );

    // Check if this slug already exists using box.get directly
    final existingEntry = box.get(slug);

    if (existingEntry != null) {
      // Update existing entry
      await box.put(slug, entry);
    } else {
      // Add new entry
      await box.put(slug, entry);
    }

    // Cleanup if too many items
    if (box.length > _maxItems) {
      await _cleanupOldEntries(box);
    }
  }

  Future<void> _cleanupOldEntries(Box<WatchHistoryEntry> box) async {
    final sortedEntries = box.values.toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));

    final toDelete = sortedEntries.sublist(_maxItems);
    for (final entry in toDelete) {
      await box.delete(entry.slug);
    }
  }

  Future<List<WatchHistoryEntry>> getHistory({int limit = 20}) async {
    final box = await _getBox();
    final sortedEntries = box.values.toList()
      ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    
    return sortedEntries.take(limit).toList();
  }

  Future<WatchHistoryEntry?> getEntry(String slug) async {
    final box = await _getBox();
    return box.get(slug);
  }

  Future<void> removeEntry(String slug) async {
    final box = await _getBox();
    await box.delete(slug);
  }

  Future<void> clearHistory() async {
    final box = await _getBox();
    await box.clear();
  }

  Future<int> getHistoryCount() async {
    final box = await _getBox();
    return box.length;
  }

  Future<void> updateProgress({
    required String slug,
    required int positionMs,
    required int durationMs,
  }) async {
    final box = await _getBox();
    final existing = box.get(slug);
    
    if (existing != null) {
      final updated = WatchHistoryEntry(
        slug: existing.slug,
        name: existing.name,
        originName: existing.originName,
        posterUrl: existing.posterUrl,
        thumbUrl: existing.thumbUrl,
        episodeCurrent: existing.episodeCurrent,
        quality: existing.quality,
        lang: existing.lang,
        year: existing.year,
        rating: existing.rating,
        watchedAt: DateTime.now(),
        positionMs: positionMs,
        durationMs: durationMs,
        type: existing.type,
        categoryId: existing.categoryId,
        categoryName: existing.categoryName,
      );
      await box.put(slug, updated);
    }
  }

  Future<void> dispose() async {
    await _box?.close();
    _box = null;
  }
}
