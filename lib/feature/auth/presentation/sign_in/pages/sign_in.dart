import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:movie_app/common/components/app_back_button.dart';
import 'package:movie_app/common/components/app_button.dart';
import 'package:movie_app/common/components/app_email_textfield.dart';
import 'package:movie_app/common/components/app_password_textfield.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_button_forgot.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_check_box.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_divide.dart';
import 'package:movie_app/common/components/app_option.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_to_sign_up.dart';
import 'package:reactive_button/reactive_button.dart';

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
  void dispose() {
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
                      LiquidGlass(
                        settings: LiquidGlassSettings(
                          lightAngle: 120,
                          lightIntensity: 1
                        ),
                        shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(15)),
                        child: Image.asset(AppImage.splashLogo, width: 150),
                      ),
                      //logo a
                      const Text(
                      'Login to Your Account',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),
                      AppEmailTextfield(
                        controller: _controllorEmail,
      
                      ),
                      const SizedBox(height: 20),
                      AppPasswordTextfield(
                        controller: _controllorPassword,
                        
                      ),
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
                      const SizedBox(height: 30),
                      AppOption(),
                      const SizedBox(height: 30),
                      AppToSignUp(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _signinButton (){
    return ReactiveButton(
      onPressed:() async {}, 
      onSuccess: (){}, 
      onFailure: (String error){}
    );
  }
}
