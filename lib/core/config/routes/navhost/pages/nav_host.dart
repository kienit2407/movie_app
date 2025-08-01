import 'package:flutter/material.dart';

class NavHost extends StatelessWidget {
  const NavHost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: Checkbox(value: true, onChanged:(value){}),
      )
    );
  }
}