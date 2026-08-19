import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum CastingType { googleCast, airPlay }

enum CastingState {
  disconnected,
  connecting,
  connected,
  loading,
  playing,
  paused,
}

class CastMedia {
  const CastMedia({
    required this.url,
    required this.movieName,
    required this.slug,
    required this.serverName,
    required this.serverIndex,
    required this.episodeName,
    required this.episodeIndex,
    required this.position,
    required this.duration,
    this.posterUrl,
  });

  final String url;
  final String movieName;
  final String slug;
  final String serverName;
  final int serverIndex;
  final String episodeName;
  final int episodeIndex;
  final Duration position;
  final Duration duration;
  final String? posterUrl;
}

class CastSessionEvent {
  const CastSessionEvent({
    required this.state,
    this.type = CastingType.googleCast,
    this.deviceName,
    this.position = Duration.zero,
    this.wasPlaying = false,
  });

  final CastingState state;
  final CastingType type;
  final String? deviceName;
  final Duration position;
  final bool wasPlaying;

  bool get isConnected => switch (state) {
    CastingState.connected ||
    CastingState.loading ||
    CastingState.playing ||
    CastingState.paused => true,
    _ => false,
  };

  factory CastSessionEvent.fromMap(
    Map<Object?, Object?> map, {
    CastingType? type,
  }) {
    final stateName = map['state']?.toString();
    final state = CastingState.values.firstWhere(
      (value) => value.name == stateName,
      orElse: () => CastingState.disconnected,
    );
    final typeName = map['type']?.toString();
    final resolvedType =
        type ??
        CastingType.values.firstWhere(
          (value) => value.name == typeName,
          orElse: () => CastingType.googleCast,
        );
    return CastSessionEvent(
      state: state,
      type: resolvedType,
      deviceName: map['deviceName']?.toString(),
      position: Duration(
        milliseconds: (map['positionMs'] as num?)?.toInt() ?? 0,
      ),
      wasPlaying: map['wasPlaying'] == true,
    );
  }
}

class GoogleCastDevice {
  const GoogleCastDevice({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;

  factory GoogleCastDevice.fromMap(Map<Object?, Object?> map) {
    return GoogleCastDevice(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Thiết bị Google Cast',
      description: map['description']?.toString(),
    );
  }
}

abstract interface class CastingService {
  bool get supportsAirPlay;
  bool get supportsGoogleCast;

  Future<bool> showAirPlayPicker();

  Stream<CastSessionEvent> get events;

  Stream<List<GoogleCastDevice>> get googleCastDevices;

  Future<List<GoogleCastDevice>> startGoogleCastDiscovery();

  Future<void> stopGoogleCastDiscovery();

  Future<bool> connectGoogleCastDevice(
    GoogleCastDevice device,
    CastMedia media,
  );

  Future<bool> showGoogleCastPicker(CastMedia media);

  Future<bool> loadGoogleCast(CastMedia media);

  Future<bool> playGoogleCast();

  Future<bool> pauseGoogleCast();

  Future<bool> seekGoogleCast(Duration position);

  Future<bool> stopGoogleCast();

  Future<bool> showGoogleCastControls();
}

class PlatformCastingService implements CastingService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.movie_app/casting',
  );
  static final StreamController<CastSessionEvent> _events =
      StreamController<CastSessionEvent>.broadcast(sync: true);
  static final StreamController<List<GoogleCastDevice>> _googleCastDevices =
      StreamController<List<GoogleCastDevice>>.broadcast(sync: true);
  static bool _handlerInstalled = false;

  PlatformCastingService() {
    _installHandler();
    if (supportsAirPlay) unawaited(_syncAirPlayState());
  }

  static void _installHandler() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'googleCastDevicesChanged' && call.arguments is List) {
        _googleCastDevices.add(
          (call.arguments as List)
              .whereType<Map>()
              .map(
                (device) =>
                    GoogleCastDevice.fromMap(device.cast<Object?, Object?>()),
              )
              .where((device) => device.id.isNotEmpty)
              .toList(growable: false),
        );
        return;
      }

      final type = switch (call.method) {
        'googleCastStateChanged' => CastingType.googleCast,
        'airPlayStateChanged' => CastingType.airPlay,
        _ => null,
      };
      if (type == null) return;
      final arguments = call.arguments;
      if (arguments is Map) {
        _events.add(
          CastSessionEvent.fromMap(
            arguments.cast<Object?, Object?>(),
            type: type,
          ),
        );
      }
    });
  }

  Future<void> _syncAirPlayState() async {
    try {
      final active =
          await _channel.invokeMethod<bool>('isAirPlayActive') ?? false;
      _events.add(
        CastSessionEvent(
          state: active ? CastingState.connected : CastingState.disconnected,
          type: CastingType.airPlay,
        ),
      );
    } on PlatformException {
      // AirPlay state is best effort; route-change events keep it in sync.
    } on MissingPluginException {
      // Native bridge is unavailable on unsupported/test platforms.
    }
  }

  @override
  bool get supportsAirPlay => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool get supportsGoogleCast =>
      defaultTargetPlatform == TargetPlatform.android;

  @override
  Stream<CastSessionEvent> get events => _events.stream;

  @override
  Stream<List<GoogleCastDevice>> get googleCastDevices =>
      _googleCastDevices.stream;

  @override
  Future<List<GoogleCastDevice>> startGoogleCastDiscovery() async {
    if (!supportsGoogleCast) return const [];
    try {
      final devices = await _channel.invokeListMethod<Object?>(
        'startGoogleCastDiscovery',
      );
      return (devices ?? const [])
          .whereType<Map>()
          .map(
            (device) =>
                GoogleCastDevice.fromMap(device.cast<Object?, Object?>()),
          )
          .where((device) => device.id.isNotEmpty)
          .toList(growable: false);
    } on PlatformException {
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  @override
  Future<void> stopGoogleCastDiscovery() async {
    if (!supportsGoogleCast) return;
    try {
      await _channel.invokeMethod<void>('stopGoogleCastDiscovery');
    } on PlatformException {
      // Discovery cleanup is best effort.
    } on MissingPluginException {
      // Native bridge is unavailable on unsupported/test platforms.
    }
  }

  @override
  Future<bool> connectGoogleCastDevice(
    GoogleCastDevice device,
    CastMedia media,
  ) {
    if (!supportsGoogleCast) return Future.value(false);
    return _invokeBool('connectGoogleCastDevice', {
      'deviceId': device.id,
      ..._mediaArguments(media),
    });
  }

  @override
  Future<bool> showAirPlayPicker() async {
    if (!supportsAirPlay) return false;
    try {
      return await _channel.invokeMethod<bool>('showAirPlayPicker') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> showGoogleCastPicker(CastMedia media) {
    if (!supportsGoogleCast) return Future.value(false);
    return _invokeBool('showGoogleCastPicker', _mediaArguments(media));
  }

  @override
  Future<bool> loadGoogleCast(CastMedia media) {
    if (!supportsGoogleCast) return Future.value(false);
    return _invokeBool('loadGoogleCastMedia', _mediaArguments(media));
  }

  Map<String, Object?> _mediaArguments(CastMedia media) => {
    'url': media.url,
    'movieName': media.movieName,
    'slug': media.slug,
    'serverName': media.serverName,
    'serverIndex': media.serverIndex,
    'episodeName': media.episodeName,
    'episodeIndex': media.episodeIndex,
    'positionMs': media.position.inMilliseconds,
    'durationMs': media.duration.inMilliseconds,
    'posterUrl': media.posterUrl,
  };

  @override
  Future<bool> playGoogleCast() => _invokeBool('googleCastPlay');

  @override
  Future<bool> pauseGoogleCast() => _invokeBool('googleCastPause');

  @override
  Future<bool> seekGoogleCast(Duration position) =>
      _invokeBool('googleCastSeek', {'positionMs': position.inMilliseconds});

  @override
  Future<bool> stopGoogleCast() => _invokeBool('googleCastStop');

  @override
  Future<bool> showGoogleCastControls() =>
      _invokeBool('showGoogleCastControls');

  Future<bool> _invokeBool(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<bool>(method, arguments) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
