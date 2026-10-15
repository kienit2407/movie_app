import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/enum/language_enum.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_navigation.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:quick_actions/quick_actions.dart';

final class AppQuickActionsService {
  AppQuickActionsService._();

  static final AppQuickActionsService instance = AppQuickActionsService._();

  static const String clearCacheType = 'clear_cache';
  static const String searchType = 'search';
  static const String notificationsType = 'notifications';

  static const String _clearCacheQuery = 'clearCache';
  static const MethodChannel _iosIconChannel = MethodChannel(
    'com.kinit.movieapp/quick_actions_icons',
  );

  final QuickActions _quickActions = const QuickActions();
  StreamSubscription<Language>? _localeSubscription;
  bool _initialized = false;

  Future<void> initialize(LocalizationCubit localizationCubit) async {
    if (_initialized || !_isSupportedPlatform) return;
    _initialized = true;

    try {
      await _quickActions.initialize(_handleShortcut);
      await _registerItems(localizationCubit.state.locale!);
      _localeSubscription = localizationCubit.stream.listen((language) {
        unawaited(_registerItems(language.locale!));
      });
    } on MissingPluginException catch (error, stackTrace) {
      _logFailure(error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _logFailure(error, stackTrace);
    }
  }

  @visibleForTesting
  Future<void> resetForTesting() async {
    await _localeSubscription?.cancel();
    _localeSubscription = null;
    _initialized = false;
  }

  static String? routeForType(String shortcutType) {
    return switch (shortcutType) {
      clearCacheType => Uri(
        path: AppRoutes.storageManagement,
        queryParameters: const {_clearCacheQuery: 'true'},
      ).toString(),
      searchType => AppRoutes.search,
      notificationsType => AppRoutes.notifications,
      _ => null,
    };
  }

  void _handleShortcut(String shortcutType) {
    final route = routeForType(shortcutType);
    if (route == null) return;
    NewMovieNotificationNavigation.openRoute(route);
  }

  Future<void> _registerItems(Locale locale) async {
    final l10n = lookupAppLocalizations(locale);
    try {
      await _quickActions.setShortcutItems([
        ShortcutItem(
          type: clearCacheType,
          localizedTitle: l10n.quickActionClearCache,
          icon: 'shortcut_clear_cache',
        ),
        ShortcutItem(
          type: searchType,
          localizedTitle: l10n.quickActionSearch,
          icon: 'shortcut_search',
        ),
        ShortcutItem(
          type: notificationsType,
          localizedTitle: l10n.quickActionNotifications,
          icon: 'shortcut_notifications',
        ),
      ]);
      // quick_actions treats icon strings as asset names on iOS, not SF Symbols.
      // Apply native system icons after registration, including locale updates.
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _iosIconChannel.invokeMethod<void>('applySystemIcons', const {
          clearCacheType: 'paintbrush',
          searchType: 'magnifyingglass',
          notificationsType: 'bell',
        });
      }
    } on MissingPluginException catch (error, stackTrace) {
      _logFailure(error, stackTrace);
    } on PlatformException catch (error, stackTrace) {
      _logFailure(error, stackTrace);
    }
  }

  bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  void _logFailure(Object error, StackTrace stackTrace) {
    debugPrint('[AppQuickActionsService] $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
