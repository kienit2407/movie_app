import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:movie_app/common/components/loading/custom_loading.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.onPressed, required this.title});
  final String title;
  final VoidCallback onPressed;
  final bool isloaing = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(60)),
      child:Text(title)
    );
  }
}
