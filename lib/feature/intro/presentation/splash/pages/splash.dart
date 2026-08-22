import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/constants/const_globals.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

import 'package:movie_app/feature/home/notification/new_movie_notification_navigation.dart';

import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_state.dart';

class StartupSplashOverlay extends StatefulWidget {
  const StartupSplashOverlay({super.key});

  @override
  State<StartupSplashOverlay> createState() => _StartupSplashOverlayState();
}

class _StartupSplashOverlayState extends State<StartupSplashOverlay> {
  static const _fadeDuration = Duration(milliseconds: 600);

  bool _isExiting = false;
  bool _isRemoved = false;
  bool _handled = false;

  Future<void> _finishSplash() async {
    if (_handled) return;

    _handled = true;

    // Nếu app được mở từ notification thì
    // chuẩn bị route phía dưới Splash trước.
    final route = NewMovieNotificationNavigation.takeRouteAfterSplash();

    if (route != AppRoutes.home) {
      context.push(route);
    }

    if (!mounted) return;

    // Bắt đầu fade toàn bộ splash.
    setState(() {
      _isExiting = true;
    });

    await Future.delayed(_fadeDuration);

    if (!mounted) return;

    // Xóa Splash hoàn toàn khỏi widget tree.
    setState(() {
      _isRemoved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRemoved) {
      return const SizedBox.shrink();
    }

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          _finishSplash();
        }

        // Nếu SplashCubit của bạn còn state
        // authenticated/ready khác thì gọi
        // _finishSplash() ở đó luôn.
      },
      child: AnimatedOpacity(
        opacity: _isExiting ? 0 : 1,
        duration: _fadeDuration,
        curve: Curves.easeInOutCubic,

        // Trong thời gian Splash còn tồn tại,
        // không cho user bấm xuống Home phía dưới.
        child: AbsorbPointer(
          absorbing: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.bgApp, AppColor.buttonColor],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: AnimatedScale(
              scale: _isExiting ? 1.08 : 1,
              duration: _fadeDuration,
              curve: Curves.easeInOutCubic,
              child: Padding(
                padding: EdgeInsets.only(top: 300.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: AssetImage(AppImage.splashIcon),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Text(
                      Global.instance.appName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.secondColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
