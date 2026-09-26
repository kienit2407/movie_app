import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_app/core/audio/sound_effect_player.dart';

class AppRefreshIndicator extends StatelessWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.soundEffectPlayer,
    required this.child,
    this.color,
    // Điểm mà biểu tượng refresh bắt đầu xuất hiện, tính từ mép trên.
    this.edgeOffset = 0.0,
    // Khoảng biểu tượng dịch xuống thêm tính từ edgeOffset.
    this.displacement = 40.0,
  });

  final Future<void> Function() onRefresh;
  final SoundEffectPlayer soundEffectPlayer;
  final Widget child;
  final Color? color;
  final double edgeOffset;
  final double displacement;

  Future<void> _handleRefresh() async {
    unawaited(soundEffectPlayer.play(SoundEventType.reloadStart));

    try {
      await onRefresh();
    } finally {
      unawaited(soundEffectPlayer.play(SoundEventType.reloadEnd));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      color: color,
      edgeOffset: edgeOffset,
      displacement: displacement,
      onRefresh: _handleRefresh,
      child: child,
    );
  }
}
