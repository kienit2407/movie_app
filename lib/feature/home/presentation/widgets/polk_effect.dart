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
class CornerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    // TopLeft corner
    path.moveTo(0, 20);
    path.lineTo(0, 0);
    path.lineTo(20, 0);

    // BottomRight corner
    path.moveTo(size.width - 20, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height - 20);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CornerBorderContainer extends StatelessWidget {
  const CornerBorderContainer({super.key, required this.content});
  final String content;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CornerBorderPainter(),
      child: Container(
        width: 200,
        height: 100,
        alignment: Alignment.center,
        child: Text(content),
      ),
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
