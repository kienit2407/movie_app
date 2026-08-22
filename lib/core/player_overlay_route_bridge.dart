import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/player_overlay_controller.dart';

class PlayerOverlayRouteBridge extends StatefulWidget {
  const PlayerOverlayRouteBridge({super.key, this.args});

  final MoviePlayerArgs? args;

  @override
  State<PlayerOverlayRouteBridge> createState() =>
      _PlayerOverlayRouteBridgeState();
}

class _PlayerOverlayRouteBridgeState extends State<PlayerOverlayRouteBridge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = widget.args;
      if (args == null) {
        context.go('/home');
        return;
      }

      PlayerOverlayController.instance.open(args, minimizeEnabled: false);
      context.go('/movie/${Uri.encodeComponent(args.slug)}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.black);
  }
}
