import 'package:flutter/material.dart';

Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required Widget dialog,
  bool barrierDismissible = true,
}) async {
  return showGeneralDialog<T>(
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    context: context,
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, a1, a2) {
      return dialog;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
