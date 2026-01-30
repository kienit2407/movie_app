import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

class AppFullnameTextfield extends StatefulWidget {
  const AppFullnameTextfield
  ({
    super.key, 
    required this.controller,
 
  });

  final TextEditingController controller;
  @override
  State<AppFullnameTextfield> createState() => _AppFullnameTextfieldState();
}

class _AppFullnameTextfieldState extends State<AppFullnameTextfield> {
  final _focusedNode = FocusNode();
  bool _isFocused = false;
  bool _hideClear = false;
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
                colors: [
                  Colors.white60.withOpacity(.3),
                  Colors.white10.withOpacity(.1),
              ]
            ),
            border: Border(
              top: BorderSide(color: Colors.white60.withOpacity(0.7), width: 1),
              left: BorderSide(color: Colors.white60.withOpacity(0.7), width: 1)
            ),
          ),
          child: TextField(
            textInputAction: TextInputAction.next,
            onSubmitted: (value) {
              if(value.isNotEmpty){
                FocusScope.of(context).nextFocus();
              } else{
                _focusedNode.requestFocus();
              }
            },
            
            onChanged: (value) {
              setState(() {
                _hideClear = value.isNotEmpty;
              });
            },
            // textInputAction: TextInputAction.next, <- cái này nó sẽ tự động rồi nextfocus luôn
            controller: widget.controller,
            focusNode: _focusedNode,
            style: const TextStyle(color: Colors.white),
            cursorWidth: 1,
            cursorRadius: Radius.circular(10),
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.user),
              filled: true,
              fillColor: _isFocused
                  ? AppColor.secondColor.withOpacity(.2)
                  :  Colors.transparent,
              prefixIconColor: _isFocused ? AppColor.secondColor : Colors.white,
              suffixIcon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.elasticInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child); // Hiệu ứng scale
                },
                child: (_hideClear && _isFocused) ? IconButton(
                  onPressed: (){
                    setState(() {
                      widget.controller.clear();
                      _hideClear = false;
                    });
                  }, 
                  icon: Icon(Iconsax.tag_cross_copy) ,
                ): null,
              ),
              hintText: 'Full name',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
          ),
        ),
      ),
    );
  }
}
