import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_constants.dart';

typedef NewMovieNotificationPayloadHandler = void Function(String payload);

abstract interface class NewMovieNotifier {
  Future<bool> areNotificationsEnabled();

  Future<void> showNewMovies(List<ItemEntity> movies);
}

abstract interface class NewMovieNotificationPermissions {
  Future<bool> areNotificationsEnabled();

  Future<bool> requestPermission();
}

class NewMovieNotificationService
    implements NewMovieNotifier, NewMovieNotificationPermissions {
  NewMovieNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initialization;

  Future<void> initialize({
    NewMovieNotificationPayloadHandler? onPayload,
    bool readLaunchPayload = false,
  }) {
    return _initialization ??= _initialize(
      onPayload: onPayload,
      readLaunchPayload: readLaunchPayload,
    );
  }

  Future<void> _initialize({
    NewMovieNotificationPayloadHandler? onPayload,
    required bool readLaunchPayload,
  }) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          onPayload?.call(payload);
        }
      },
    );

    if (!readLaunchPayload || onPayload == null) return;

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final response = launchDetails?.notificationResponse;
    final payload = response?.payload;
    if ((launchDetails?.didNotificationLaunchApp ?? false) &&
        payload != null &&
        payload.isNotEmpty) {
      onPayload(payload);
    }
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();

    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    await initialize();

    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final permissions = await ios?.checkPermissions();
      return permissions?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<void> showNewMovies(List<ItemEntity> movies) async {
    if (movies.isEmpty) return;
    await initialize();

    final isSingleMovie = movies.length == 1;
    final title = isSingleMovie
        ? 'Có phim mới'
        : 'Có ${movies.length} phim mới';
    final body = isSingleMovie
        ? '${movies.first.name} vừa được thêm vào Liquid Phim.'
        : movies.take(3).map((movie) => movie.name).join(', ');
    final payload = jsonEncode(
      isSingleMovie
          ? <String, String>{'type': 'new_movie', 'slug': movies.first.slug}
          : const <String, String>{'type': 'new_movies'},
    );

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        NewMovieNotificationConstants.channelId,
        NewMovieNotificationConstants.channelName,
        channelDescription: NewMovieNotificationConstants.channelDescription,
        icon: 'ic_launcher_monochrome',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        threadIdentifier: NewMovieNotificationConstants.channelId,
      ),
    );

    await _plugin.show(
      id: NewMovieNotificationConstants.notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
