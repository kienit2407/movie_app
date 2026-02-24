import 'package:flutter/material.dart';
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
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Bạn muốn xem gì hôm nay?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        // --- LIST ---
        SingleChildScrollView(
          controller: _scrollController, // Gắn controller đã khai báo ở trên
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: List.generate(SortMap.sortMovie.length, (index) {
              final sortMovie = SortMap.sortMovie[index];
              return GestureDetector(
                onTap: () {
                  final result = FillterMovieReq(
                    typeList: sortMovie.keys.single,
                    fillterType: Filltertype.list,
                  );
                  AppNavigator.push(context, AllMoviePage(fillterReq: result));
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

        // --- INDICATOR (THANH CUỘN) ---
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                Positioned(
                  // Công thức: Tỷ lệ * (Độ dài thanh xám - Độ dài thanh đỏ)
                  left: _scrollPercent * (40 - 15),
                  child: Container(
                    width: 15,
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFC77DFF), // Tím
                          Color(0xFFFF9E9E), // Hồng cam (ở giữa)
                          Color(0xFFFFD275),
                        ], // Vàng],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(2),
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
    final w = MediaQuery.sizeOf(context).width;
    final scale = (w / 414).clamp(0.85, 1.15);

    return SizedBox(
      height: 110 * scale, // ✅ ổn định
      width: 150 * scale,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                // lớp nền
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(15),
                ),
                gradient: gadient,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                // lớp nền
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(100),
                ),
                gradient: RadialGradient(
                  center: Alignment.center, // Tâm điểm sáng nằm giữa
                  radius: 0.8, // Độ lan toả (0.8 là lan ra khoảng 80% hộp)
                  colors: [
                    // Màu ở tâm: Trắng mờ (để tạo cảm giác sáng lên)
                    Colors.white.withOpacity(0.2),

                    // Màu ở ngoài rìa: Trong suốt (để lộ màu nền bên dưới)
                    Colors.transparent,
                  ],
                  // (Tuỳ chọn) stops: [0.0, 1.0], // Để kiểm soát độ chuyển màu gắt hay mềm
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 100,
              margin: EdgeInsets.only(left: 10),
              child: Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Xem Thêm',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                      Icon(Iconsax.arrow_right_3_copy, size: 14),
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
