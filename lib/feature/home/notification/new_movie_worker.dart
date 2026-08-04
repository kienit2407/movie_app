import 'package:flutter/widgets.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/notification/new_movie_checker.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_constants.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void newMovieCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint(
      '[NewMovieWorker] TRIGGERED '
      'task=$taskName time=${DateTime.now()} input=$inputData',
    );
    final isNewMovieTask =
        taskName == NewMovieNotificationConstants.taskName ||
        taskName == NewMovieNotificationConstants.androidUniqueTaskName ||
        taskName == NewMovieNotificationConstants.iosTaskIdentifier;
    if (!isNewMovieTask) return true;

    try {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeGetit();
      await sl<NewMovieNotificationService>().initialize();
      final result = await sl<NewMovieChecker>().check();
      debugPrint(
        '[NewMovieWorker] ${result.outcome.name}'
        '${result.error == null ? '' : ': ${result.error}'}',
      );
      return !result.shouldRetry;
    } catch (error, stackTrace) {
      debugPrint('[NewMovieWorker] failed: $error\n$stackTrace');
      return false;
    }
  });
}
