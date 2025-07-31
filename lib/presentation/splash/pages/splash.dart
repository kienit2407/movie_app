import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_splash.png')
                )
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                colors: [
                    AppColor.bgApp,
                    AppColor.buttonColor.withOpacity(0.5),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,

                )
              ),
            ),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/splash_logo.png')
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}