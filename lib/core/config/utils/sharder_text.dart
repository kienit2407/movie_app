import 'package:flutter/material.dart';

class SharderText extends StatelessWidget {
  const SharderText({super.key, required this.child,  this.firtsColor,  this.secondsColor, required this.gradient});
  final Widget child;
  final Color? firtsColor;
  final Color? secondsColor;
  final Gradient gradient;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
      child: child,
    );
  }
}
