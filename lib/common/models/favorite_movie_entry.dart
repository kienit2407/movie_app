import 'package:hive_ce/hive_ce.dart';

part 'favorite_movie_entry.g.dart';

@HiveType(typeId: 101)
class FavoriteMovieEntry {
  @HiveField(0)
  final String slug;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String originName;

  @HiveField(3)
  final String posterUrl;

  @HiveField(4)
  final String episodeCurrent;

  @HiveField(5)
  final String quality;

  @HiveField(6)
  final String lang;

  @HiveField(7)
  final int year;

  @HiveField(8)
  final double? rating;

  @HiveField(9)
  final DateTime addedAt;

  FavoriteMovieEntry({
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    required this.rating,
    required this.addedAt,
  });
}
