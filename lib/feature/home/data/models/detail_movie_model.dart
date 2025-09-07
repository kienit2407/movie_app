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
    return DetailMovieModel(
      movie: MovieModel.fromMap(map['movie'] as Map<String, dynamic>),
      episodes: List<EpisodesModel>.from(
        (map['episodes'] as List<dynamic>).map<EpisodesModel>(
          (x) => EpisodesModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DetailMovieModel.fromJson(String source) =>
      DetailMovieModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

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
      server_data: List<ServerData>.from((map['server_data'] as List<dynamic>).map<ServerData>((x) => ServerData.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory EpisodesModel.fromJson(String source) => EpisodesModel.fromMap(json.decode(source) as Map<String, dynamic>);
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
      name: map['name'] as String,
      slug: map['slug'] as String,
      filename: map['filename'] as String,
      link_embed: map['link_embed'] as String,
      link_m3u8: map['link_m3u8'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ServerData.fromJson(String source) =>
      ServerData.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MovieModel {
  final TbdmModel? tbdm;
  final CreatedModel created;
  final ModifiedModel modified;
  final String? id;
  final String slug;
  final String origin_name;
  final String content;
  final String type;
  final String status;
  final String poster_url;
  final String thumb_url;
  final bool chieurap;
  final String trailer_url;
  final String time;
  final String episode_current;
  final String? eposode_total;
  final String quality;
  final String lang;
  final int year;
  final List<dynamic>? actor;
  final List<dynamic>? director;
  final List<CategoryModel> category;
  final List<CountryModel> country;

  MovieModel({required this.tbdm, required this.created, required this.modified, required this.id, required this.slug, required this.origin_name, required this.content, required this.type, required this.status, required this.poster_url, required this.thumb_url, required this.chieurap, required this.trailer_url, required this.time, required this.episode_current, required this.eposode_total, required this.quality, required this.lang, required this.year, required this.actor, required this.director, required this.category, required this.country});



 

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tbdm': tbdm?.toMap(),
      'created': created.toMap(),
      'modified': modified.toMap(),
      'id': id,
      'slug': slug,
      'origin_name': origin_name,
      'content': content,
      'type': type,
      'status': status,
      'poster_url': poster_url,
      'thumb_url': thumb_url,
      'chieurap': chieurap,
      'trailer_url': trailer_url,
      'time': time,
      'episode_current': episode_current,
      'eposode_total': eposode_total,
      'quality': quality,
      'lang': lang,
      'year': year,
      'actor': actor,
      'director': director,
      'category': category.map((x) => x.toMap()).toList(),
      'country': country.map((x) => x.toMap()).toList(),
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      tbdm: map['tbdm'] != null ? TbdmModel.fromMap(map['tbdm'] as Map<String,dynamic>) : null,
      created: CreatedModel.fromMap(map['created'] as Map<String,dynamic>),
      modified: ModifiedModel.fromMap(map['modified'] as Map<String,dynamic>),
      id: map['id'] != null ? map['id'] as String : null,
      slug: map['slug'] as String,
      origin_name: map['origin_name'] as String,
      content: map['content'] as String,
      type: map['type'] as String,
      status: map['status'] as String,
      poster_url: map['poster_url'] as String,
      thumb_url: map['thumb_url'] as String,
      chieurap: map['chieurap'] as bool,
      trailer_url: map['trailer_url'] as String,
      time: map['time'] as String,
      episode_current: map['episode_current'] as String,
      eposode_total: map['eposode_total'] != null ? map['eposode_total'] as String : null,
      quality: map['quality'] as String,
      lang: map['lang'] as String,
      year: map['year'] as int,
      actor: map['actor'] != null ? List<dynamic>.from((map['actor'] as List<dynamic>)) : null,
      director: map['director'] != null ? List<dynamic>.from((map['director'] as List<dynamic>)) : null,
      category: List<CategoryModel>.from((map['category'] as List<dynamic>).map<CategoryModel>((x) => CategoryModel.fromMap(x as Map<String,dynamic>),),),
      country: List<CountryModel>.from((map['country'] as List<dynamic>).map<CountryModel>((x) => CountryModel.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory MovieModel.fromJson(String source) => MovieModel.fromMap(json.decode(source) as Map<String, dynamic>);
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
      id: map['id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
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
      id: map['id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CountryModel.fromJson(String source) =>
      CountryModel.fromMap(json.decode(source) as Map<String, dynamic>);
}




class TbdmModel {
  final int season;
  final num vote_average;

  TbdmModel({required this.season, required this.vote_average});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'season': season, 'vote_average': vote_average};
  }

  factory TbdmModel.fromMap(Map<String, dynamic> map) {
    return TbdmModel(
      season: map['season'] as int,
      vote_average: map['vote_average'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory TbdmModel.fromJson(String source) =>
      TbdmModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CreatedModel {
  final String time;

  CreatedModel({required this.time});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'time': time};
  }

  factory CreatedModel.fromMap(Map<String, dynamic> map) {
    return CreatedModel(time: map['time'] as String);
  }

  String toJson() => json.encode(toMap());

  factory CreatedModel.fromJson(String source) =>
      CreatedModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ModifiedModel {
  final String time;
  ModifiedModel({required this.time});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'time': time};
  }

  factory ModifiedModel.fromMap(Map<String, dynamic> map) {
    return ModifiedModel(time: map['time'] as String);
  }

  String toJson() => json.encode(toMap());

  factory ModifiedModel.fromJson(String source) =>
      ModifiedModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
