import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

class SearchMoviesPage {
  final List<MovieModel> movies;
  final bool hasMore;

  const SearchMoviesPage({required this.movies, required this.hasMore});
}
