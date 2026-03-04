import 'package:flutter/material.dart';

class HomeActionButton extends StatelessWidget {
  final IconData icon;
  final String content;
  final VoidCallback onTap;
  final bool isPrimary;

  const HomeActionButton({
    super.key,
    required this.icon,
    required this.content,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: isPrimary
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
            color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
            boxShadow: isPrimary
                ? const [
                    BoxShadow(
                      color: Color(0xFFC77DFF),
                      blurRadius: 12,
                      offset: Offset(0, 0),
                      spreadRadius: -2,
                    ),
                  ]
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.9),
                size: 18,
              ),
              Text(
                content,
                style: TextStyle(
                  color: isPrimary
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
