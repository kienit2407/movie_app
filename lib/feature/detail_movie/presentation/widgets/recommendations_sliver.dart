import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_state.dart';
import 'package:movie_app/feature/detail_movie/presentation/widgets/recommendation_item.dart';

class RecommendationsSliver extends StatefulWidget {
  const RecommendationsSliver({super.key});

  @override
  State<RecommendationsSliver> createState() => _RecommendationsSliverState();
}

class _RecommendationsSliverState extends State<RecommendationsSliver> {
  int _firstBatchCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FetchFillterCubit>().stream.listen((state) {
        if (state is FetchFillterLoaded && _firstBatchCount == 0) {
          if (mounted) {
            setState(() {
              _firstBatchCount = state.items.length;
            });
          }
        }
      });
    });
  }

  Widget _buildIndicator() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      height: 30,
      width: double.infinity,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(width: 8),
          Text('Loading'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFillterCubit, FetchFillterState>(
      builder: (context, state) {
        if (state is FetchFillterLoading) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              maxCrossAxisExtent: 150,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return Shimmer.fromColors(
                baseColor: const Color(0xff272A39).withOpacity(.2),
                highlightColor: const Color(0xff191A24).withOpacity(.2),
                child: SizedBox(
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: 9),
          );
        }
        if (state is FetchFillterFailure) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Không thể tải đề xuất',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          );
        }
        if (state is FetchFillterLoaded) {
          final movies = state.items;
          if (movies.isEmpty) {
            return const SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Không có đề xuất',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            );
          }

          return MultiSliver(
            children: [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = movies[index];
                  return RecommendationItem(itemEntity: item);
                }, childCount: movies.length),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 0.55,
                ),
              ),
              if (state.isLoadingMore)
                SliverToBoxAdapter(child: _buildIndicator()),
            ],
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}
