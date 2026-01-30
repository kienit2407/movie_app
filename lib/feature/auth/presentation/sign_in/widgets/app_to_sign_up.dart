// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
// import 'package:movie_app/core/config/themes/app_color.dart';
// import 'package:movie_app/feature/auth/presentation/sign_up/pages/sign_up.dart';

// class AppToSignUp extends StatelessWidget {
//   const AppToSignUp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return  Text.rich(
//       TextSpan(
//         children: [
//       const TextSpan(
//           text: 'Don\'t have an account? ',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         TextSpan(
//           text:  'Sign up',
//           style: TextStyle(
//               color: AppColor.secondColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           recognizer: TapGestureRecognizer()..onTap = (){
//             AppNavigator.push(
//               context,
//               const SignUpPage()
//             );
//           }
//         )
//       ],
//       )
//     );
//   }
// }
// //Cách2
// // Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Text(
// //           'Don\'t have an account?',
// //           style: TextStyle(fontWeight: FontWeight.w700),
// //         ),
// //         TextButton(
// //           key: ValueKey(context),
// //           onPressed:() {
// //             AppNavigator.push(
// //               context,
// //               SignUpPage()
// //             );
// //           },
// //           child: Text(
// //             'Sign up',
// //             style: TextStyle(
// //               color: AppColor.secondColor,
// //               fontWeight: FontWeight.w600,
// //               fontSize: 14,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );