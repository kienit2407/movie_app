class NewMovieEntity {
  final List<ItemEntity> items; //nếu không chỉ định kiểu cụ thể
  final PaginationEntity pagination;

  NewMovieEntity({required this.items, required this.pagination});
}

class ItemEntity {
  final TmDbEntity tmdb;
  final ModifiedEntity modified;
  final String id;
  final String name;
  final String slug;
  final String originName;
  final String type;
  final String posterUrl;
  final String thumbUrl;
  final String time;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final int year;
  final List<CategoryEntity> category;
  final List<CountryEntity> country;
  final bool? subDocquyen;
  final bool? chieurap;

  ItemEntity({
    required this.tmdb,
    required this.modified,
    required this.id,
    required this.name,
    required this.slug,
    required this.originName,
    required this.type,
    required this.posterUrl,
    required this.thumbUrl,
    required this.time,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    required this.category,
    required this.country,
    this.subDocquyen,
    this.chieurap,
  });
}

class TmDbEntity {
  final num voteAverage;

  TmDbEntity({required this.voteAverage});
}

class ModifiedEntity {
  final String time;

  ModifiedEntity({required this.time});
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

class PaginationEntity {
  final int totalItems;
  final int totalItemsPerPage;
  final int currentPage;
  final int totalPages;

  PaginationEntity({
    required this.totalItems,
    required this.totalItemsPerPage,
    required this.currentPage,
    required this.totalPages,
  });
}
