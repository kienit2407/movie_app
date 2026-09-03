import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/core/casting/casting_service.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';

class CastDeviceSheet extends StatefulWidget {
  const CastDeviceSheet({super.key, required this.service, this.media});

  final CastingService service;
  final CastMedia? media;

  @override
  State<CastDeviceSheet> createState() => _CastDeviceSheetState();

  static Future<void> show(
    BuildContext context, {
    CastingService? service,
    CastMedia? media,
  }) {
    final castingService = service ?? PlatformCastingService();
    if (Navigator.maybeOf(context) != null) {
      return _showOnNavigator(context, service: castingService, media: media);
    }

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return Future.value();

    final completed = Completer<void>();
    var presentationStarted = false;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: HeroControllerScope.none(
          child: Navigator(
            onGenerateRoute: (_) => PageRouteBuilder<void>(
              opaque: false,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (navigatorContext, animation, secondaryAnimation) {
                if (!presentationStarted) {
                  presentationStarted = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    try {
                      if (navigatorContext.mounted) {
                        await _showOnNavigator(
                          navigatorContext,
                          service: castingService,
                          media: media,
                        );
                      }
                    } finally {
                      if (!completed.isCompleted) completed.complete();
                    }
                  });
                }
                return const Material(
                  type: MaterialType.transparency,
                  child: SizedBox.expand(),
                );
              },
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    return completed.future.whenComplete(() {
      entry.remove();
      entry.dispose();
    });
  }

  static Future<void> _showOnNavigator(
    BuildContext context, {
    required CastingService service,
    required CastMedia? media,
  }) {
    return showModalBottomSheet<void>(
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 200),
      ),
      context: context,
      useRootNavigator: false,
      builder: (_) => CastDeviceSheet(service: service, media: media),
    );
  }
}

class _CastDeviceSheetState extends State<CastDeviceSheet> {
  StreamSubscription<List<GoogleCastDevice>>? _devicesSubscription;
  Timer? _searchTimeout;
  List<GoogleCastDevice> _devices = const [];
  bool _isSearching = false;
  bool _searchFinished = false;
  String? _connectingDeviceId;

  @override
  void initState() {
    super.initState();
    if (widget.service.supportsGoogleCast) {
      _devicesSubscription = widget.service.googleCastDevices.listen(
        _updateDevices,
      );
      unawaited(_startDiscovery());
    }
  }

  @override
  void dispose() {
    _searchTimeout?.cancel();
    _devicesSubscription?.cancel();
    unawaited(widget.service.stopGoogleCastDiscovery());
    super.dispose();
  }

  void _updateDevices(List<GoogleCastDevice> devices) {
    if (!mounted) return;
    setState(() {
      _devices = devices;
      if (devices.isNotEmpty) {
        _isSearching = false;
        _searchFinished = true;
      }
    });
  }

  Future<void> _startDiscovery() async {
    _searchTimeout?.cancel();
    setState(() {
      _isSearching = true;
      _searchFinished = false;
    });

    final devices = await widget.service.startGoogleCastDiscovery();
    if (!mounted) return;
    _updateDevices(devices);
    if (devices.isNotEmpty) return;

    _searchTimeout = Timer(const Duration(seconds: 8), () {
      if (!mounted || _devices.isNotEmpty) return;
      setState(() {
        _isSearching = false;
        _searchFinished = true;
      });
    });
  }

  Future<void> _showAirPlay(BuildContext context) async {
    final opened = await widget.service.showAirPlayPicker();
    if (!context.mounted) return;
    if (opened) return;
    await _showInfo(
      context,
      title: context.l10n.castAirPlayUnavailableTitle,
      content: context.l10n.castAirPlayUnavailableBody,
    );
  }

  Future<void> _connectGoogleCastDevice(
    BuildContext context,
    GoogleCastDevice device,
  ) async {
    final castMedia = widget.media;
    if (castMedia == null) {
      await _showInfo(
        context,
        title: context.l10n.castVideoUnavailableTitle,
        content: context.l10n.castVideoUnavailableBody,
      );
      return;
    }

    setState(() => _connectingDeviceId = device.id);
    final connected = await widget.service.connectGoogleCastDevice(
      device,
      castMedia,
    );
    if (!context.mounted) return;
    setState(() => _connectingDeviceId = null);
    if (connected) {
      Navigator.of(context).pop();
      return;
    }
    await _showInfo(
      context,
      title: context.l10n.castConnectionFailedTitle,
      content: context.l10n.castConnectionFailedBody,
    );
  }

  Future<void> _showInfo(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return showAnimatedDialog<void>(
      context: context,
      dialog: AppAlertDialog(
        title: title,
        content: content,
        buttonTitle: context.l10n.commonUnderstood,
        icon: const Icon(Icons.cast_connected_rounded, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIos = widget.service.supportsAirPlay;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom + 40,
        ),
        decoration: BoxDecoration(
          color: const Color(0xff2F3345),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              width: 100,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Iconsax.mobile_copy, size: 20),
                  Text(
                    context.l10n.castChooseDevice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            if (isIos)
              _DeviceOption(
                icon: Icons.airplay_rounded,
                title: context.l10n.castAirPlayAndBluetoothDevices,
                onTap: () => _showAirPlay(context),
              )
            else
              _buildGoogleCastContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleCastContent(BuildContext context) {
    if (_devices.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: _devices
            .map((device) {
              final connecting = _connectingDeviceId == device.id;
              return _DeviceOption(
                icon: Iconsax.mirroring_screen_copy,
                title: device.name,
                subtitle: connecting
                    ? context.l10n.castConnecting
                    : (device.description?.trim().isNotEmpty == true
                          ? device.description
                          : context.l10n.castDefaultDeviceName),
                trailing: connecting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : null,
                onTap: connecting
                    ? null
                    : () => _connectGoogleCastDevice(context, device),
              );
            })
            .toList(growable: false),
      );
    }

    if (_isSearching && !_searchFinished) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          children: [
            const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.l10n.castSearching,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          const Icon(Icons.cast_outlined, color: Colors.white38, size: 34),
          const SizedBox(height: 10),
          Text(
            context.l10n.castNoDevices,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            context.l10n.castSameWifiGuidance,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _startDiscovery,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.l10n.castSearchAgain),
          ),
        ],
      ),
    );
  }
}

class _DeviceOption extends StatelessWidget {
  const _DeviceOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
