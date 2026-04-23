import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/common/helpers/sort_map.dart';
import 'package:movie_app/core/config/utils/list_gadient.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';

class RecommendScrollCubit extends Cubit<double> {
  RecommendScrollCubit() : super(0.0);

  void updatePercent(double value) {
    final next = value.clamp(0.0, 1.0);
    if ((next - state).abs() <= 0.01) return;
    emit(next);
  }
}

class MovieSectionWithScroll extends StatefulWidget {
  const MovieSectionWithScroll({super.key});
  @override
  State<MovieSectionWithScroll> createState() => _MovieSectionWithScrollState();
}

class _MovieSectionWithScrollState extends State<MovieSectionWithScroll> {
  late ScrollController _scrollController;
  late final RecommendScrollCubit _scrollCubit;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollCubit = RecommendScrollCubit();

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        double percent = maxScroll > 0 ? (currentScroll / maxScroll) : 0.0;
        _scrollCubit.updatePercent(percent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scrollCubit,
      child: BlocBuilder<RecommendScrollCubit, double>(
        builder: (context, scrollPercent) => Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Text(
                'Bạn muốn xem gì hôm nay?',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
            SingleChildScrollView(
              primary: false,
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10.w,
                children: List.generate(SortMap.sortMovie.length, (index) {
                  final sortMovie = SortMap.sortMovie[index];
                  return GestureDetector(
                    onTap: () {
                      final result = FillterMovieReq(
                        typeList: sortMovie.keys.single,
                        fillterType: Filltertype.list,
                      );
                      AppNavigator.push(
                        context,
                        AllMoviePage(fillterReq: result),
                      );
                    },
                    child: _movieThemeItem(
                      ListGadient.listGadient[index %
                          ListGadient.listGadient.length],
                      SortMap.sortMovie[index].values.single,
                    ),
                  );
                }),
              ),
            ),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: scrollPercent * (40.w - 15.w),
                      child: Container(
                        width: 15.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFC77DFF),
                              Color(0xFFFF9E9E),
                              Color(0xFFFFD275),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _movieThemeItem(Gradient gadient, String content) {
    return SizedBox(
      height: 110.h,
      width: 150.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.r),
                  topRight: Radius.circular(30.r),
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(15.r),
                ),
                gradient: gadient,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100.r),
                  topRight: Radius.circular(30.r),
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(100.r),
                ),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(left: 10.w),
              child: Column(
                spacing: 5.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Xem Thêm',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 9.sp,
                        ),
                      ),
                      Icon(Iconsax.arrow_right_3_copy, size: 14.sp),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
