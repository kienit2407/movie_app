import 'package:flutter/material.dart';
import 'package:movie_app/common/components/app_back_button.dart';
import 'package:movie_app/common/components/app_button.dart';
import 'package:movie_app/common/components/app_email_textfield.dart';
import 'package:movie_app/common/components/app_password_textfield.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/auth/sign_in/widgets/app_button_forgot.dart';
import 'package:movie_app/feature/auth/sign_in/widgets/app_check_box.dart';
import 'package:movie_app/feature/auth/sign_in/widgets/app_divide.dart';
import 'package:movie_app/feature/auth/sign_in/widgets/app_option.dart';
import 'package:movie_app/feature/auth/sign_in/widgets/app_to_sign_up.dart';
import 'package:movie_app/feature/auth/sign_up/pages/widgets/app_fullname_textfield.dart';
import 'package:movie_app/feature/auth/sign_up/pages/widgets/app_to_sign_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _controllorFullname = TextEditingController();
  final _controllorEmail = TextEditingController();
  final _controllorPassword = TextEditingController();

  @override
  void dispose() {
    _controllorFullname.dispose();
    _controllorEmail.dispose();
    _controllorPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImage.splashBackground),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.bgApp,
                    AppColor.buttonColor.withOpacity(0.3),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/splash_logo.png',
                        width: 150,
                      ),
                      //logo a
                      Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 30),
                      AppFullnameTextfield(controller: _controllorFullname),
                      SizedBox(height: 20),
                      AppEmailTextfield(controller: _controllorEmail),
                      SizedBox(height: 20),
                      AppPasswordTextfield(controller: _controllorPassword),
                      SizedBox(height: 40),
                      AppButton(onPressed: () {}, title: 'Sign up'),
                      SizedBox(height: 30),
                      AppDivide(),
                      SizedBox(height: 30),
                      AppOption(),
                      SizedBox(height: 30),
                      AppToSignIn(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              child: SafeArea(
                child: AppBackButton(),
                )
              ),
          ],
        ),
      ),
    );
  }
}
