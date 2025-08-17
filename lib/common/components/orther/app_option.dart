import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/core/config/assets/app_icon.dart';

class AppOption extends StatelessWidget {
  const AppOption({super.key,});
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 30,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(
          onTap: () => context.read<AuthWithSocialCubit>().signInWithGoogle(),
          iconUrl: AppIcon.appIconGoogle,
        ),
        _socialButton(onTap: () => context.read<AuthWithSocialCubit>().signInWithFacebook(), 
          iconUrl: AppIcon.appIconFacebook
        ),
      ],
    );
  }

  Widget _socialButton({required VoidCallback onTap, required String iconUrl}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(15)),
          settings: LiquidGlassSettings(
            glassColor: Colors.white10,
            blur: 2,
            lightAngle: 20,
            lightIntensity: 1,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 33,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffA0A0A0).withOpacity(.3)),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Image.asset(iconUrl, height: 28),
          ),
        ),
      ),
    );
  }
}
