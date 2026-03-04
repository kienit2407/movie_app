import 'package:flutter/material.dart';

class HomeInfoChip extends StatelessWidget {
  final String text;
  final Color? borderColor;
  final bool isGradient;
  final Color? backgroundColor;

  const HomeInfoChip({
    super.key,
    required this.text,
    this.borderColor,
    this.isGradient = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? Colors.white),
        borderRadius: BorderRadius.circular(7),
        boxShadow: isGradient
            ? const [
                BoxShadow(
                  color: Color(0xFFC77DFF),
                  blurRadius: 12,
                  offset: Offset(0, 0),
                  spreadRadius: -2,
                ),
              ]
            : null,
        gradient: isGradient
            ? const LinearGradient(
                colors: [
                  Color(0xFFC77DFF),
                  Color(0xFFFF9E9E),
                  Color(0xFFFFD275),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
