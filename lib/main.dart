
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
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
import 'package:movie_app/feature/home/presentation/bloc/detail_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/latest_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/pages/home_page.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/firebase_options.dart';

Future<void> main() async {
  // ensure flutter Initialized before of all
  WidgetsFlutterBinding.ensureInitialized();
  //Init get it để tiêm phụ thuộc
  await initializeGetit(); //<- hàm thuần
  await Hive.initFlutter();
  //Next one load môi trường
  await dotenv.load(fileName:'assets/.env');
  // //khởi động biến môi trường cho supabase
  await supaBaseInit.initSupabase();
  //khởi động firebase
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // DevicePreview(
      const MovieApp()
      // enabled: !kReleaseMode,
      // builder: (context) => const MovieApp()
    // )
  );
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
        BlocProvider(create: (context) => LatestMovieCubit()..getLatestMovie()),
        BlocProvider(create: (context) => DetailMovieCubit()),
      ],
      child: MaterialApp(
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}



