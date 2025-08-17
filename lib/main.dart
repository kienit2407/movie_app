
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/network/init_supabase.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/themes/app_theme.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/confirm_token_cubit.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/reset_password_cubit.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/pages/reset_password_page.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/bloc/sign_in_cubit.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/bloc/sign_up_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/pages/splash.dart';
import 'package:movie_app/firebase_options.dart';

Future<void> main() async {
  // ensure flutter Initialized before of all
  WidgetsFlutterBinding.ensureInitialized();
  //Init get it để tiêm phụ thuộc
  await initializeGetit(); //<- hàm thuần
  //Next one load môi trường
  await dotenv.load(fileName:'assets/.env');
  // //khởi động biến môi trường cho supabase
  await supaBaseInit.initSupabase();
  //khởi động firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      // <- custom status bar
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()..appStarted()), //<- khởi động app, để xét xem có người dùng chưa
        BlocProvider(create: (context) => SignUpCubit()),
        BlocProvider(create: (context) => SignInCubit()),
        BlocProvider(create: (context) => AuthWithSocialCubit()),
        BlocProvider(create: (context) => ResetPasswordCubit()),
        BlocProvider(create: (context) => ConfirmTokenCubit()),
      ],
      child: MaterialApp(
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    );
  }
}

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: 300,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImage.splashBackground),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              PolkBackGround(
                dotColor: Colors.black,
                dotRadius: 0.5,
                spacing: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      // Colors.transparent,
                      AppColor.bgApp.withOpacity(0.8),
                    ],
                    stops: [0.7, 1.0],
                    radius: .7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PolkBackGround extends StatelessWidget {
  const PolkBackGround({
    super.key,
    this.dotColor = Colors.white,
    this.dotRadius = 4,
    this.spacing = 40,
  });
  final Color dotColor;
  final double spacing;
  final double dotRadius;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PolkaDotPainter(
        dotColor: dotColor,
        dotRadius: dotRadius,
        spacing: spacing,
      ),
      child: SizedBox.expand(), // full screen
    );
  }
}

class PolkaDotPainter extends CustomPainter {
  final double dotRadius;
  final double spacing;
  final Color dotColor;

  PolkaDotPainter({
    required this.dotRadius,
    required this.spacing,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
