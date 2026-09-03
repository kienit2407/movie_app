import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';

class InternetStatusBanner extends StatefulWidget {
  const InternetStatusBanner({super.key, this.connectivity});

  final Connectivity? connectivity;

  @override
  State<InternetStatusBanner> createState() => _InternetStatusBannerState();
}

class _InternetStatusBannerState extends State<InternetStatusBanner> {
  late final Connectivity _connectivity = widget.connectivity ?? Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _onlineHideTimer;
  bool _initialized = false;
  bool _visible = false;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _subscription = _connectivity.onConnectivityChanged.listen(_handleResults);
    unawaited(_readInitialStatus());
  }

  Future<void> _readInitialStatus() async {
    try {
      _handleResults(await _connectivity.checkConnectivity());
    } catch (_) {
      // Không đổi UI nếu hệ điều hành tạm thời chưa trả trạng thái mạng.
    }
  }

  void _handleResults(List<ConnectivityResult> results) {
    if (!mounted) return;
    final online =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (!_initialized) {
      _initialized = true;
      setState(() {
        _online = online;
        _visible = !online;
      });
      return;
    }

    if (online == _online) return;
    _onlineHideTimer?.cancel();
    setState(() {
      _online = online;
      _visible = true;
    });

    if (online) {
      _onlineHideTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _online) setState(() => _visible = false);
      });
    }
  }

  @override
  void dispose() {
    _onlineHideTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _online
        ? context.l10n.internetBackOnline
        : context.l10n.internetOffline;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 240);

    return Positioned(
      left: 12,
      right: 12,
      bottom: MediaQuery.viewPaddingOf(context).bottom + 10,
      child: IgnorePointer(
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 1.4),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: duration,
            child: Semantics(
              liveRegion: true,
              label: statusText,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _online
                      ? const Color(0xFF176B45)
                      : const Color(0xFF2B2B31),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
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
