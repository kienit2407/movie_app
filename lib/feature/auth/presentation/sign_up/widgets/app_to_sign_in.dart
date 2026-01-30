import 'package:flutter/material.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/pages/sign_in.dart';

class AppToSignIn extends StatelessWidget {
  const AppToSignIn({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: () {
            AppNavigator.pop(context);
          },
          child: const Text(
            'Sign in',
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
