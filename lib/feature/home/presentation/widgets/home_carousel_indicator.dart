import 'package:flutter/material.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';

class HomeCarouselIndicator extends StatelessWidget {
  final List<ItemEntity> movies;
  final int currentIndex;

  const HomeCarouselIndicator({
    super.key,
    required this.movies,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(movies.length > 5 ? 5 : movies.length, (index) {
        final actualIndex = movies.length > 5
            ? (currentIndex + index - 2) % movies.length
            : index;
        final isActive = movies.length > 5
            ? index == 2
            : actualIndex == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        );
      }),
    );
  }
}
