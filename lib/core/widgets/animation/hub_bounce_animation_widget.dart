import 'package:flutter/material.dart';

/// Tạo hiệu ứng nảy cho toàn bộ thanh Hub khi người dùng chạm vào thanh.
///
/// [Listener] chỉ quan sát pointer nên các nút điều hướng bên trong vẫn nhận
/// gesture và xử lý `onTap` như bình thường.
class HubBounceAnimationWidget extends StatefulWidget {
  const HubBounceAnimationWidget({
    super.key,
    required this.reduceMotion,
    required this.child,
  });

  final bool reduceMotion;
  final Widget child;

  @override
  State<HubBounceAnimationWidget> createState() =>
      _HubBounceAnimationWidgetState();
}

class _HubBounceAnimationWidgetState extends State<HubBounceAnimationWidget>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 380);

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.965,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.965,
          end: 1.025,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.025,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: const Offset(0, 0.04),
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, 0.04),
          end: const Offset(0, -0.08),
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant HubBounceAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.reduceMotion && widget.reduceMotion) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  void _playAnimation(PointerDownEvent event) {
    if (!widget.reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _playAnimation,
      child: ScaleTransition(
        alignment: Alignment.bottomCenter,
        scale: _scaleAnimation,
        child: SlideTransition(position: _slideAnimation, child: widget.child),
      ),
    );
  }
}
