import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppButtonForgot extends StatelessWidget {
  const AppButtonForgot({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: AppColor.secondColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
