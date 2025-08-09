import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_state.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/button/app_back_button.dart';
import 'package:movie_app/common/components/button/app_button.dart';
import 'package:movie_app/common/components/loading/custom_loading.dart';
import 'package:movie_app/common/components/text_field/app_email_textfield.dart';
import 'package:movie_app/common/components/text_field/app_password_textfield.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/assets/app_image.dart';
import 'package:movie_app/core/config/routes/navhost/pages/nav_host.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/feature/auth/data/models/sign_in_req.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/bloc/sign_in_cubit.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/bloc/sign_in_state.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_button_forgot.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_divide.dart';
import 'package:movie_app/common/components/orther/app_option.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/widgets/app_to_sign_up.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/widgets/app_fullname_textfield.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _controllorEmail = TextEditingController();
  final _controllorPassword = TextEditingController();

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
            _buildBackground(),
            _buildOverlay(),
            _buildMainContent(),
            AppBackButton(),
            _buildLoading()
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return MultiBlocListener(
      listeners: [
        BlocListener<SignInCubit, SignInState>(
          listener: (context, signInState) {
            _handleSignUpState(context, signInState);
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
              RepaintBoundary(
                child: LiquidGlass(
                  settings: LiquidGlassSettings(
                    lightAngle: 120,
                    lightIntensity: 1,
                  ),
                  shape: LiquidRoundedSuperellipse(
                    borderRadius: Radius.circular(15),
                  ),
                  child: Image.asset(AppImage.splashLogo, width: 150),
                ),
              ),
              //logo a
              const Text(
                'Login to Your Account',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              AppEmailTextfield(controller: _controllorEmail),
              const SizedBox(height: 20),
              AppPasswordTextfield(controller: _controllorPassword),
              const SizedBox(height: 45),
              AppButton(
                onPressed: () {
                  final signInReq = SignInReq(
                    email: _controllorEmail.text,
                    password: _controllorPassword.text,
                  );
                  context.read<SignInCubit>().signIn(signInReq);
                },
                title: 'Sign in',
              ),
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
    );
  }

  void _handleSignUpState(BuildContext context, SignInState state) {
    if (state is SignInValidErrol) {
      final errols = state.errolSignIn;
      final errolKey = errols.keys.first;
      if (state.errolSignIn.containsKey(errolKey)) {
        showAnimatedDialog(
          context: context,
          dialog: AppAlertDialog(
            content: state.errolSignIn[errolKey],
            title: 'Warning!',
          ),
        );
      }
    }
    if (state is SignInFailure) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(content: state.messages, title: 'Warning!'),
      );
    }
    if (state is SignInSuccessfull) {
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
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, signInState) {
        return BlocBuilder<AuthWithSocialCubit, AuthWithSocialState>(
          builder: (context, authSocialState) {
            final isLoading =
                signInState is SignInLoading ||
                authSocialState is AuthWithSocialLoading;
            return Visibility(visible: isLoading, child: CustomLoading());
          },
        );
      },
    );
  }

  void _loginSuccessfully() {
    Future.delayed(Duration(seconds: 1));
    AppNavigator.pushAndRemoveUtil(context, const NavHost());
  }
}
