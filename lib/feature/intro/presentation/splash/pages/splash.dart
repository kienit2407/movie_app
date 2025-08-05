import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/components/custom_loading.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/routes/navhost/pages/nav_host.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/pages/sign_in.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_state.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if(state is UnAuthenticated){
              AppNavigator.pushReplacement(
                context,
                SignInPage()
              );
            }
            if(state is Authenticated){
              AppNavigator.pushReplacement(
                context,
                NavHost()
              );
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
                  )
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImage.splashLogo)
                      )
                    ),
                  ),
                  CustomLoading(
                  size: 70,
                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
- Cách để giảm tải data cho api
  + Dùng load trang thông minh: chỉ load 20 trang khi kéo xuống mới load thêm
  + Dùng cache của dio tự động xoá sau 30 phút
  + Gộp nhièu request lại 
  + Giới hạn thời gian request tránh bị overload server
 */