import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_constants.dart';
import 'package:workmanager/workmanager.dart';

abstract interface class NewMovieTaskScheduler {
  Future<void> ensureRegistered();

  Future<void> cancel();
}

class NewMovieBackgroundScheduler implements NewMovieTaskScheduler {
  const NewMovieBackgroundScheduler();

  String get _uniqueTaskName {
    if (!kIsWeb && Platform.isIOS) {
      return NewMovieNotificationConstants.iosTaskIdentifier;
    }
    return NewMovieNotificationConstants.androidUniqueTaskName;
  }

  @override
  Future<void> ensureRegistered() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    await Workmanager().registerPeriodicTask(
      _uniqueTaskName,
      NewMovieNotificationConstants.taskName,
      frequency: NewMovieNotificationConstants.checkFrequency,
      initialDelay: NewMovieNotificationConstants.checkFrequency,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 10),
      tag: NewMovieNotificationConstants.taskName,
    );
    debugPrint('[NewMovieWorker] REGISTERED at ${DateTime.now()}');
  }

  @override
  Future<void> cancel() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    await Workmanager().cancelByUniqueName(_uniqueTaskName);
  }
}
