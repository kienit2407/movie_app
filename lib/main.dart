import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/core/config/themes/app_theme.dart';
import 'package:movie_app/presentation/splash/pages/splash.dart';

void main() {
  runApp(const MovieApp());
}
class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle( 
      const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      )
    );
    return MaterialApp(
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}