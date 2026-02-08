import 'package:flutter/material.dart';

class AutoSwitch extends StatelessWidget {
  const AutoSwitch({
    required this.value,
    required this.onChanged,
    required this.onIcon,
    required this.offIcon,
    required this.onColor,
    required this.offColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData onIcon;
  final IconData offIcon;
  final Color onColor;
  final Color offColor;

  @override
  Widget build(BuildContext context) {
    // Kích thước tổng
    const double w = 40;
    const double h = 30;
    const double knob = 5;
    const double pad = 3;

    final bg = value ? onColor.withOpacity(0.25) : Colors.black54;
    final border = value ? onColor : Colors.white24;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: w,
          height: h,
          padding: const EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border, width: 1),
          ),
          child: Stack(
            children: [
              // // Text "Auto" nhỏ bên trái / hoặc bạn bỏ luôn nếu muốn
              // Align(
              //   alignment: Alignment.center,
              //   child: Text(
              //     'Auto',
              //     style: TextStyle(
              //       color: Colors.white.withOpacity(0.85),
              //       fontSize: 11,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),

              // Nút tròn chạy qua lại
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    color: value ? onColor : offColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        value ? onIcon : offIcon,
                        key: ValueKey(value),
                        size: 16,
                        color: value ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}