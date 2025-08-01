import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppToSignUp extends StatelessWidget {
  const AppToSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Sign up',
            style: TextStyle(
              color: AppColor.secondColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
