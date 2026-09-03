import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    this.content,
    this.icon,
    this.title,
    this.buttonTitle,
    this.onPressed,
    this.cancelButtonTitle,
    this.onCancel,
    this.isDestructive = false,
  });

  final String? title;
  final String? content;
  final String? buttonTitle;
  final Icon? icon;
  final VoidCallback? onPressed;
  final String? cancelButtonTitle;
  final VoidCallback? onCancel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white60.withValues(alpha: .3),
                      Colors.white10.withValues(alpha: .1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white60),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xffE91C2D), Color(0xffF83947)],
                          ),
                        ),
                        child: icon ?? const Icon(Iconsax.danger, size: 30),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        title ?? context.l10n.commonCongratulationsTitle,
                        style: const TextStyle(
                          color: AppColor.secondColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          content ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            if (cancelButtonTitle != null) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      onCancel ??
                                      () => Navigator.pop(context, false),
                                  child: Text(cancelButtonTitle!),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                style: isDestructive
                                    ? ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xffE91C2D,
                                        ),
                                        foregroundColor: Colors.white,
                                      )
                                    : null,
                                onPressed:
                                    onPressed ??
                                    () => Navigator.pop(context, true),
                                child: Text(
                                  buttonTitle ?? context.l10n.commonAgree,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
