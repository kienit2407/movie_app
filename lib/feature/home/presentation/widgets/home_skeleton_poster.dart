import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeletonPoster extends StatelessWidget {
  const HomeSkeletonPoster({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Shimmer.fromColors(
        baseColor: const Color(0xff272A39),
        highlightColor: const Color(0xff4A4E69),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
