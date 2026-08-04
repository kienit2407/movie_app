import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/notification/new_movie_background_service.dart';
import 'package:movie_app/feature/home/notification/new_movie_checker.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_storage.dart';

class NewMovieHomeSetup {
  const NewMovieHomeSetup({required this.shouldShowOnboarding});

  final bool shouldShowOnboarding;
}

class NewMovieNotificationCoordinator {
  NewMovieNotificationCoordinator({
    required NewMovieChecker checker,
    required NewMovieNotificationStore store,
    required NewMovieNotificationPermissions notificationService,
    required NewMovieTaskScheduler scheduler,
  }) : _checker = checker,
       _store = store,
       _notificationService = notificationService,
       _scheduler = scheduler;

  final NewMovieChecker _checker;
  final NewMovieNotificationStore _store;
  final NewMovieNotificationPermissions _notificationService;
  final NewMovieTaskScheduler _scheduler;

  Future<NewMovieHomeSetup> prepareHome(List<ItemEntity> currentMovies) async {
    final baselineCreated = await _checker.seedBaselineIfNeeded(currentMovies);
    if (!baselineCreated) {
      await _checker.processForeground(currentMovies);
    }

    final permissionGranted = await _notificationService
        .areNotificationsEnabled();
    if (permissionGranted) {
      await _scheduler.ensureRegistered();
    } else {
      await _scheduler.cancel();
    }

    return NewMovieHomeSetup(
      shouldShowOnboarding: !await _store.isOnboardingShown,
    );
  }

  Future<bool> enableNotifications() async {
    await _store.markOnboardingShown();
    final permissionGranted = await _notificationService.requestPermission();
    if (permissionGranted) {
      await _scheduler.ensureRegistered();
    } else {
      await _scheduler.cancel();
    }
    return permissionGranted;
  }

  Future<void> declineNotifications() async {
    await _store.markOnboardingShown();
    await _scheduler.cancel();
  }
}
