import 'package:flutter/services.dart';

enum DevicePhysicalOrientation {
  portraitUp,
  landscapeLeft,
  landscapeRight,
  unknown,
}

class DeviceOrientationService {
  DeviceOrientationService._();

  static final DeviceOrientationService instance = DeviceOrientationService._();
  static const EventChannel _channel = EventChannel(
    'com.kinit.movieapp/device_orientation',
  );

  Stream<DevicePhysicalOrientation>? _orientationStream;

  Stream<DevicePhysicalOrientation> get orientationChanges {
    return _orientationStream ??= _channel
        .receiveBroadcastStream()
        .map(_decodeOrientation)
        .where(
          (orientation) => orientation != DevicePhysicalOrientation.unknown,
        )
        .distinct();
  }

  DevicePhysicalOrientation _decodeOrientation(dynamic value) {
    return switch (value) {
      'portraitUp' => DevicePhysicalOrientation.portraitUp,
      'landscapeLeft' => DevicePhysicalOrientation.landscapeLeft,
      'landscapeRight' => DevicePhysicalOrientation.landscapeRight,
      _ => DevicePhysicalOrientation.unknown,
    };
  }
}
