import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
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
    if (_animateOut) return; // tránh chạy nhiều lần
    setState(() => _animateOut = true);

    // chờ animation kết thúc rồi mới navigate
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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

            // Logo animate
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: _animateOut ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutCubic,
              builder: (context, t, child) {
                final scale = 1.0 + (0.4 * t);      // 1 -> 1.4
                final opacity = 1.0 - t;           // 1 -> 0
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
