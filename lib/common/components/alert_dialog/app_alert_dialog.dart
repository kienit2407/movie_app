import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppAlertDialog extends StatefulWidget {
  const AppAlertDialog({super.key, this.content, this.icon, this.title, this.buttonTitle, this.onPressed});
  final String? title;
  final String? content;
  final String? buttonTitle;
  final Icon? icon;
  final VoidCallback? onPressed;

  @override
  State<AppAlertDialog> createState() => _AppAlertDialogState();
}

class _AppAlertDialogState extends State<AppAlertDialog> {
  @override
  void initState() {
    closeDialog();
    super.initState();
  }
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
                      Colors.white60.withOpacity(.3),
                      Colors.white10.withOpacity(.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white60),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xffE91C2D), Color(0xffF83947)],
                          ),
                        ),
                        child: widget.icon ?? Icon(Iconsax.danger, size: 30),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        widget.title ?? 'Congratulations!',
                        style: TextStyle(
                          color: AppColor.secondColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,),
                        child: Text(
                          '${widget.content}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.maxFinite,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: widget.onPressed ?? () {
                              AppNavigator.pop(context);
                            },
                            child: Text(
                              widget.buttonTitle ?? 'I agree',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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

  Future<void> closeDialog () async {
    await Future.delayed(const Duration(seconds: 4));
    if(mounted){ //<- biến mounted là một biên sbool của mỗi statefull. cho biến widget còn sống hay không
      AppNavigator.pop(context);
    }
    return;
  }
}
