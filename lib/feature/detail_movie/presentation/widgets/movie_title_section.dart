import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class MovieTitleSection extends StatelessWidget {
  final String originName;
  final String name;

  const MovieTitleSection({
    super.key,
    required this.originName,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          originName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.secondColor,
          ),
        ),
      ],
    );
  }
}
