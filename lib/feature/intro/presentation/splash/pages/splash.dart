import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _animateOut = false;

  void _startExitAnimationAndNavigate() async {
    if (_animateOut) return;
    setState(() => _animateOut = true);

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is UnAuthenticated) {
            _startExitAnimationAndNavigate();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.bgApp,
                    AppColor.buttonColor.withOpacity(1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: _animateOut ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic,
              builder: (context, t, child) {
                final scale = 1.0 + (0.4 * t);
                final opacity = 1.0 - t;
                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImage.splashIcon),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
