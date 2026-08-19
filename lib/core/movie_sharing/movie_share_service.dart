import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MovieShareService {
  const MovieShareService._();

  static const _shareHost = 'movieapp-c3847.web.app';

  static Uri movieLink(String slug) => Uri(
    scheme: 'https',
    host: _shareHost,
    pathSegments: ['movie', slug.trim()],
  );

  static Future<void> shareMovie({
    required BuildContext context,
    required String slug,
    required String movieName,
  }) async {
    final link = movieLink(slug);

    if (!context.mounted) return;
    final renderObject = context.findRenderObject();
    final box = renderObject is RenderBox ? renderObject : null;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: movieName,
          subject: 'Xem $movieName trên Liquid Phim',
          uri: link,
          sharePositionOrigin: origin,
        ),
      );
      return;
    } catch (error, stackTrace) {
      debugPrint('[MovieShare] Sharing web link failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Không thể mở bảng chia sẻ.')),
    );
  }
}
