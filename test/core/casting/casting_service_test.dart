import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/casting/casting_service.dart';

void main() {
  test('maps native Google Cast playback state and handoff position', () {
    final event = CastSessionEvent.fromMap({
      'state': 'playing',
      'deviceName': 'Phòng khách',
      'positionMs': 91234,
      'wasPlaying': true,
    });

    expect(event.state, CastingState.playing);
    expect(event.deviceName, 'Phòng khách');
    expect(event.position, const Duration(milliseconds: 91234));
    expect(event.wasPlaying, isTrue);
    expect(event.isConnected, isTrue);
  });

  test('unknown native state safely falls back to disconnected', () {
    final event = CastSessionEvent.fromMap(const {'state': 'unexpected'});

    expect(event.state, CastingState.disconnected);
    expect(event.isConnected, isFalse);
  });

  test('maps AirPlay route state without treating it as Google Cast', () {
    final event = CastSessionEvent.fromMap(const {
      'state': 'connected',
      'type': 'airPlay',
    });

    expect(event.type, CastingType.airPlay);
    expect(event.state, CastingState.connected);
    expect(event.isConnected, isTrue);
  });
}
