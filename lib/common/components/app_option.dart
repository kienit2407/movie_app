import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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
        // Material(
        //   color: Colors.transparent,
        //   child: InkWell(
        //     onTap: () {},
        //     borderRadius: BorderRadius.circular(15),
        //     child: LiquidGlass(
        //       settings: LiquidGlassSettings(
        //         blur: 2,
        //         lightIntensity: 1.5,
        //         lightAngle: 120,
        //       ),
        //       shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(15)),
        //       child: Container(
        //         color: Colors.white60.withOpacity(.2),
        //         padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 18),
        //         child: Image.asset('assets/icons/gg.png', height: 28),
        //       ),
        //     ),
        //   ),
        // ),
        // Material(
        //   color: Colors.transparent,
        //   child: InkWell(
        //     onTap: () {},
        //     borderRadius: BorderRadius.circular(15),
        //     child: LiquidGlass(
        //       settings: LiquidGlassSettings(
        //         blur: 2,
        //         lightIntensity: 1.5,
        //         lightAngle: 120,
        //       ),
        //       shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(15)),
        //       child: Container(
        //         color: Colors.white60.withOpacity(.2),
        //         padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 18),
        //         child: Image.asset('assets/icons/fb.png', height: 28),
        //       ),
        //     ),
        //   ),
        // ),
        // Material(
        //   color: Colors.transparent,
        //   child: InkWell(
        //     onTap: () {},
        //     borderRadius: BorderRadius.circular(15),
        //     child: LiquidGlass(
        //       settings: LiquidGlassSettings(
        //         blur: 2,
        //         lightIntensity: 1.5,
        //         lightAngle: 120,
        //       ),
        //       shape: LiquidRoundedSuperellipse(borderRadius: Radius.circular(15)),
        //       child: Container(
        //         color: Colors.white60.withOpacity(.2),
        //         padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 18),
        //         child: Image.asset('assets/icons/github.png', height: 28),
        //       ),
        //     ),
        //   ),
        // ),
        // Material(
        //   color: Colors.transparent,
        //   child: InkWell(
        //     onTap: () {},
        //     borderRadius: BorderRadius.circular(15),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(15),
        //       child: BackdropFilter(
        //         filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        //         child: InkWell(
        //           child: Container(
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(15),
        //               border: Border(
        //                 top: BorderSide(
        //                   color: Colors.white60.withOpacity(0.7),
        //                   width: .8,
        //                 ),
        //                 left: BorderSide(
        //                   color: Colors.white60.withOpacity(0.7),
        //                   width: .8,
        //                 ),
        //               ),
        //             ),
        //             child: Container(
        //               padding: const EdgeInsets.symmetric(
        //                 horizontal: 33,
        //                 vertical: 18,
        //               ),
        //               decoration: BoxDecoration(
        //                 border: Border.all(
        //                   color: Color(0xffA0A0A0).withOpacity(.3),
        //                 ),
        //                 gradient: LinearGradient(
        //                   begin: Alignment.topLeft,
        //                   end: Alignment.bottomRight,
        //                   colors: [
        //                     Colors.white60.withOpacity(.3),
        //                     Colors.white10.withOpacity(.1),
        //                   ],
        //                 ),
        //                 borderRadius: BorderRadius.circular(15),
        //               ),
        //               child: Image.asset('assets/icons/github.png', height: 28),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
