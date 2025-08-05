import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppNavigator.pop(context);
        },
        borderRadius: BorderRadius.circular(15),
        child: LiquidGlass(
          settings: LiquidGlassSettings(
            lightAngle: 120,
            lightIntensity: 1,
            
          ),
          shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white60.withOpacity(.2),
            child: const Icon(Iconsax.arrow_left_2_copy),
          ),
        ),
      ),
    );
  }
}
