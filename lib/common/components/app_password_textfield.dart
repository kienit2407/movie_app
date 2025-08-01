import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppPasswordTextfield extends StatefulWidget {
  const AppPasswordTextfield({
    super.key,
    required this.controller
  });

  final TextEditingController controller;
  @override
  State<AppPasswordTextfield> createState() => _AppPasswordTextfieldState();
}

class _AppPasswordTextfieldState extends State<AppPasswordTextfield> {
  final _focusedNode = FocusNode();
  bool _isFocused = false;
  bool _isHidePassword = true;

@override
  void initState() {
    _focusedNode.addListener((){
      if(_focusedNode.hasFocus != _isFocused){
        setState(() {
          _isFocused = _focusedNode.hasFocus;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusedNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.hardEdge,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _isFocused
              ? 5
              : 3, //<- dùng để điều chỉnh độ mờ theo chiều nang và dọc
          sigmaY: _isFocused ? 5 : 3,
          tileMode: TileMode.mirror,
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: _isHidePassword,
          obscuringCharacter: '*',
          focusNode: _focusedNode,
          style: TextStyle(color: Colors.white),
          cursorWidth: 1,
          cursorRadius: Radius.circular(10),
          decoration: InputDecoration(
            prefixIcon: Icon(Iconsax.lock),
            suffixIcon: IconButton(
              onPressed: (){
                setState(() {
                  _isHidePassword = !_isHidePassword;
                });
              }, 
              icon: _isHidePassword ? 
              Icon(Iconsax.eye_slash)
              : Icon(Iconsax.eye)
            ),
            filled: true,
            fillColor: _isFocused
                ? AppColor.secondColor.withOpacity(.1)
                : Color(0xff353841).withOpacity(.3),
            prefixIconColor: _isFocused ? AppColor.secondColor : Colors.white,
            hintText: 'Password',
          ).applyDefaults(Theme.of(context).inputDecorationTheme),
        ),
      ),
    );
  }
}
