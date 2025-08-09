import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        _socialButton(onTap: () {}, iconUrl: AppIcon.appIconFacebook),
        _socialButton(onTap: () {}, iconUrl: AppIcon.appIconGithub),
      ],
    );
  }

  Widget _socialButton({required VoidCallback onTap, required String iconUrl}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border(
                  top: BorderSide(
                    color: Colors.white60.withOpacity(0.7),
                    width: .8,
                  ),
                  left: BorderSide(
                    color: Colors.white60.withOpacity(0.7),
                    width: .8,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 33,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white60.withOpacity(.3),
                      Colors.white10.withOpacity(.1),
                    ],
                  ),
                  border: Border.all(color: Color(0xffA0A0A0).withOpacity(.3)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(iconUrl, height: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
