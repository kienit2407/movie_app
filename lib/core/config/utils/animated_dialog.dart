import 'package:flutter/material.dart';

Future<void> showAnimatedDialog({
  required BuildContext context,
  required Widget dialog,
}) async {
 await showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: '',
    context: context, 
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, a1, a2){
      return dialog;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}