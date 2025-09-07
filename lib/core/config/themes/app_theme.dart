import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppTheme {
  static final appTheme = ThemeData(
    useMaterial3: true,
    textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    scaffoldBackgroundColor: AppColor.bgApp, //<- đặt màu theme cho scaffold
    iconTheme: IconThemeData(color: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor.secondColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
      ),
    ),
    // appBarTheme: AppBarTheme() <- theme cho appbar
    // textTheme: TextTheme() //<- theme cho text
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColor.secondColor,
      brightness: Brightness.dark,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      focusColor: Colors.amber,
      hintStyle: TextStyle(color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white30.withOpacity(.3))
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColor.secondColor),
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(
      // selectionColor: AppColor.secondColor, //màu phần chọn
      // selectionHandleColor: AppColor.secondColor // màu 2 đầu mút
      cursorColor: Colors.white,
    )
    // colorScheme: ColorScheme(brightness: brightness, primary: primary, onPrimary: onPrimary, secondary: secondary, onSecondary: onSecondary, error: error, onError: onError, surface: surface, onSurface: onSurface) <- định nghĩa các bảng màu
    // brightness: Brightness.dark  <- đùng để cấu hình chế độ sáng tối
    // inputDecorationTheme: InputDecorationTheme() <- dùng để config input
    // cardTheme: CardThemeData() <- dùng để cấu hình card
    // iconTheme: IconThemeData() <- cấu hình icon
    // navigationBarTheme: NavigationBarThemeData() cấu hình theme cho navigatgion
  );
}
