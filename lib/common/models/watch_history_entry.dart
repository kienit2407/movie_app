import 'package:hive_ce/hive_ce.dart';

part 'watch_history_entry.g.dart';

@HiveType(typeId: 100)
class WatchHistoryEntry {
  @HiveField(0)
  final String slug;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String originName;

  @HiveField(3)
  final String posterUrl;

  @HiveField(4)
  final String? thumbUrl;

  @HiveField(5)
  final String episodeCurrent;

  @HiveField(6)
  final String? quality;

  @HiveField(7)
  final String? lang;

  @HiveField(8)
  final String? year;

  @HiveField(9)
  final double? rating;

  @HiveField(10)
  final DateTime watchedAt;

  @HiveField(11)
  final int positionMs;

  @HiveField(12)
  final int durationMs;

  @HiveField(13)
  final String? type;

  @HiveField(14)
  final String? categoryId;

  @HiveField(15)
  final String? categoryName;

  WatchHistoryEntry({
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    this.thumbUrl,
    required this.episodeCurrent,
    this.quality,
    this.lang,
    this.year,
    this.rating,
    required this.watchedAt,
    required this.positionMs,
    required this.durationMs,
    this.type,
    this.categoryId,
    this.categoryName,
  });

  double get progressPercent {
    if (durationMs <= 0) return 0;
    return (positionMs / durationMs).clamp(0.0, 1.0);
  }

  bool get isCompleted => progressPercent >= 0.9;

  bool get hasProgress => positionMs > 0 && progressPercent < 0.9;
}
