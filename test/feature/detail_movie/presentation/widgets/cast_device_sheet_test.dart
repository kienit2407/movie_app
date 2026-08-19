import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/casting/casting_service.dart';
import 'package:movie_app/feature/detail_movie/presentation/widgets/cast_device_sheet.dart';

void main() {
  testWidgets('opens above a player overlay that has no Navigator ancestor', (
    tester,
  ) async {
    final service = _FakeCastingService();
    final media = CastMedia(
      url: 'https://example.com/movie.m3u8',
      movieName: 'Liquid Movie',
      slug: 'liquid-movie',
      serverName: 'Server 1',
      serverIndex: 0,
      episodeName: 'Tập 1',
      episodeIndex: 0,
      position: const Duration(seconds: 12),
      duration: const Duration(minutes: 45),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: const SizedBox.shrink(),
        builder: (context, child) => Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (_) => Stack(
                fit: StackFit.expand,
                children: [
                  child ?? const SizedBox.shrink(),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Builder(
                      builder: (overlayContext) => ElevatedButton(
                        onPressed: () {
                          unawaited(
                            CastDeviceSheet.show(
                              overlayContext,
                              service: service,
                              media: media,
                            ),
                          );
                        },
                        child: const Text('Mở Cast'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Mở Cast'));
    await tester.pumpAndSettle();

    expect(find.text('Chọn thiết bị'), findsOneWidget);
    expect(find.text('Phòng khách'), findsOneWidget);

    await tester.tap(find.text('Phòng khách'));
    await tester.pumpAndSettle();

    expect(service.pickerCalls, 1);
    expect(service.lastMedia?.url, media.url);
    expect(find.text('Chọn thiết bị'), findsNothing);
  });
}

class _FakeCastingService implements CastingService {
  int pickerCalls = 0;
  CastMedia? lastMedia;
  final StreamController<List<GoogleCastDevice>> devicesController =
      StreamController<List<GoogleCastDevice>>.broadcast();

  @override
  Stream<CastSessionEvent> get events => const Stream.empty();

  @override
  Stream<List<GoogleCastDevice>> get googleCastDevices =>
      devicesController.stream;

  @override
  Future<List<GoogleCastDevice>> startGoogleCastDiscovery() async => const [
    GoogleCastDevice(id: 'living-room', name: 'Phòng khách'),
  ];

  @override
  Future<void> stopGoogleCastDiscovery() async {}

  @override
  Future<bool> connectGoogleCastDevice(
    GoogleCastDevice device,
    CastMedia media,
  ) async {
    pickerCalls++;
    lastMedia = media;
    return true;
  }

  @override
  bool get supportsAirPlay => false;

  @override
  bool get supportsGoogleCast => true;

  @override
  Future<bool> showGoogleCastPicker(CastMedia media) async {
    pickerCalls++;
    lastMedia = media;
    return true;
  }

  @override
  Future<bool> loadGoogleCast(CastMedia media) async => true;

  @override
  Future<bool> pauseGoogleCast() async => true;

  @override
  Future<bool> playGoogleCast() async => true;

  @override
  Future<bool> seekGoogleCast(Duration position) async => true;

  @override
  Future<bool> showAirPlayPicker() async => false;

  @override
  Future<bool> showGoogleCastControls() async => true;

  @override
  Future<bool> stopGoogleCast() async => true;
}
