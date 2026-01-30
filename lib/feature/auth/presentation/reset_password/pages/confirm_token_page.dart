// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
// import 'package:movie_app/common/components/background/app_back_ground.dart';
// import 'package:movie_app/common/components/button/app_back_button.dart';
// import 'package:movie_app/common/components/button/app_button.dart';
// import 'package:movie_app/common/components/loading/custom_loading.dart';
// import 'package:movie_app/common/components/text_field/app_email_textfield.dart';
// import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
// import 'package:movie_app/core/config/themes/app_color.dart';
// import 'package:movie_app/core/config/utils/animated_dialog.dart';
// import 'package:movie_app/feature/auth/data/models/confirm_token.dart';
// import 'package:movie_app/feature/auth/presentation/reset_password/bloc/confirm_token_cubit.dart';
// import 'package:movie_app/feature/auth/presentation/reset_password/bloc/confirm_token_state.dart';
// import 'package:movie_app/feature/auth/presentation/reset_password/pages/new_password_page.dart';

// class ConfirmTokenPage extends StatefulWidget {
//   const ConfirmTokenPage({super.key, required this.email});

//   final String email;

//   @override
//   State<ConfirmTokenPage> createState() => _ConfirmTokenPageState();
// }

// class _ConfirmTokenPageState extends State<ConfirmTokenPage> {
//   final _tokenControllor = TextEditingController();
//   @override
//   void dispose() {
//     _tokenControllor.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Scaffold(
//           body: Stack(
//             children: [
//               const AppBackGround(), 
//               _buildOverlay(),
//               _buildMainContent(),
//               const AppBackButton(),
//               _handleLoading(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildMainContent() {
//     return BlocListener<ConfirmTokenCubit, ConfirmTokenState>(
//       listener: (context, state) => _hangleValidateEmail(context, state),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 60),
//               const Text(
//                 'Enter your OPT is sent to email!',
//                 style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
//               ),
//               Text(
//                 'Enter 6 digit code that your receive on your email (${widget.email}).',
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 20),
//               AppEmailTextfield(controller: _tokenControllor,),
//               Spacer(),
//               AppButton(
//                 onPressed: () {
//                   final input = ConfirmToken(
//                     email: widget.email, 
//                     token: _tokenControllor.text.trim()
//                   );
//                   context.read<ConfirmTokenCubit>().confirmWithTokenToResetPassword(input);
//                 }, 
//                 title: 'Confirm'),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _handleLoading (){
//     return BlocBuilder<ConfirmTokenCubit , ConfirmTokenState>(
//       builder: (context, state) {
//         final isLoading = state is ConfirmTokenLoading;
//         return Visibility(
//           visible: isLoading,
//           child: CustomLoading()
//         );
//       }
//     );
//   }
//   Widget _buildOverlay() => Container(
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         colors: [AppColor.bgApp, AppColor.buttonColor.withOpacity(0.3)],
//         begin: Alignment.bottomCenter,
//         end: Alignment.topCenter,
//       ),
//     ),
//   );
//   void _hangleValidateEmail(BuildContext context, ConfirmTokenState state) {
//     if (state is ConfirmTokenValidErrol) {
//       final errols = state.errolConfirmToken;
//       final errolKey = errols.keys.first;
//       if (state.errolConfirmToken.containsKey(errolKey)) {
//         showAnimatedDialog(
//           context: context,
//           dialog: AppAlertDialog(
//             content: state.errolConfirmToken[errolKey],
//             title: 'Warning!',
//           ),
//         );
//       }
//     }
//     if (state is ConfirmTokenFailure) {
//       showAnimatedDialog(
//         context: context,
//         dialog: AppAlertDialog(content: state.messages, title: 'Warning!'),
//       );
//     }
//     if (state is ConfirmTokenSuccessfull) {
//         showAnimatedDialog(
//         context: context,
//         dialog: AppAlertDialog(content: 'Successfully. Let enter your new password', title: 'Notification!' ),
//       );
//       Future.delayed(Duration(seconds: 2), () {
//         AppNavigator.pushReplacement(context, const NewPasswordPage());
//       },);
//     }
//   }
// }