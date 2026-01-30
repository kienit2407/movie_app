import 'package:flutter/material.dart';

class NavHost extends StatelessWidget {
  const NavHost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            
          }, 
          child: Text('Đăng xuất')
        ),
      )
    );
  }
}