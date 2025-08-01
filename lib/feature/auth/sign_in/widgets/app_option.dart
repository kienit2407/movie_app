import 'dart:ui';

import 'package:flutter/material.dart';

class AppOption extends StatelessWidget {
  const AppOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 30,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(15),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 33, vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffA0A0A0).withOpacity(.3),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset('assets/icons/gg.png', height: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(15),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 33, vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xffA0A0A0).withOpacity(.3),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset('assets/icons/fb.png', height: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
