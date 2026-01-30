import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class OverlayGadient extends StatelessWidget {
  const OverlayGadient({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(.2),
                    Colors.transparent,
                    // Colors.transparent,
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          //Bottom Of Gadient Overlay
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(.9),
                    // Colors.transparent,
                    // Colors.transparent,
                    // AppColor.bgApp,
                    // AppColor.bgApp,
                    AppColor.bgApp,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
