import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/core/casting/casting_service.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';

class CastDeviceSheet extends StatelessWidget {
  const CastDeviceSheet({super.key, required this.service, this.media});

  final CastingService service;
  final CastMedia? media;

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

  Future<void> _showAirPlay(BuildContext context) async {
    final opened = await service.showAirPlayPicker();
    if (!context.mounted) return;
    if (opened) return;
    await _showInfo(
      context,
      title: 'Không thể mở AirPlay',
      content: 'Hãy kiểm tra iPhone và TV/Mac đang cùng Wi-Fi rồi thử lại.',
    );
  }

  Future<void> _showGoogleCast(BuildContext context) async {
    final castMedia = media;
    if (castMedia == null) {
      await _showInfo(
        context,
        title: 'Chưa có video để phát',
        content: 'Hãy chờ video tải xong rồi chọn thiết bị Google Cast.',
      );
      return;
    }

    final opened = await service.showGoogleCastPicker(castMedia);
    if (!context.mounted) return;
    if (opened) return;
    await _showInfo(
      context,
      title: 'Không thể mở Google Cast',
      content:
          'Hãy kiểm tra Google Play services và bảo đảm điện thoại, Chromecast hoặc Google TV đang cùng Wi-Fi.',
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
        buttonTitle: 'Đã hiểu',
        icon: const Icon(Icons.cast_connected_rounded, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIos = service.supportsAirPlay;
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Iconsax.mobile_copy, size: 20,),
                  Text(
                    'Chọn thiết bị',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _DeviceOption(
              icon: isIos
                  ? Icons.airplay_rounded
                  : Iconsax.mirroring_screen_copy,
              title: isIos
                  ? 'Các thiết bị AirPlay và Bluetooth'
                  : 'Google Cast',
              subtitle: isIos ? null : 'Chromecast và Google TV',
              onTap: isIos
                  ? () => _showAirPlay(context)
                  : () => _showGoogleCast(context),
            ),
          ],
        ),
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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

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
            ],
          ),
        ),
      ),
    );
  }
}
