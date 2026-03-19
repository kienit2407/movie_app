import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/common/helpers/sort_map.dart';
import 'package:movie_app/core/config/utils/list_gadient.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';

class MovieSectionWithScroll extends StatefulWidget {
  const MovieSectionWithScroll({super.key});
  @override
  State<MovieSectionWithScroll> createState() => _MovieSectionWithScrollState();
}

class _MovieSectionWithScrollState extends State<MovieSectionWithScroll> {
  // 1. Khai báo biến Ở ĐÂY (Trong State, không phải trong hàm build)
  late ScrollController _scrollController;
  double _scrollPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 2. Lắng nghe sự kiện cuộn
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        // Tính toán tỷ lệ
        double percent = maxScroll > 0 ? (currentScroll / maxScroll) : 0.0;
        percent = percent.clamp(0.0, 1.0);

        // Chỉ setState nếu giá trị thay đổi đáng kể (để tối ưu hiệu năng)
        if ((_scrollPercent - percent).abs() > 0.01) {
          setState(() {
            _scrollPercent = percent;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // 3. Nhớ dispose controller để tránh rò rỉ bộ nhớ
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What are you watching ?',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(SortMap.sortMovie.length, (index) {
              final sortMovie = SortMap.sortMovie[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == SortMap.sortMovie.length - 1 ? 0 : 10.w,
                ),
                child: GestureDetector(
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
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: Container(
            width: 56.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: _scrollPercent * (56.w - 22.w),
                  child: Container(
                    width: 22.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffe73827),
                          Color.fromARGB(255, 254, 136, 115),
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _movieThemeItem(Gradient gadient, String content) {
    return SizedBox(
      height: 102.h,
      width: 150.w,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                // lớp nền
                borderRadius: BorderRadius.circular(12.r),
                gradient: gadient,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 102.w,
              margin: EdgeInsets.only(left: 10.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  SizedBox(height: 5.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Watch More',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 9.sp,
                        ),
                      ),
                      SizedBox(width: 2.w),
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
