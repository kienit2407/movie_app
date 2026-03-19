import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_state.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/button/app_back_button.dart';
import 'package:movie_app/common/components/button/app_button.dart';
import 'package:movie_app/common/components/text_field/app_email_textfield.dart';
import 'package:movie_app/common/components/text_field/app_password_textfield.dart';
import 'package:movie_app/common/components/loading/custom_loading.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/routes/nav_host.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/feature/auth/data/models/sign_up_req.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_divide.dart';
import 'package:movie_app/common/components/orther/app_option.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/bloc/sign_up_cubit.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/bloc/sign_up_state.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/widgets/app_fullname_textfield.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/widgets/app_to_sign_in.dart';

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
            //Background
            _buildBackground(),
            //Overlay gradient
            _buildOverlay(),
            _buildMainContent(),
            AppBackButton(),
            _buildLoading(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return MultiBlocListener(
      listeners: [
        BlocListener<SignUpCubit, SignUpState>(
          listener: (context, signUpState) {
            _handleSignUpState(context, signUpState);
          },
        ),
        BlocListener<AuthWithSocialCubit, AuthWithSocialState>(
          listener: (context, authWithSocialState) {
            _handleAuthSocial(context, authWithSocialState);
          },
        ),
      ],
      child: Stack(children: [_buildContent()]),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiquidGlass(
                settings: LiquidGlassSettings(
                  blur: 3,
                  lightAngle: 120,
                  lightIntensity: 1,
                ),
                shape: LiquidRoundedSuperellipse(
                  borderRadius: Radius.circular(15),
                ),
                child: Image.asset(AppImage.splashLogo, width: 150),
              ),
              const SizedBox(height: 20),
              //logo a
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              AppFullnameTextfield(controller: _controllorFullname),
              const SizedBox(height: 20),
              AppEmailTextfield(controller: _controllorEmail),
              const SizedBox(height: 20),
              AppPasswordTextfield(controller: _controllorPassword),
              SizedBox(height: 40),
              AppButton(
                onPressed: () {
                  final signUpReq = SignUpReq(
                    fullname: _controllorFullname.text,
                    email: _controllorEmail.text,
                    password: _controllorPassword.text,
                  );
                  context.read<SignUpCubit>().signUp(signUpReq);
                },
                title: 'Sign up',
              ),
              const SizedBox(height: 30),
              AppDivide(),
              const SizedBox(height: 30),
              AppOption(),
              const SizedBox(height: 30),
              AppToSignIn(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignUpState(BuildContext context, SignUpState state) {
    if (state is SignUpValidErrol) {
      final errols = state.errolSignUp;
      final errolKey = errols.keys.first;
      if (state.errolSignUp.containsKey(errolKey)) {
        showAnimatedDialog(
          context: context,
          dialog: AppAlertDialog(
            content: state.errolSignUp[errolKey],
            title: 'Warning!',
          ),
        );
      }
    }
    if (state is SignUpFailure) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(content: state.messages, title: 'Warning!'),
      );
    }
    if (state is SignUpSuccessfull) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(
          icon: Icon(Iconsax.tick_circle, size: 30),
          content: 'Your account is ready to use!',
          title: 'Congratulations',
          buttonTitle: 'Continue',
        ),
      );
      _loginSuccessfully();
    }
  }

  void _handleAuthSocial(BuildContext context, AuthWithSocialState state) {
    if (state is AuthWithSocialFailure) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(content: state.messages, title: 'Warning!'),
      );
    }
    if (state is AuthWithSocialSuccessfull) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(
          icon: Icon(Iconsax.tick_circle, size: 30),
          content: 'Your account is ready to use!',
          title: 'Congratulations',
          buttonTitle: 'Continue',
        ),
      );
      _loginSuccessfully();
    }
  }

  Widget _buildBackground() => Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(AppImage.splashBackground),
        fit: BoxFit.cover,
      ),
    ),
  );
  Widget _buildOverlay() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColor.bgApp, AppColor.buttonColor.withOpacity(0.3)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  );
  Widget _buildLoading() {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, signUpState) {
        return BlocBuilder<AuthWithSocialCubit, AuthWithSocialState>(
          builder: (context, authSocialState) {
            final isLoading =
                signUpState is SignUpLoading ||
                authSocialState is AuthWithSocialLoading;
            return Visibility(visible: isLoading, child: CustomLoading());
          },
        );
      },
    );
  }
  void _loginSuccessfully (){
    Future.delayed(Duration(seconds: 1));
    AppNavigator.pushAndRemoveUtil(context, const NavHost());
  }
}



//áp dụng định lý 3 - 5 - 30 (trên 30 dòng, 5 props, 3 nơi sử dụng)