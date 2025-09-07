import 'dart:ui';

import 'package:flutter/material.dart';

class PolkBackGround extends StatelessWidget {
  const PolkBackGround({
    super.key,
    this.dotColor = Colors.white,
    this.dotRadius = 4,
    this.spacing = 40,
  });
  final Color dotColor;
  final double spacing;
  final double dotRadius;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PolkaDotPainter(
        dotColor: dotColor,
        dotRadius: dotRadius,
        spacing: spacing,
      ),
      child: SizedBox.expand(), // full screen
    );
  }
}

class PolkaDotPainter extends CustomPainter {
  final double dotRadius;
  final double spacing;
  final Color dotColor;

  PolkaDotPainter({
    required this.dotRadius,
    required this.spacing,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
