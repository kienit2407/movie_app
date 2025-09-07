class DetailMovieEntity {
  MovieEntity movie;
  List<EpisodesEntity> episodes;
  DetailMovieEntity({
    required this.movie,
    required this.episodes,
  });
}

class EpisodesEntity {
  final String server_name;
  final ServerData server_data;

  EpisodesEntity({required this.server_name, required this.server_data});
}
class ServerData {
  final String name;
  final String slug;
  final String filename;
  final String link_embed;
  final String link_m3u8;

  ServerData({required this.name, required this.slug, required this.filename, required this.link_embed, required this.link_m3u8});
}
class MovieEntity {
  final TbdmEntity tBdm;
  final CreatedEntity created;
  final ModifiedEntity modified;
  final String id;
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
  final String eposode_total;
  final String quality;
  final String lang;
  final int year;
  final List<Actor> actor;
  final List<Director> director;
  final List<CategoryEntity> category;
  final List<CountryEntity> country;

  MovieEntity({
    required this.tBdm,
    required this.created,
    required this.modified,
    required this.id,
    required this.slug,
    required this.origin_name,
    required this.content,
    required this.type,
    required this.status,
    required this.poster_url,
    required this.thumb_url,
    required this.chieurap,
    required this.trailer_url,
    required this.time,
    required this.episode_current,
    required this.eposode_total,
    required this.quality,
    required this.lang,
    required this.year,
    required this.actor,
    required this.director,
    required this.category,
    required this.country,
  });
}

class CategoryEntity {
  final String id;
  final String name;
  final String slug;

  CategoryEntity({required this.id, required this.name, required this.slug});
}

class CountryEntity {
  final String id;
  final String name;
  final String slug;
  CountryEntity({required this.id, required this.name, required this.slug});
}

class Actor {
  final String nameActor;
  Actor({required this.nameActor});
}

class Director {
  final String nameDirector;
  Director({required this.nameDirector});
}

class TbdmEntity {
  final int season;
  final num vote_average;

  TbdmEntity({required this.season, required this.vote_average});
}

class CreatedEntity {
  final String time;

  CreatedEntity({required this.time});
}

class ModifiedEntity {
  final String time;
  ModifiedEntity({required this.time});
}
