import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/background/app_back_ground.dart';
import 'package:movie_app/common/components/button/app_back_button.dart';
import 'package:movie_app/common/components/button/app_button.dart';
import 'package:movie_app/common/components/loading/custom_loading.dart';
import 'package:movie_app/common/components/text_field/app_email_textfield.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/themes/app_color.dart' show AppColor;
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/reset_password_cubit.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/reset_password_state.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/pages/confirm_token_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailControllor = TextEditingController();
  @override
  void dispose() {
    _emailControllor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Stack(
            children: [
              AppBackGround(), 
              _buildOverlay(),
              _buildMainContent(),
              const AppBackButton(),
              _handleLoading(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocListener<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) => _hangleValidateEmail(context, state),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Reset Password',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              const Text(
                'Enter your email for the verification process. We will send some codes to your email.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              AppEmailTextfield(controller: _emailControllor),
              Spacer(),
              AppButton(
                onPressed: () {
                  context.read<ResetPasswordCubit>().reqSendCodeReserPassword(_emailControllor.text);
                }, 
                title: 'Send Code'),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
  Widget _handleLoading (){
    return BlocBuilder<ResetPasswordCubit , ResetPasswordState>(
      builder: (context, state) {
        final isLoading = state is ResetPasswordLoading;
        return Visibility(
          visible: isLoading,
          child: CustomLoading()
        );
      }
    );
  }
  Widget _buildOverlay() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColor.bgApp, AppColor.buttonColor.withOpacity(0.3)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  );
  void _hangleValidateEmail(BuildContext context, ResetPasswordState state) {
    if (state is ResetPasswordValidErrol) {
      final errols = state.errolResetPassword;
      final errolKey = errols.keys.first;
      if (state.errolResetPassword.containsKey(errolKey)) {
        showAnimatedDialog(
          context: context,
          dialog: AppAlertDialog(
            content: state.errolResetPassword[errolKey],
            title: 'Warning!',
          ),
        );
      }
    }
    if (state is ResetPasswordFailure) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(content: state.messages, title: 'Warning!'),
      );
    }
    if (state is ResetPasswordSuccessfull) {
      showAnimatedDialog(
        context: context,
        dialog: AppAlertDialog(content: 'We sent code to your email. Pls check it !', title: 'Notification!'),
      );
      Future.delayed(Duration(seconds: 2), (){
        AppNavigator.pushReplacement(context, ConfirmTokenPage(email: _emailControllor.text.trim() ));
      });
    }
  }
}
