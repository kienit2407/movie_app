import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87, // Màu nền bên ngoài "chiếc điện thoại"
      child: Center(
        child: ClipRect(
          // Đảm bảo nội dung không tràn ra ngoài bo góc
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ), // Chiều rộng chuẩn Mobile
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
