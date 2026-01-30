import 'package:flutter/material.dart';

class NoBackSwipeRoute<T> extends MaterialPageRoute<T> {
  NoBackSwipeRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  bool get popGestureEnabled => false; // <-- chặn swipe-back iOS
}
