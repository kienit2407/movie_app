import 'package:flutter/widgets.dart';

class AppColor {
  AppColor._(); //private contructor -> ngăn việc tạo class bên ngoài nghĩa là nó đã là singleton là không cho phép tạo instance nên là nó cũng không cho phép tạo bên ngoài luôn
  static const bgApp = Color(0xff191A24);
  static const primaryColor = LinearGradient(
    colors: [
      Color(0xffec008c),
      Color(0xffF4347A),
      Color(0xfffc6767),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight
  );
  static const buttonColor = Color(0xff36383F);
  static const secondColor = Color(0xffE21120);
  static const thirdColor = Color(0xFFFF9E9E);
  static const firstColor = Color(0xFFC77DFF);
  static const fourthColor = Color(0xFFFFD275);
}