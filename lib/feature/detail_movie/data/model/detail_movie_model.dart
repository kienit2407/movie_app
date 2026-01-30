// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DetailMovieModel {
  MovieModel movie;
  List<EpisodesModel> episodes;
  DetailMovieModel({required this.movie, required this.episodes});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'movie': movie.toMap(),
      'episodes': episodes.map((x) => x.toMap()).toList(),
    };
  }

  factory DetailMovieModel.fromMap(Map<String, dynamic> map) {
    final rawEpisodes = (map['episodes'] as List<dynamic>)
        .map((e) => EpisodesModel.fromMap(e as Map<String, dynamic>))
        .toList();

    final normalizedEpisodes = rawEpisodes
        .expand((e) => e.normalize())
        .toList();

    return DetailMovieModel(
      movie: MovieModel.fromMap(map['movie'] as Map<String, dynamic>),
      episodes: normalizedEpisodes,
    );
  }

  String toJson() => json.encode(toMap());

  factory DetailMovieModel.fromJson(String source) =>
      DetailMovieModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension EpisodesNormalize on EpisodesModel {
  List<EpisodesModel> normalize() {
    final base = _extractBaseServerName(server_name);

    // Nếu server_name không có kiểu gộp => giữ nguyên
    if (!_isMixedServerName(server_name)) return [this];

    // Phân loại item theo audio/sub type
    final longTieng = <ServerData>[];
    final thuyetMinh = <ServerData>[];
    final others = <ServerData>[]; // mặc định coi là Vietsub / bản chính

    for (final item in server_data) {
      final t = _detectType(item);
      if (t == _TrackType.longTieng) {
        longTieng.add(item);
      } else if (t == _TrackType.thuyetMinh) {
        thuyetMinh.add(item);
      } else {
        others.add(item);
      }
    }

    // Nếu không tách được gì (ví dụ chỉ toàn "Full" mà không có long-tieng/thuyet-minh)
    if (longTieng.isEmpty && thuyetMinh.isEmpty) return [this];

    final out = <EpisodesModel>[];

    // Vietsub: lấy phần còn lại (thường là "Full")
    if (others.isNotEmpty) {
      out.add(
        EpisodesModel(server_name: '$base (Vietsub)', server_data: others),
      );
    }

    // Lồng tiếng: ép hiển thị "Full" cho đúng format UI bạn muốn
    if (longTieng.isNotEmpty) {
      out.add(
        EpisodesModel(
          server_name: '$base (Lồng Tiếng)',
          server_data: longTieng.map(_forceFullNameSlug).toList(),
        ),
      );
    }

    // Thuyết minh: ép hiển thị "Full"
    if (thuyetMinh.isNotEmpty) {
      out.add(
        EpisodesModel(
          server_name: '$base (Thuyết Minh)',
          server_data: thuyetMinh.map(_forceFullNameSlug).toList(),
        ),
      );
    }

    // Nếu vì lý do nào đó out rỗng => fallback
    return out.isEmpty ? [this] : out;
  }

  String _extractBaseServerName(String s) {
    final idx = s.indexOf('(');
    if (idx == -1) return s.trim();
    return s.substring(0, idx).trim();
  }

  bool _isMixedServerName(String s) {
    final lower = s.toLowerCase();
    // bắt tất cả dạng gộp (bạn có thể bổ sung thêm keyword khác)
    return lower.contains('+') &&
        (lower.contains('vietsub') ||
            lower.contains('lồng tiếng') ||
            lower.contains('long tieng') ||
            lower.contains('thuyết minh') ||
            lower.contains('thuyet minh'));
  }

  _TrackType _detectType(ServerData x) {
    final slug = x.slug.toLowerCase().trim();
    final name = x.name.toLowerCase().trim();

    if (slug.contains('long-tieng') || slug.contains('long_tieng'))
      return _TrackType.longTieng;
    if (name.contains('lồng tiếng') || name.contains('long tieng'))
      return _TrackType.longTieng;

    if (slug.contains('thuyet-minh') || slug.contains('thuyet_minh'))
      return _TrackType.thuyetMinh;
    if (name.contains('thuyết minh') || name.contains('thuyet minh'))
      return _TrackType.thuyetMinh;

    return _TrackType.other; // coi như Vietsub/bản chính
  }

  // Vì UI của bạn đang render theo server_name, nên server_data cứ "Full" là đẹp nhất
  ServerData _forceFullNameSlug(ServerData x) {
    if (x.name == 'Full' && x.slug == 'full') return x;
    return ServerData(
      name: 'Full',
      slug: 'full',
      filename: x.filename,
      link_embed: x.link_embed,
      link_m3u8: x.link_m3u8,
    );
  }
}

enum _TrackType { other, longTieng, thuyetMinh }

class EpisodesModel {
  final String server_name;
  final List<ServerData> server_data;

  EpisodesModel({required this.server_name, required this.server_data});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'server_name': server_name,
      'server_data': server_data.map((x) => x.toMap()).toList(),
    };
  }

  factory EpisodesModel.fromMap(Map<String, dynamic> map) {
    return EpisodesModel(
      server_name: map['server_name'] as String,
      server_data: List<ServerData>.from(
        (map['server_data'] as List<dynamic>).map<ServerData>(
          (x) => ServerData.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory EpisodesModel.fromJson(String source) =>
      EpisodesModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ServerData {
  final String name;
  final String slug;
  final String filename;
  final String link_embed;
  final String link_m3u8;

  ServerData({
    required this.name,
    required this.slug,
    required this.filename,
    required this.link_embed,
    required this.link_m3u8,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'slug': slug,
      'filename': filename,
      'link_embed': link_embed,
      'link_m3u8': link_m3u8,
    };
  }

  factory ServerData.fromMap(Map<String, dynamic> map) {
    return ServerData(
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      filename: map['filename']?.toString() ?? '',
      link_embed: map['link_embed']?.toString() ?? '',
      link_m3u8: map['link_m3u8']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerData.fromJson(String source) =>
      ServerData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MovieModel {
  final TbdmModel? tmdb;
  final ImdbModel? imdb;
  final CreatedModel? created;
  final ModifiedModel? modified;
  final String? id;
  final String? internalId;
  final String slug;
  final String name;
  final String origin_name;
  final String content;
  final String type;
  final String status;
  final String poster_url;
  final String thumb_url;
  final bool is_copyright;
  final bool sub_docquyen;
  final bool chieurap;
  final String trailer_url;
  final String time;
  final String episode_current;
  final String? eposode_total;
  final String quality;
  final String lang;
  final String notify;
  final String showtimes;
  final int year;
  final int view;
  final List<dynamic>? actor;
  final List<dynamic>? director;
  final List<CategoryModel> category;
  final List<CountryModel> country;

  MovieModel({
    required this.tmdb,
    required this.imdb,
    required this.created,
    required this.modified,
    required this.id,
    this.internalId,
    required this.slug,
    required this.name,
    required this.origin_name,
    required this.content,
    required this.type,
    required this.status,
    required this.poster_url,
    required this.thumb_url,
    required this.is_copyright,
    required this.sub_docquyen,
    required this.chieurap,
    required this.trailer_url,
    required this.time,
    required this.episode_current,
    required this.eposode_total,
    required this.quality,
    required this.lang,
    required this.notify,
    required this.showtimes,
    required this.year,
    required this.view,
    required this.actor,
    required this.director,
    required this.category,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tmdb': tmdb?.toMap(),
      'imdb': imdb?.toMap(),
      'created': created?.toMap(),
      'modified': modified?.toMap(),
      'id': id,
      '_id': internalId,
      'slug': slug,
      'name': name,
      'origin_name': origin_name,
      'content': content,
      'type': type,
      'status': status,
      'poster_url': poster_url,
      'thumb_url': thumb_url,
      'is_copyright': is_copyright,
      'sub_docquyen': sub_docquyen,
      'chieurap': chieurap,
      'trailer_url': trailer_url,
      'time': time,
      'episode_current': episode_current,
      'eposode_total': eposode_total,
      'quality': quality,
      'lang': lang,
      'notify': notify,
      'showtimes': showtimes,
      'year': year,
      'view': view,
      'actor': actor,
      'director': director,
      'category': category.map((x) => x.toMap()).toList(),
      'country': country.map((x) => x.toMap()).toList(),
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    try {
      final List<CategoryModel> parsedCategories = [];
      if (map['category'] is List) {
        for (var item in map['category'] as List) {
          if (item is Map<String, dynamic>) {
            try {
              parsedCategories.add(CategoryModel.fromMap(item));
            } catch (e) {
              print('Error parsing category: $e, item: $item');
            }
          }
        }
      }

      final List<CountryModel> parsedCountries = [];
      if (map['country'] is List) {
        for (var item in map['country'] as List) {
          if (item is Map<String, dynamic>) {
            try {
              parsedCountries.add(CountryModel.fromMap(item));
            } catch (e) {
              print('Error parsing country: $e, item: $item');
            }
          }
        }
      }

      return MovieModel(
        tmdb: map['tmdb'] is Map
            ? TbdmModel.fromMap(map['tmdb'] as Map<String, dynamic>)
            : null,
        imdb: map['imdb'] is Map
            ? ImdbModel.fromMap(map['imdb'] as Map<String, dynamic>)
            : null,
        created: map['created'] is Map
            ? CreatedModel.fromMap(map['created'] as Map<String, dynamic>)
            : null,
        modified: map['modified'] is Map
            ? ModifiedModel.fromMap(map['modified'] as Map<String, dynamic>)
            : null,
        id: map['id']?.toString(),
        internalId: map['_id']?.toString(),
        slug: map['slug']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        origin_name: map['origin_name']?.toString() ?? '',
        content: map['content'] is String
            ? map['content'] as String
            : map['content']?.toString() ?? '',
        type: map['type'] is String
            ? map['type'] as String
            : map['type']?.toString() ?? '',
        status: map['status'] is String
            ? map['status'] as String
            : map['status']?.toString() ?? '',
        poster_url: map['poster_url']?.toString() ?? '',
        thumb_url: map['thumb_url']?.toString() ?? '',
        is_copyright: map['is_copyright'] is bool
            ? map['is_copyright'] as bool
            : map['is_copyright']?.toString().toLowerCase() == 'true',
        sub_docquyen: map['sub_docquyen'] is bool
            ? map['sub_docquyen'] as bool
            : map['sub_docquyen']?.toString().toLowerCase() == 'true',
        chieurap: map['chieurap'] is bool
            ? map['chieurap'] as bool
            : map['chieurap']?.toString().toLowerCase() == 'true',
        trailer_url: map['trailer_url']?.toString() ?? '',
        time: map['time']?.toString() ?? '',
        episode_current: map['episode_current']?.toString() ?? '',
        eposode_total: map['eposode_total']?.toString(),
        quality: map['quality']?.toString() ?? '',
        lang: map['lang']?.toString() ?? '',
        notify: map['notify'] is String
            ? map['notify'] as String
            : map['notify']?.toString() ?? '',
        showtimes: map['showtimes'] is String
            ? map['showtimes'] as String
            : map['showtimes']?.toString() ?? '',
        year: map['year'] is int
            ? map['year'] as int
            : int.tryParse(map['year']?.toString() ?? '0') ?? 0,
        view: map['view'] is int
            ? map['view'] as int
            : int.tryParse(map['view']?.toString() ?? '0') ?? 0,
        actor: map['actor'] != null
            ? List<dynamic>.from((map['actor'] as List<dynamic>))
            : null,
        director: map['director'] != null
            ? List<dynamic>.from((map['director'] as List<dynamic>))
            : null,
        category: parsedCategories,
        country: parsedCountries,
      );
    } catch (e) {
      print('Error parsing MovieModel: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  factory MovieModel.fromJson(String source) =>
      MovieModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;

  CategoryModel({required this.id, required this.name, required this.slug});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'slug': slug};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CountryModel {
  final String id;
  final String name;
  final String slug;

  CountryModel({required this.id, required this.name, required this.slug});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'slug': slug};
  }

  factory CountryModel.fromMap(Map<String, dynamic> map) {
    return CountryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CountryModel.fromJson(String source) =>
      CountryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class TbdmModel {
  final String? type;
  final int? id;
  final int? season;
  final double? vote_average;
  final int? vote_count;

  TbdmModel({
    this.type,
    this.id,
    this.season,
    this.vote_average,
    this.vote_count,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'id': id,
      'season': season,
      'vote_average': vote_average,
      'vote_count': vote_count,
    };
  }

  factory TbdmModel.fromMap(Map<String, dynamic> map) {
    return TbdmModel(
      type: map['type']?.toString(),
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      season: map['season'] != null
          ? int.tryParse(map['season'].toString())
          : null,
      vote_average: map['vote_average'] != null
          ? double.tryParse(map['vote_average'].toString())
          : null,
      vote_count: map['vote_count'] != null
          ? int.tryParse(map['vote_count'].toString())
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TbdmModel.fromJson(String source) =>
      TbdmModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ImdbModel {
  final String? id;

  ImdbModel({this.id});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id};
  }

  factory ImdbModel.fromMap(Map<String, dynamic> map) {
    return ImdbModel(id: map['id']?.toString());
  }

  String toJson() => json.encode(toMap());

  factory ImdbModel.fromJson(String source) =>
      ImdbModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CreatedModel {
  final DateTime time;

  CreatedModel({required this.time});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'time': time.toIso8601String()};
  }

  factory CreatedModel.fromMap(Map<String, dynamic> map) {
    return CreatedModel(time: DateTime.parse(map['time'] as String));
  }

  String toJson() => json.encode(toMap());

  factory CreatedModel.fromJson(String source) =>
      CreatedModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ModifiedModel {
  final DateTime time;

  ModifiedModel({required this.time});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'time': time.toIso8601String()};
  }

  factory ModifiedModel.fromMap(Map<String, dynamic> map) {
    return ModifiedModel(time: DateTime.parse(map['time'] as String));
  }

  String toJson() => json.encode(toMap());

  factory ModifiedModel.fromJson(String source) =>
      ModifiedModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
