import 'package:flutter/material.dart';

class AppNavigator {
  static Future<T?> pushReplacement<T extends Object?>(
    BuildContext context,
    Widget newRoute,
  ) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacement(MaterialPageRoute(builder: (context) => newRoute));
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget newRoute,
  ) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (context) => newRoute));
  }

  static Future<T?> pushAndRemoveUtil<T extends Object?>(
    BuildContext context,
    Widget newRoute,
  ) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => newRoute),
      (route) =>
          false, //<- dòng này báo cho flutter rằng hãy xoá hết những route cũ trong stack mà chỉ giữ lại những cái mới mà thôi. Nếu là true thì nó cũng giống push thông thường
    );
  }
}
