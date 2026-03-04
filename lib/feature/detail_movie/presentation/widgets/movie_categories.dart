import 'package:flutter/material.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

class MovieCategories extends StatelessWidget {
  final List<CategoryModel> categories;

  const MovieCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 5,
      runSpacing: 5,
      children: List.generate(categories.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            categories[index].name,
            style: const TextStyle(fontSize: 9, color: Colors.white),
          ),
        );
      }),
    );
  }
}
