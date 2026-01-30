import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AllMovieLoadingSkeleton extends StatelessWidget {
  const AllMovieLoadingSkeleton({super.key});

  static const _base = Color(0xFF141827);     // nền tối
  static const _hi   = Color(0xFF2A2F42);     // sáng nhẹ

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Shimmer(
        // Shimmer “mịn” kiểu iOS
        period: const Duration(milliseconds: 1400),
        direction: ShimmerDirection.ltr,
        gradient: LinearGradient(
          begin: const Alignment(-1.0, -0.25),
          end: const Alignment(1.0, 0.25),
          colors: [
            _base.withOpacity(0.20),
            _hi.withOpacity(0.55),
            _base.withOpacity(0.20),
          ],
          stops: const [0.2, 0.5, 0.8],
        ),
        child: GridView.builder(
          // quan trọng: vì đang nằm trong CustomScrollView/sliver
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
            maxCrossAxisExtent: 150,
            childAspectRatio: 0.55,
          ),
          itemCount: 9,
          itemBuilder: (_, __) => const _MovieCardSkeleton(),
        ),
      ),
    );
  }
}

class _MovieCardSkeleton extends StatelessWidget {
  const _MovieCardSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget line({required double h, required double w}) {
      return Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          // để màu TRẮNG mờ -> shimmer sẽ “ăn” theo alpha, nhìn mịn hơn
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // nền trắng mờ để shimmer chạy, thêm border mờ giống ảnh
              color: Colors.white.withOpacity(0.10),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        line(h: 12, w: double.infinity),
        const SizedBox(height: 6),
        line(h: 10, w: 90),
      ],
    );
  }
}
