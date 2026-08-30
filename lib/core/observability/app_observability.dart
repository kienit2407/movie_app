import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/firebase_options.dart';

class AppObservability {
  AppObservability._();

  static bool _initialized = false;
  static bool _handlersInstalled = false;

  static bool get isEnabled => _initialized;

  static Future<void> initialize() async {
    _installGlobalErrorHandlers();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final collect = !kDebugMode;
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        collect,
      );
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(collect);
      _initialized = true;
      if (collect) await FirebaseAnalytics.instance.logAppOpen();
    } catch (error) {
      _initialized = false;
      debugPrint(
        '[Firebase] Chưa có cấu hình native; Crashlytics/Analytics đang tắt: '
        '$error',
      );
    }
  }

  static BlocObserver blocObserver() => _CrashReportingBlocObserver();

  static NavigatorObserver navigatorObserver() => _AnalyticsNavigatorObserver();

  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
  }) async {
    if (!_initialized) return;
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) return;
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  static Future<void> logScreenView(String screenName) async {
    if (!_initialized) return;
    await FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  static void _installGlobalErrorHandlers() {
    if (_handlersInstalled) return;
    _handlersInstalled = true;

    final previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (previousFlutterHandler != null) {
        previousFlutterHandler(details);
      } else {
        FlutterError.presentError(details);
      }
      if (_initialized) {
        unawaited(
          FirebaseCrashlytics.instance.recordFlutterFatalError(details),
        );
      }
    };

    final previousPlatformHandler = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(recordError(error, stack, fatal: true));
      return previousPlatformHandler?.call(error, stack) ?? _initialized;
    };
  }
}

class _CrashReportingBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    unawaited(
      AppObservability.recordError(
        error,
        stackTrace,
        reason: 'Bloc error: ${bloc.runtimeType}',
      ),
    );
    super.onError(bloc, error, stackTrace);
  }
}

class _AnalyticsNavigatorObserver extends NavigatorObserver {
  void _log(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(AppObservability.logScreenView(name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log(previousRoute);
  }
}
