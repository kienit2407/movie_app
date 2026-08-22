import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Một lớp hiển thị duy nhất cho trailer ở trang chi tiết và dialog xem nhanh.
///
/// YoutubePlayer đã cung cấp nút play/pause ở giữa; thanh dưới chỉ giữ thời
/// gian và một thanh tua để không tạo thêm nhiều bộ điều khiển chồng nhau.
class MovieTrailerPlayer extends StatelessWidget {
  const MovieTrailerPlayer({
    super.key,
    required this.controller,
    required this.onReady,
  });

  final YoutubePlayerController controller;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      onReady: onReady,
      bottomActions: const [
        SizedBox(width: 8),
        CurrentPosition(),
        SizedBox(width: 8),
        ProgressBar(isExpanded: true),
        SizedBox(width: 8),
        RemainingDuration(),
        SizedBox(width: 8),
      ],
    );
  }
}
