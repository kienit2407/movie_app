import 'package:flutter/material.dart';

class NavigatorHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static void pushToPlayer(BuildContext context, Map<String, dynamic> args) {
    try {
      Navigator.of(context, rootNavigator: true).pushNamed('/player', arguments: args);
    } catch (e) {
      print('Navigation error: $e');
    }
  }
}
