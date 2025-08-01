import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppEmailTextfield extends StatefulWidget {
  const AppEmailTextfield
  ({
    super.key, 
    required this.controller
  });

  final TextEditingController controller
;
  @override
  State<AppEmailTextfield> createState() => _AppEmailTextfieldState();
}

class _AppEmailTextfieldState extends State<AppEmailTextfield> {
  final _focusedNode = FocusNode();
  bool _isFocused = false;
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
          textInputAction: TextInputAction.next,
          controller: widget.controller,
          focusNode: _focusedNode,
          style: TextStyle(color: Colors.white),
          cursorWidth: 1,
          cursorRadius: Radius.circular(10),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.mail),
            filled: true,
            fillColor: _isFocused
                ? AppColor.secondColor.withOpacity(.1)
                : Color(0xff353841).withOpacity(.3),
            prefixIconColor: _isFocused ? AppColor.secondColor : Colors.white,
            hintText: 'Email',
          ).applyDefaults(Theme.of(context).inputDecorationTheme),
        ),
      ),
    );
  }
}
