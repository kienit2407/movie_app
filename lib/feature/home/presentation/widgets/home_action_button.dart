import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeActionButton extends StatefulWidget {
  const HomeActionButton({
    super.key,
    required this.icon,
    required this.content,
    required this.onTap,
    this.isPrimary = true,
    this.height = 44,
    this.borderRadius = 12,
  });

  final IconData icon;
  final String content;
  final VoidCallback onTap;
  final bool isPrimary;
  final double height;
  final double borderRadius;

  @override
  State<HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<HomeActionButton>
    with SingleTickerProviderStateMixin {
  static const _gradientColors = <Color>[
    Color(0xFFFFD275),
    Color(0xFFFF9E9E),
    Color(0xFFC77DFF),
    Color(0xFF70D7FF),
    Color(0xFFFFD275),
  ];

  late final AnimationController _borderController;
  bool? _animationEnabled;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = !MediaQuery.disableAnimationsOf(context);
    if (_animationEnabled == enabled) return;
    _animationEnabled = enabled;
    if (enabled) {
      _borderController.repeat();
    } else {
      _borderController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.content,
      child: AnimatedBuilder(
        animation: _borderController,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: SweepGradient(
                colors: _gradientColors,
                transform: GradientRotation(
                  _borderController.value * math.pi * 2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: _gradientColors[2].withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Padding(padding: const EdgeInsets.all(1.5), child: child),
          );
        },
        child: SizedBox(
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius - 1.5),
              gradient: widget.isPrimary
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFFFD275),
                        Color(0xFFFF9E9E),
                        Color(0xFFC77DFF),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    )
                  : null,
              color: widget.isPrimary
                  ? null
                  : const Color(0xFF252633).withValues(alpha: 0.92),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onTap();
                },
                borderRadius: BorderRadius.circular(widget.borderRadius - 1.5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          widget.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
