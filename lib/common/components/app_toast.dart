import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

abstract final class AppToast {
  static const Duration defaultDuration = Duration(seconds: 4);

  static void show(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
  }) {
    if (!context.mounted || message.trim().isEmpty) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    toastification.dismissAll(delayForAnimation: false);
    toastification.showCustom(
      context: context,
      overlayState: overlay,
      alignment: Alignment.topCenter,
      animationDuration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      autoCloseDuration: duration,
      animationBuilder: (context, animation, alignment, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: .96, end: 1).animate(curvedAnimation),
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      builder: (context, _) => _AppToastView(message: message.trim()),
    );
  }
}

class _AppToastView extends StatelessWidget {
  const _AppToastView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360, minHeight: 52),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
