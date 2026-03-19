import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppNavigator {
  static void pushReplacement (BuildContext context, Widget newRoute){
    Navigator.pushReplacement(
      context, MaterialPageRoute(
        builder: (context) => newRoute
      )
    );
  }

  static void pop (BuildContext context) {
    Navigator.pop(context);
  }

  static void push (BuildContext context, Widget newRoute){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => newRoute
      ) 
    );
  }

  static void pushAndRemoveUtil (BuildContext context, Widget newRoute){
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => newRoute
      ),
      (route) => false, //<- dòng này báo cho flutter rằng hãy xoá hết những route cũ trong stack mà chỉ giữ lại những cái mới mà thôi. Nếu là true thì nó cũng giống push thông thường
    );
  }


}