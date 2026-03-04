import 'package:flutter/material.dart';

class MovieInfoChip extends StatelessWidget {
  final Color? borderColor;
  final bool isGradient;
  final Widget? child;
  final Color? backgroundColor;

  const MovieInfoChip({
    super.key,
    this.borderColor,
    this.isGradient = false,
    this.child,
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
      child: child,
    );
  }
}
