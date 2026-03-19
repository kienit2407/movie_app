import 'package:flutter/material.dart';
import 'package:movie_app/core/config/assets/app_image.dart';

class AppBackGround extends StatelessWidget {
  const AppBackGround({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImage.splashBackground),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
