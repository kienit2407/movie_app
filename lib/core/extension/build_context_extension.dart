import 'package:flutter/material.dart';
import 'package:movie_app/l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
