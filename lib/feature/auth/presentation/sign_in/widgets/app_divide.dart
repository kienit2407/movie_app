import 'package:flutter/material.dart';

class AppDivide extends StatelessWidget {
  const AppDivide({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.white10,
            thickness: 2,
            radius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Text(
            'Or Continue with',
            style: TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white10,
            thickness: 2,
            radius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
