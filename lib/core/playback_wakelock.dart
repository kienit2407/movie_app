import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlaybackWakelock {
  PlaybackWakelock._();

  static bool _enabled = false;

  static Future<void> setEnabled(bool enabled) async {
    if (_enabled == enabled) return;

    try {
      if (enabled) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
      _enabled = enabled;
    } catch (error) {
      debugPrint('[PlaybackWakelock] Failed to set enabled=$enabled: $error');
    }
  }

  static void unawaitedSetEnabled(bool enabled) {
    unawaited(setEnabled(enabled));
  }
}
