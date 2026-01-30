import 'package:flutter/services.dart';

class SupportRotateScreen {
  static void onlyPotrait () {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  static void allowAll () {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
  }
}