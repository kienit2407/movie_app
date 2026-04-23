import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy padding top (safearea) để tính toán vị trí chính xác nếu cần,
    // nhưng ở đây ta dùng SafeArea(top: false) như code cũ của bạn.
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: const Color(0xff272A39),
        highlightColor: const Color(0xff191A24).withOpacity(0.2),
      ),
      child: SafeArea(
        top:
            false, // Giữ nguyên theo thiết kế của bạn để background tràn lên status bar
        child: SingleChildScrollView(
          physics:
              const NeverScrollableScrollPhysics(), // Skeleton không nên cuộn được
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // 1. Poster/Hero chính
              SizedBox(
                height: h * 0.60,
                width: w,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  // 👇 SỬA TỪ IMAGE.NETWORK THÀNH CONTAINER
                  child: Container(
                    // Bí quyết: Phải có color để Skeletonizer nhận diện khối
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. Category chips (Dùng text thật để lấy shape)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    _ChipFake('Action'),
                    _ChipFake('Drama'),
                    _ChipFake('Comedy'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Title + Subtitle (Text thật)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      'Movie title placeholder',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Original name placeholder name',
                      maxLines: 1,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Info pills
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _PillFake('iMdB 8.8'),
                    _PillFake('HD'),
                    _PillFake('2025'),
                    _PillFake('120 phút'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 5. Dot indicators
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (_) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        width: 10, // Sửa lại size cho giống dot indicator thật
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          // 👇 BẮT BUỘC PHẢI THÊM COLOR VÀO ĐÂY
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 6. Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: null, // Disable để hiện skeleton block
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Cần màu nền
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Xem phim'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Thông tin'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 7. Section preview list
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Phim Hàn Quốc',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text('Xem tất cả'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: h * .28,
                  child: Row(
                    children: List.generate(3, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 2 ? 0 : 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  // 👇 SỬA TỪ IMAGE.NETWORK THÀNH CONTAINER
                                  child: Container(
                                    // Bí quyết: Phải có color
                                    color: Colors.transparent,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Movie name placeholder',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Origin name',
                                maxLines: 1,
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget cho category chips
class _ChipFake extends StatelessWidget {
  final String t;
  const _ChipFake(this.t);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color:
            Colors.transparent, // 👉 Cần color nền để hiện khối block hoàn toàn
        borderRadius: BorderRadius.circular(8),
        // Không cần border nữa vì màu nền sẽ tạo ra khối shimmer đẹp hơn
      ),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.transparent,
        ), // Chữ trong suốt để lấy shape
      ),
    );
  }
}

// Helper widget cho info pills
class _PillFake extends StatelessWidget {
  final String t;
  const _PillFake(this.t);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent, // 👉 Cần color nền
        borderRadius: BorderRadius.circular(20), // Bo tròn dạng pill
      ),
      child: Text(
        t,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.transparent,
        ), // Chữ trong suốt
      ),
    );
  }
}
