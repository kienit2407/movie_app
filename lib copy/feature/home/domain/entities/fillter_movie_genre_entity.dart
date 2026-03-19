import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
class FillterMovieGenreEntity {
  final List<ItemEntity> items;
  final String titlePage;
  final ParamsEntity params;

  FillterMovieGenreEntity({required this.items, required this.titlePage, required this.params});
}

class ParamsEntity {
  final PaginationEntity pagination;
  ParamsEntity({required this.pagination});
}