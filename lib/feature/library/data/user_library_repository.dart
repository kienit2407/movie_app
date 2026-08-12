import 'dart:typed_data';

import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserFavorite {
  const UserFavorite({
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    required this.thumbUrl,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    required this.rating,
    required this.addedAt,
  });

  final String slug;
  final String name;
  final String originName;
  final String posterUrl;
  final String thumbUrl;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final int year;
  final double? rating;
  final DateTime addedAt;

  factory UserFavorite.fromMap(Map<String, dynamic> map) => UserFavorite(
    slug: map['movie_slug']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    originName: map['origin_name']?.toString() ?? '',
    posterUrl: map['poster_url']?.toString() ?? '',
    thumbUrl: map['thumb_url']?.toString() ?? '',
    episodeCurrent: map['episode_current']?.toString() ?? '',
    quality: map['quality']?.toString() ?? '',
    lang: map['lang']?.toString() ?? '',
    year: (map['year'] as num?)?.toInt() ?? 0,
    rating: (map['rating'] as num?)?.toDouble(),
    addedAt:
        DateTime.tryParse(map['added_at']?.toString() ?? '')?.toLocal() ??
        DateTime.now(),
  );

  static UserFavorite fromMovie(MovieModel movie) => UserFavorite(
    slug: movie.slug,
    name: movie.name,
    originName: movie.origin_name,
    posterUrl: movie.poster_url,
    thumbUrl: movie.thumb_url,
    episodeCurrent: movie.episode_current,
    quality: movie.quality,
    lang: movie.lang,
    year: movie.year,
    rating: movie.tmdb?.vote_average?.toDouble(),
    addedAt: DateTime.now(),
  );

  Map<String, dynamic> toInsert(String userId) => {
    'user_id': userId,
    'movie_slug': slug,
    'name': name,
    'origin_name': originName,
    'poster_url': posterUrl,
    'thumb_url': thumbUrl,
    'episode_current': episodeCurrent,
    'quality': quality,
    'lang': lang,
    'year': year,
    'rating': rating,
    'added_at': addedAt.toUtc().toIso8601String(),
  };
}

class UserWatchHistory {
  const UserWatchHistory({
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    required this.thumbUrl,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    required this.rating,
    required this.positionMs,
    required this.durationMs,
    required this.watchedAt,
    this.movieType,
    this.categoryId,
    this.categoryName,
    this.lastServerIndex,
    this.lastEpisodeIndex,
    this.lastEpisodeName,
    this.lastEpisodeLink,
    this.lastServerName,
  });

  final String slug;
  final String name;
  final String originName;
  final String posterUrl;
  final String thumbUrl;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final int year;
  final double? rating;
  final int positionMs;
  final int durationMs;
  final String? movieType;
  final String? categoryId;
  final String? categoryName;
  final int? lastServerIndex;
  final int? lastEpisodeIndex;
  final String? lastEpisodeName;
  final String? lastEpisodeLink;
  final String? lastServerName;
  final DateTime watchedAt;

  double get progress =>
      durationMs <= 0 ? 0 : (positionMs / durationMs).clamp(0.0, 1.0);

  factory UserWatchHistory.fromMap(Map<String, dynamic> map) =>
      UserWatchHistory(
        slug: map['movie_slug']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        originName: map['origin_name']?.toString() ?? '',
        posterUrl: map['poster_url']?.toString() ?? '',
        thumbUrl: map['thumb_url']?.toString() ?? '',
        episodeCurrent: map['episode_current']?.toString() ?? '',
        quality: map['quality']?.toString() ?? '',
        lang: map['lang']?.toString() ?? '',
        year: (map['year'] as num?)?.toInt() ?? 0,
        rating: (map['rating'] as num?)?.toDouble(),
        positionMs: (map['position_ms'] as num?)?.toInt() ?? 0,
        durationMs: (map['duration_ms'] as num?)?.toInt() ?? 0,
        movieType: map['movie_type']?.toString(),
        categoryId: map['category_id']?.toString(),
        categoryName: map['category_name']?.toString(),
        lastServerIndex: (map['last_server_index'] as num?)?.toInt(),
        lastEpisodeIndex: (map['last_episode_index'] as num?)?.toInt(),
        lastEpisodeName: map['last_episode_name']?.toString(),
        lastEpisodeLink: map['last_episode_link']?.toString(),
        lastServerName: map['last_server_name']?.toString(),
        watchedAt:
            DateTime.tryParse(map['watched_at']?.toString() ?? '')?.toLocal() ??
            DateTime.now(),
      );

  Map<String, dynamic> toUpsert(String userId) => {
    'user_id': userId,
    'movie_slug': slug,
    'name': name,
    'origin_name': originName,
    'poster_url': posterUrl,
    'thumb_url': thumbUrl,
    'episode_current': episodeCurrent,
    'quality': quality,
    'lang': lang,
    'year': year,
    'rating': rating,
    'movie_type': movieType,
    'category_id': categoryId,
    'category_name': categoryName,
    'position_ms': positionMs,
    'duration_ms': durationMs,
    'last_server_index': lastServerIndex,
    'last_episode_index': lastEpisodeIndex,
    'last_episode_name': lastEpisodeName,
    'last_episode_link': lastEpisodeLink,
    'last_server_name': lastServerName,
    'watched_at': watchedAt.toUtc().toIso8601String(),
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  };
}

abstract interface class UserLibraryRepository {
  User? get currentUser;

  Future<List<UserFavorite>> getFavorites();
  Future<List<UserWatchHistory>> getWatchHistory();
  Future<void> addFavorite(UserFavorite favorite);
  Future<void> removeFavorite(String slug);
  Future<void> removeFavorites(Iterable<String> slugs);
  Future<void> upsertWatchHistory(UserWatchHistory history);
  Future<void> removeWatchHistory(String slug);
  Future<void> removeWatchHistoryItems(Iterable<String> slugs);
  Future<String> uploadAvatar(Uint8List bytes, {required String extension});
  Future<User> updateProfile({required String displayName, String? avatarUrl});
}

class SupabaseUserLibraryRepository implements UserLibraryRepository {
  SupabaseUserLibraryRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  String get _userId {
    final id = currentUser?.id;
    if (id == null) throw const AuthException('Bạn cần đăng nhập.');
    return id;
  }

  @override
  Future<List<UserFavorite>> getFavorites() async {
    final response = await _client
        .from('user_favorites')
        .select()
        .eq('user_id', _userId)
        .order('added_at', ascending: false);
    return response.map(UserFavorite.fromMap).toList(growable: false);
  }

  @override
  Future<List<UserWatchHistory>> getWatchHistory() async {
    final response = await _client
        .from('user_watch_history')
        .select()
        .eq('user_id', _userId)
        .order('watched_at', ascending: false)
        .limit(100);
    return response.map(UserWatchHistory.fromMap).toList(growable: false);
  }

  @override
  Future<void> addFavorite(UserFavorite favorite) => _client
      .from('user_favorites')
      .upsert(favorite.toInsert(_userId), onConflict: 'user_id,movie_slug');

  @override
  Future<void> removeFavorite(String slug) => _client
      .from('user_favorites')
      .delete()
      .eq('user_id', _userId)
      .eq('movie_slug', slug);

  @override
  Future<void> removeFavorites(Iterable<String> slugs) async {
    final values = slugs.toSet().toList(growable: false);
    if (values.isEmpty) return;
    await _client
        .from('user_favorites')
        .delete()
        .eq('user_id', _userId)
        .inFilter('movie_slug', values);
  }

  @override
  Future<void> upsertWatchHistory(UserWatchHistory history) => _client
      .from('user_watch_history')
      .upsert(history.toUpsert(_userId), onConflict: 'user_id,movie_slug');

  @override
  Future<void> removeWatchHistory(String slug) => _client
      .from('user_watch_history')
      .delete()
      .eq('user_id', _userId)
      .eq('movie_slug', slug);

  @override
  Future<void> removeWatchHistoryItems(Iterable<String> slugs) async {
    final values = slugs.toSet().toList(growable: false);
    if (values.isEmpty) return;
    await _client
        .from('user_watch_history')
        .delete()
        .eq('user_id', _userId)
        .inFilter('movie_slug', values);
  }

  @override
  Future<String> uploadAvatar(
    Uint8List bytes, {
    required String extension,
  }) async {
    final normalizedExtension = extension.toLowerCase().replaceAll('.', '');
    final safeExtension =
        {'jpg', 'jpeg', 'png', 'webp'}.contains(normalizedExtension)
        ? normalizedExtension
        : 'jpg';
    final path =
        '$_userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
    await _client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            contentType: safeExtension == 'png'
                ? 'image/png'
                : safeExtension == 'webp'
                ? 'image/webp'
                : 'image/jpeg',
          ),
        );
    final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
    return '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<User> updateProfile({
    required String displayName,
    String? avatarUrl,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty) throw const FormatException('Tên không được để trống.');
    final currentMetadata = Map<String, dynamic>.from(
      currentUser?.userMetadata ?? const <String, dynamic>{},
    );
    final previousAvatarPath = _avatarObjectPath(
      currentMetadata['avatar_url']?.toString(),
    );
    currentMetadata['full_name'] = name;
    currentMetadata['name'] = name;
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      currentMetadata['avatar_url'] = avatarUrl.trim();
      currentMetadata['picture'] = avatarUrl.trim();
    }
    final response = await _client.auth.updateUser(
      UserAttributes(data: currentMetadata),
    );
    final updatedUser = response.user;
    if (updatedUser == null) {
      throw const AuthException('Không thể đọc hồ sơ vừa cập nhật.');
    }
    final nextAvatarPath = _avatarObjectPath(avatarUrl);
    if (previousAvatarPath != null &&
        nextAvatarPath != null &&
        previousAvatarPath != nextAvatarPath) {
      try {
        await _client.storage.from('avatars').remove([previousAvatarPath]);
      } catch (_) {
        // Profile was already updated; stale avatar cleanup can be retried later.
      }
    }
    return updatedUser;
  }

  String? _avatarObjectPath(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;
    const marker = '/storage/v1/object/public/avatars/';
    final markerIndex = uri.path.indexOf(marker);
    if (markerIndex < 0) return null;
    return Uri.decodeComponent(uri.path.substring(markerIndex + marker.length));
  }
}
