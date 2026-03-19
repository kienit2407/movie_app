import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMovieGenre extends StatelessWidget {
  const ShimmerMovieGenre({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300, 
      highlightColor: Colors.grey.shade100,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .2,
        child: Wrap(
          spacing: 10,
          children: List.generate(20, (index) {
            return Container(
              width: 100,
              height: 30,
              color: Colors.amber,
            );
          })
        ),
      )
    );
  }
}