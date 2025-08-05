import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_app/core/config/themes/app_theme.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/pages/splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // ensure flutter Initialized before of all 
  WidgetsFlutterBinding.ensureInitialized();
  //Next one load môi trường
  await dotenv.load();
  try {
    await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, //<- tránh trường hợp null và bị crash app
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  } catch (e) {
    print('Lỗi khi khởi tạo env: $e');
  }
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle( // <- custom status bar
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return BlocProvider(
      create: (context) => SplashCubit()..appStarted(), //<- khởi động app
      child: MaterialApp(
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    );
  }
}
