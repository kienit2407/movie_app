import 'package:hive_ce/hive.dart';

part 'watch_progress_model.g.dart';

@HiveType(typeId: 1)
class WatchProgressModel {
  @HiveField(0)
  final String movieId;

  @HiveField(1)
  final String episodeName;

  @HiveField(2)
  final int positionMs;

  @HiveField(3)
  final int durationMs;

  @HiveField(4)
  final DateTime lastUpdated;

  WatchProgressModel({
    required this.movieId,
    required this.episodeName,
    required this.positionMs,
    required this.durationMs,
    required this.lastUpdated,
  });

  double get progressPercent => durationMs > 0 ? positionMs / durationMs : 0;
}
