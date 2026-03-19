import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppOverlay extends StatelessWidget {
  const AppOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 3,
        sigmaY: 3,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.bgApp, AppColor.buttonColor.withOpacity(0.3)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}
