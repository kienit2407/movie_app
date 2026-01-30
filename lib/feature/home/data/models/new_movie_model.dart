// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

class NewMovieModel {
  final List<ItemModel> items; //nếu không chỉ định kiểu cụ thể
  final PaginationModel pagination;

  NewMovieModel({required this.items, required this.pagination});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': items.map((x) => x.toMap()).toList(),
      'pagination': pagination.toMap(),
    };
  }

  factory NewMovieModel.fromMap(Map<String, dynamic> map) {
    return NewMovieModel(
      items: List<ItemModel>.from(
        (map['items'] as List<dynamic>).map<ItemModel>(
          (x) => ItemModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      pagination: PaginationModel.fromMap(
        map['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory NewMovieModel.fromJson(String source) =>
      NewMovieModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension NewMovieModelConvert on NewMovieModel {
  NewMovieEntity toEntity() {
    return NewMovieEntity(
      items: items.map((e) => e.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class ItemModel {
  final TmDbModel tmdb;
  final ModifiedModel modified;
  final String id;
  final String name;
  final String slug;
  final String origin_name;
  final String? type;
  final String poster_url;
  final String thumb_url;
  final String? time;
  final String? episode_current;
  final String? quality;
  final String? lang;
  final int year;
  final List<CategoryModel>? category;
  final List<CountryModel>? country;
  final bool sub_docquyen;
  final bool chieurap;

  ItemModel({
    required this.tmdb,
    required this.modified,
    required this.id,
    required this.name,
    required this.slug,
    required this.origin_name,
    required this.type,
    required this.poster_url,
    required this.thumb_url,
    required this.time,
    required this.episode_current,
    required this.quality,
    required this.lang,
    required this.year,
    required this.category,
    required this.country,
    required this.sub_docquyen,
    required this.chieurap,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tmdb': tmdb.toMap(),
      'modified': modified.toMap(),
      'id': id,
      'name': name,
      'slug': slug,
      'origin_name': origin_name,
      'type': type,
      'poster_url': poster_url,
      'thumb_url': thumb_url,
      'time': time,
      'episode_current': episode_current,
      'quality': quality,
      'lang': lang,
      'year': year,
      'category': (category ?? []).map((x) => x.toMap()).toList(),
      'country': (country ?? []).map((x) => x.toMap()).toList(),
      'sub_docquyen': sub_docquyen,
      'chieurap': chieurap,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      tmdb: TmDbModel.fromMap(map['tmdb'] as Map<String, dynamic>),
      modified: ModifiedModel.fromMap(map['modified'] as Map<String, dynamic>),
      id: map['_id'] as String,
      name: map['name'] as String,
      slug: map['slug'] as String,
      origin_name: map['origin_name'] as String,
      type: map['type'] != null ? map['type'] as String : null,
      poster_url: map['poster_url'] as String,
      thumb_url: map['thumb_url'] as String,
      time: map['time'] != null ? map['time'] as String : null,
      episode_current: map['episode_current'] != null
          ? map['episode_current'] as String
          : null,
      quality: map['quality'] != null ? map['quality'] as String : null,
      lang: map['lang'] != null ? map['lang'] as String : null,
      year: map['year'] is int
          ? map['year'] as int
          : int.tryParse(map['year'].toString()) ?? 0,
      category: map['category'] != null
          ? List<CategoryModel>.from(
              (map['category'] as List<dynamic>).map<CategoryModel?>(
                (x) => CategoryModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      country: map['country'] != null
          ? List<CountryModel>.from(
              (map['country'] as List<dynamic>).map<CountryModel?>(
                (x) => CountryModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      sub_docquyen: map['sub_docquyen'] is bool
          ? map['sub_docquyen'] as bool
          : map['sub_docquyen']?.toString().toLowerCase() == 'true',
      chieurap: map['chieurap'] is bool
          ? map['chieurap'] as bool
          : map['chieurap']?.toString().toLowerCase() == 'true',
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension ItemModelConvert on ItemModel {
  ItemEntity toEntity() {
    return ItemEntity(
      tmdb: tmdb.toEntity(),
      modified: modified.toEntity(),
      id: id,
      name: name,
      slug: slug,
      originName: origin_name,
      type: type ?? 'N/A',
      posterUrl: poster_url,
      thumbUrl: thumb_url,
      time: time ?? 'N/A',
      episodeCurrent: episode_current ?? 'N/A',
      quality: quality ?? 'N/A',
      lang: lang ?? 'N/A',
      year: year,
      category: (category ?? []).map((e) => e.toEntity()).toList(),
      country: (country ?? []).map((e) => e.toEntity()).toList(),
      subDocquyen: sub_docquyen ?? false,
      chieurap: chieurap ?? false,
    );
  }
}

class TmDbModel {
  final num vote_average;

  TmDbModel({required this.vote_average});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'vote_average': vote_average};
  }

  factory TmDbModel.fromMap(Map<String, dynamic> map) {
    return TmDbModel(
      vote_average: map['vote_average'] is num
          ? map['vote_average']
          : num.tryParse(map['vote_average']?.toString() ?? '0') ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory TmDbModel.fromJson(String source) =>
      TmDbModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

extension TmDbModelConvert on TmDbModel {
  TmDbEntity toEntity() {
    return TmDbEntity(voteAverage: vote_average);
  }
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

extension ModifiedModelConvert on ModifiedModel {
  ModifiedEntity toEntity() {
    return ModifiedEntity(time: time);
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String slug;

  CategoryModel({required this.id, required this.name, required this.slug});

  CategoryModel copyWith({String? id, String? name, String? slug}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }

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

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, slug: $slug)';

  @override
  bool operator ==(covariant CategoryModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.slug == slug;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ slug.hashCode;
}

extension CategoryModelConvert on CategoryModel {
  CategoryEntity toEntity() {
    return CategoryEntity(id: id, name: name, slug: slug);
  }
}

class CountryModel {
  final String id;
  final String name;
  final String slug;
  CountryModel({required this.id, required this.name, required this.slug});

  CountryModel copyWith({String? id, String? name, String? slug}) {
    return CountryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
    );
  }

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

  @override
  String toString() => 'CountryModel(id: $id, name: $name, slug: $slug)';

  @override
  bool operator ==(covariant CountryModel other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.slug == slug;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ slug.hashCode;
}

extension CountryModelConvert on CountryModel {
  CountryEntity toEntity() {
    return CountryEntity(id: id, name: name, slug: slug);
  }
}

class PaginationModel {
  final int totalItems;
  final int totalItemsPerPage;
  final int currentPage;
  final int totalPages;

  PaginationModel({
    required this.totalItems,
    required this.totalItemsPerPage,
    required this.currentPage,
    required this.totalPages,
  });

  PaginationModel copyWith({
    int? totalItems,
    int? totalItemsPerPage,
    int? currentPage,
    int? totalPages,
  }) {
    return PaginationModel(
      totalItems: totalItems ?? this.totalItems,
      totalItemsPerPage: totalItemsPerPage ?? this.totalItemsPerPage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalItems': totalItems,
      'totalItemsPerPage': totalItemsPerPage,
      'currentPage': currentPage,
      'totalPages': totalPages,
    };
  }

  factory PaginationModel.fromMap(Map<String, dynamic> map) {
    return PaginationModel(
      totalItems: map['totalItems'] as int,
      totalItemsPerPage: map['totalItemsPerPage'] as int,
      currentPage: map['currentPage'] as int,
      totalPages: map['totalPages'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaginationModel.fromJson(String source) =>
      PaginationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PaginationModel(totalItems: $totalItems, totalItemsPerPage: $totalItemsPerPage, currentPage: $currentPage, totalPages: $totalPages)';
  }

  @override
  bool operator ==(covariant PaginationModel other) {
    if (identical(this, other)) return true;

    return other.totalItems == totalItems &&
        other.totalItemsPerPage == totalItemsPerPage &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages;
  }

  @override
  int get hashCode {
    return totalItems.hashCode ^
        totalItemsPerPage.hashCode ^
        currentPage.hashCode ^
        totalPages.hashCode;
  }
}

extension PaginationModelConvert on PaginationModel {
  PaginationEntity toEntity() {
    return PaginationEntity(
      totalItems: totalItems,
      totalItemsPerPage: totalItemsPerPage,
      currentPage: currentPage,
      totalPages: totalPages,
    );
  }
}

// import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:flutter/foundation.dart';

// part 'new_movie_model.freezed.dart';
// part 'new_movie_model.g.dart';

// @freezed
// abstract class NewMovieModel with _$NewMovieModel {
//   const factory NewMovieModel({
//     required bool status,
//     required String msg,
//     required List<ItemModel> items,
//     required PaginationModel pagination,
//   }) = _NewMovieModel;

//   factory NewMovieModel.fromJson(Map<String, dynamic> json) =>
//       _$NewMovieModelFromJson(json);
// }

// extension NewMovieModelExtension on NewMovieModel {
//   NewMovieEntity toEntity() {
//     return NewMovieEntity(
//       items: items.map((e) => e.toEntity()).toList(),
//       pagination: pagination.toEntity(),
//     );
//   }
// }

// @freezed
// abstract class ItemModel with _$ItemModel {
//   const factory ItemModel({
//     required TmDbModel tmdb,
//     required ModifiedModel modified,
//     @JsonKey(name: '_id') required String id, // Ánh xạ đúng với JSON
//     required String name,
//     required String slug,
//     @JsonKey(name: 'origin_name') required String origin_name,
//     @JsonKey(defaultValue: 'unknown') required String? type, // Đã đúng
//     @JsonKey(name: 'poster_url') required String poster_url,
//     @JsonKey(name: 'thumb_url') required String thumbUrl,
//     @JsonKey(defaultValue: 'N/A') required String? time, // Cho phép null
//     @JsonKey(name: 'episode_current', defaultValue: 'N/A') required String? episode_current, // Cho phép null
//     @JsonKey(defaultValue: 'N/A') required String? quality, // Cho phép null
//     @JsonKey(defaultValue: 'N/A') required String? lang, // Cho phép null
//     required int year,
//     @JsonKey(defaultValue: []) required List<CategoryModel> category, // Thêm default
//     @JsonKey(defaultValue: []) required List<CountryModel> country, // Thêm default
//   }) = _ItemModel;

//   factory ItemModel.fromJson(Map<String, dynamic> json) =>
//       _$ItemModelFromJson(json);
// }

// extension ItemModelExtension on ItemModel {
//   ItemEntity toEntity() {
//     return ItemEntity(
//       tmdb: tmdb.toEntity(),
//       modified: modified.toEntity(),
//       id: id,
//       name: name,
//       slug: slug,
//       originName: origin_name,
//       type: type ?? '',
//       posterUrl: poster_url,
//       thumbUrl: thumbUrl,
//       time: time ?? '',
//       episodeCurrent: episode_current ?? ,
//       quality: quality ?? '',
//       lang: lang ?? '',
//       year: year,
//       category: category.map((e) => e.toEntity()).toList(),
//       country: country.map((e) => e.toEntity()).toList(),
//     );
//   }
// }

// @freezed
// abstract class TmDbModel with _$TmDbModel {
//   const factory TmDbModel({
//     required int vote_average,
//   }) = _TmDbModel;

//   factory TmDbModel.fromJson(Map<String, dynamic> json) =>
//       _$TmDbModelFromJson(json);
// }

// extension TmDbModelExtension on TmDbModel {
//   TmDbEntity toEntity() {
//     return TmDbEntity(voteAverage: vote_average);
//   }
// }

// @freezed
// abstract class ModifiedModel with _$ModifiedModel {
//   const factory ModifiedModel({
//     required String time,
//   }) = _ModifiedModel;

//   factory ModifiedModel.fromJson(Map<String, dynamic> json) =>
//       _$ModifiedModelFromJson(json);
// }

// extension ModifiedModelExtension on ModifiedModel {
//   ModifiedEntity toEntity() {
//     return ModifiedEntity(time: time);
//   }
// }

// @freezed
// abstract class CategoryModel with _$CategoryModel {
//   const factory CategoryModel({
//     required String id,
//     required String name,
//     required String slug,
//   }) = _CategoryModel;

//   factory CategoryModel.fromJson(Map<String, dynamic> json) =>
//       _$CategoryModelFromJson(json);
// }

// extension CategoryModelExtension on CategoryModel {
//   CategoryEntity toEntity() {
//     return CategoryEntity(id: id, name: name, slug: slug);
//   }
// }

// @freezed
// abstract class CountryModel with _$CountryModel {
//   const factory CountryModel({
//     required String id,
//     required String name,
//     required String slug,
//   }) = _CountryModel;

//   factory CountryModel.fromJson(Map<String, dynamic> json) =>
//       _$CountryModelFromJson(json);
// }

// extension CountryModelExtension on CountryModel {
//   CountryEntity toEntity() {
//     return CountryEntity(id: id, name: name, slug: slug);
//   }
// }

// @freezed
// abstract class PaginationModel with _$PaginationModel {
//   const factory PaginationModel({
//     required int totalItems,
//     required int totalItemsPerPage,
//     required int currentPage,
//     required int totalPages,
//   }) = _PaginationModel;

//   factory PaginationModel.fromJson(Map<String, dynamic> json) =>
//       _$PaginationModelFromJson(json);
// }

// extension PaginationModelExtension on PaginationModel {
//   PaginationEntity toEntity() {
//     return PaginationEntity(
//       totalItems: totalItems,
//       totalItemsPerPage: totalItemsPerPage,
//       currentPage: currentPage,
//       totalPages: totalPages,
//     );
//   }
// }
