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
    final _foscusScrope = FocusScope.of(context);
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
            onSubmitted: (value) => _foscusScrope.unfocus(),
            controller: widget.controller,
            obscureText: _isHidePassword,
            obscuringCharacter: '*',
            focusNode: _focusedNode,
            style: const TextStyle(color: Colors.white),
            cursorWidth: 1, 
            cursorRadius: Radius.circular(10),
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.lock),
              suffixIcon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.elasticInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child); // Hiệu ứng scale
                },
                child: _isFocused ? IconButton(
                  key: ValueKey<bool>(_isHidePassword),
                  onPressed: (){
                    setState(() {
                      _isHidePassword = !_isHidePassword;
                    });
                  }, 
                  icon: _isHidePassword ? 
                  const Icon(Iconsax.eye_slash)
                  : const Icon(Iconsax.eye)
                ) : null,
              ),
              filled: true,
              fillColor: _isFocused
                  ? AppColor.secondColor.withOpacity(.2)
                  :  Colors.transparent,
              prefixIconColor: _isFocused ? AppColor.secondColor : Colors.white,
              hintText: 'Password',
            ).applyDefaults(Theme.of(context).inputDecorationTheme),
          ),
        ),
      ),
    );
  }
}

// Curve	Hiệu ứng	Ứng dụng phổ biến
// Curves.linear	Tốc độ không đổi	Progress bar
// Curves.easeIn	Chậm → Nhanh	Fade in
// Curves.easeOut	Nhanh → Chậm	Fade out
// Curves.easeInOut	Chậm → Nhanh → Chậm (tự nhiên nhất)	Button animations
// Curves.elasticOut	Hiệu ứng lò xo	Bounce effects
// Curves.fastOutSlowIn	Nhanh → Chậm hơn easeInOut	Transition màn hình
// Chọn curve phù hợp:

// Dùng Curves.easeInOut cho các UI thông thường
// Mở/đóng menu

// Chuyển trang

// Fade in/out

// Hầu hết animation thông thường
// Dùng Curves.elasticOut khi cần hiệu ứng "bật lại":
// Nút bấm vui nhộn

// Thông báo xuất hiện

// Hiệu ứng "nhấn mạnh"

//Khi nào càn value key ? : khi mà chueyern đổi giữa 2 widget còn nếu chuyền đổi màu thì không cần vi fnos cùng widget