import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/home/notification/new_movie_background_service.dart';
import 'package:movie_app/feature/home/notification/new_movie_checker.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_coordinator.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';

import 'new_movie_checker_test.dart';

void main() {
  group('NewMovieNotificationCoordinator', () {
    test('seeds Home and cancels work when permission is disabled', () async {
      final store = FakeNewMovieStore();
      final permissions = FakePermissions(enabled: false);
      final scheduler = FakeScheduler();
      final coordinator = buildCoordinator(
        store: store,
        permissions: permissions,
        scheduler: scheduler,
      );

      final setup = await coordinator.prepareHome([movie('baseline')]);

      expect(store.knownSlugs, {'baseline'});
      expect(setup.shouldShowOnboarding, isTrue);
      expect(scheduler.cancelCalls, 1);
      expect(scheduler.registerCalls, 0);
    });

    test('keeps work registered when permission is already granted', () async {
      final store = FakeNewMovieStore(
        baselineInitialized: true,
        onboardingShown: true,
      );
      final permissions = FakePermissions(enabled: true);
      final scheduler = FakeScheduler();
      final coordinator = buildCoordinator(
        store: store,
        permissions: permissions,
        scheduler: scheduler,
      );

      final setup = await coordinator.prepareHome([movie('existing')]);

      expect(setup.shouldShowOnboarding, isFalse);
      expect(scheduler.registerCalls, 1);
      expect(scheduler.cancelCalls, 0);
    });

    test('registers work after the permission request succeeds', () async {
      final store = FakeNewMovieStore();
      final permissions = FakePermissions(enabled: false, requestResult: true);
      final scheduler = FakeScheduler();
      final coordinator = buildCoordinator(
        store: store,
        permissions: permissions,
        scheduler: scheduler,
      );

      final enabled = await coordinator.enableNotifications();

      expect(enabled, isTrue);
      expect(store.onboardingShown, isTrue);
      expect(scheduler.registerCalls, 1);
      expect(scheduler.cancelCalls, 0);
    });

    test('cancels work when onboarding is declined', () async {
      final store = FakeNewMovieStore();
      final scheduler = FakeScheduler();
      final coordinator = buildCoordinator(
        store: store,
        permissions: FakePermissions(enabled: false),
        scheduler: scheduler,
      );

      await coordinator.declineNotifications();

      expect(store.onboardingShown, isTrue);
      expect(scheduler.cancelCalls, 1);
    });
  });
}

NewMovieNotificationCoordinator buildCoordinator({
  required FakeNewMovieStore store,
  required FakePermissions permissions,
  required FakeScheduler scheduler,
}) {
  final notifier = FakeNewMovieNotifier();
  final checker = NewMovieChecker(
    loadLatestMovies: () async => const Right([]),
    store: store,
    notifier: notifier,
  );
  return NewMovieNotificationCoordinator(
    checker: checker,
    store: store,
    notificationService: permissions,
    scheduler: scheduler,
  );
}

class FakePermissions implements NewMovieNotificationPermissions {
  FakePermissions({required this.enabled, bool? requestResult})
    : requestResult = requestResult ?? enabled;

  bool enabled;
  final bool requestResult;

  @override
  Future<bool> areNotificationsEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    enabled = requestResult;
    return requestResult;
  }
}

class FakeScheduler implements NewMovieTaskScheduler {
  int registerCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }

  @override
  Future<void> ensureRegistered() async {
    registerCalls++;
  }
}
