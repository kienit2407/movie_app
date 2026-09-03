import 'package:flutter/material.dart';
import 'package:movie_app/l10n/app_localizations.dart';

Widget localizedTestApp({
  required Widget home,
  ThemeData? theme,
  TransitionBuilder? builder,
}) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme,
    builder: builder,
    home: home,
  );
}
