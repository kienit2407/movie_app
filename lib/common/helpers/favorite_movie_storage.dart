import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:movie_app/common/models/favorite_movie_entry.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

class FavoriteMovieStorage {
  static const String _boxName = 'favoriteMovies';
  static Box<FavoriteMovieEntry>? _box;

  Future<Box<FavoriteMovieEntry>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<FavoriteMovieEntry>(_boxName);
    }
    return _box!;
  }

  Future<ValueListenable<Box<FavoriteMovieEntry>>> listenable() async {
    final box = await _getBox();
    return box.listenable();
  }

  List<FavoriteMovieEntry> sortEntries(Iterable<FavoriteMovieEntry> entries) {
    return entries.toList()..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  Future<bool> isFavorite(String slug) async {
    final box = await _getBox();
    return box.containsKey(slug);
  }

  Future<bool> toggle(MovieModel movie) async {
    final box = await _getBox();
    if (box.containsKey(movie.slug)) {
      await box.delete(movie.slug);
      return false;
    }

    await box.put(
      movie.slug,
      FavoriteMovieEntry(
        slug: movie.slug,
        name: movie.name,
        originName: movie.origin_name,
        posterUrl: movie.poster_url,
        episodeCurrent: movie.episode_current,
        quality: movie.quality,
        lang: movie.lang,
        year: movie.year,
        rating: movie.tmdb?.vote_average,
        addedAt: DateTime.now(),
      ),
    );
    return true;
  }
}
