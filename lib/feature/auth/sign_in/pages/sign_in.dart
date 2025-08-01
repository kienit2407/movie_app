import 'package:flutter/material.dart';
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

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _controllorEmail = TextEditingController();
  final _controllorPassword = TextEditingController();

  bool _isChecked = false;
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
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/splash_logo.png', width: 200),
                    //logo a
                    Text(
                      'Login to Your Account',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 30),
                    AppEmailTextfield(controller: _controllorEmail),
                    SizedBox(height: 20),
                    AppPasswordTextfield(controller: _controllorPassword),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: AppCheckBox(
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                        isChecked: _isChecked,
                      ),
                    ),
                    AppButton(onPressed: () {}, title: 'Sign in'),
                    AppButtonForgot(onPressed: () {}),
                    AppDivide(),
                    SizedBox(height: 30),
                    AppOption(),
                    SizedBox(height: 30),
                    AppToSignUp(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
