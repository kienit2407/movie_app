import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class MovieDescription extends StatefulWidget {
  final String content;

  const MovieDescription({super.key, required this.content});

  @override
  State<MovieDescription> createState() => _MovieDescriptionState();
}

class _MovieDescriptionState extends State<MovieDescription> {
  bool _isExpanded = false;

  String _cleanHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    String textWithoutTags = htmlString.replaceAll(exp, '');
    String textWithoutTagsSecond = textWithoutTags
        .replaceAll('&nbsp;', ' ')
        .trim();
    String textWithoutTagsThird = textWithoutTagsSecond
        .replaceAll('&#39;', ' ')
        .trim();
    return textWithoutTagsThird.replaceAll('&quot;', ' ').trim();
  }

  bool _shouldShowButton(String content) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: content,
        style: const TextStyle(fontSize: 12, height: 1.5),
      ),
      textDirection: Directionality.of(context),
      maxLines: 4,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32);
    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final cleanContent = _cleanHtmlTags(widget.content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới thiệu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.topCenter,
          child: Text(
            cleanContent,
            maxLines: _isExpanded ? null : 4,
            overflow: _isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        if (_shouldShowButton(cleanContent))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded ? 'Thu gọn' : 'Xem thêm',
                style: const TextStyle(
                  color: AppColor.secondColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
