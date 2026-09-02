import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class AppToast {
  static const Duration defaultDuration = Duration(seconds: 4);

  static OverlayEntry? _currentEntry;
  static GlobalKey<_AppToastOverlayState>? _currentKey;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
  }) {
    final text = message.trim();
    if (!context.mounted || text.isEmpty) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    _removeCurrent();
    final key = GlobalKey<_AppToastOverlayState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      opaque: false,
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: _AppToastOverlay(
            key: key,
            message: text,
            duration: duration,
            reduceMotion: reduceMotion,
            onDismissed: () => _removeEntry(entry, key),
          ),
        ),
      ),
    );
    _currentEntry = entry;
    _currentKey = key;
    overlay.insert(entry);
  }

  static void _removeCurrent() {
    _currentKey?.currentState?.prepareForImmediateRemoval();
    final entry = _currentEntry;
    _currentEntry = null;
    _currentKey = null;
    if (entry == null) return;
    entry.remove();
    entry.dispose();
  }

  static void _removeEntry(
    OverlayEntry entry,
    GlobalKey<_AppToastOverlayState> key,
  ) {
    if (!identical(_currentEntry, entry) || !identical(_currentKey, key)) {
      return;
    }
    _removeCurrent();
  }
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    super.key,
    required this.message,
    required this.duration,
    required this.reduceMotion,
    required this.onDismissed,
  });

  final String message;
  final Duration duration;
  final bool reduceMotion;
  final VoidCallback onDismissed;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    final animationDuration = widget.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 180);
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
      reverseDuration: animationDuration,
    )..forward();
    _timer = Timer(widget.duration, () => unawaited(_dismiss()));
  }

  void prepareForImmediateRemoval() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _timer?.cancel();
    _timer = null;
    if (!widget.reduceMotion) await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: .96, end: 1).animate(animation),
              alignment: Alignment.topCenter,
              child: _AppToastView(message: widget.message),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppToastView extends StatelessWidget {
  const _AppToastView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.hardEdge,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360, minHeight: 52),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
