import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';

class HubPage extends StatelessWidget {
  const HubPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _selectTab(int index) {
    if (index == navigationShell.currentIndex) {
      HubTabReselectNotifier.instance.notifyTab(index);
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && navigationShell.currentIndex != 0) {
          _selectTab(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColor.bgApp,
        body: navigationShell,
        bottomNavigationBar: RepaintBoundary(
          child: HubBottomBar(selectedIndex: index, onSelected: _selectTab),
        ),
      ),
    );
  }
}

class HubTabReselectNotifier extends ChangeNotifier {
  HubTabReselectNotifier._();

  static final HubTabReselectNotifier instance = HubTabReselectNotifier._();

  int? _index;

  int? get index => _index;

  void notifyTab(int index) {
    _index = index;
    notifyListeners();
  }
}

/// Dùng chung một bottom bar cho mọi nền tảng.
///
/// Mỗi tab có thể dùng:
/// - IconData
/// - SVG asset
class HubBottomBar extends StatelessWidget {
  const HubBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLibraryCubit, UserLibraryState>(
      buildWhen: (previous, current) => previous.user != current.user,
      builder: (context, libraryState) {
        final metadata =
            libraryState.user?.userMetadata ?? const <String, dynamic>{};

        final avatarUrl = _firstNonEmpty([
          metadata['avatar_url'],
          metadata['picture'],
        ]);

        return _FloatingBlurHubBar(
          selectedIndex: selectedIndex,
          onSelected: onSelected,
          avatarUrl: avatarUrl,
        );
      },
    );
  }
}

class _FloatingBlurHubBar extends StatelessWidget {
  const _FloatingBlurHubBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.avatarUrl,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String avatarUrl;

  static const int _itemCount = 4;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: SizedBox(
        height: 66,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColor.bgApp.withValues(alpha: 0.64),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const outerPadding = 5.0;

                  final availableWidth =
                      constraints.maxWidth - outerPadding * 2;

                  final itemWidth = availableWidth / _itemCount;

                  return Stack(
                    children: [
                      /// Indicator của tab đang chọn.
                      AnimatedPositioned(
                        duration: Duration(
                          milliseconds: reduceMotion ? 80 : 260,
                        ),
                        curve: Curves.easeOutCubic,
                        left: outerPadding + itemWidth * selectedIndex,
                        top: outerPadding,
                        bottom: outerPadding,
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColor.secondColor.withValues(
                                alpha: 0.22,
                              ),
                              borderRadius: BorderRadius.circular(27),
                              border: Border.all(
                                color: AppColor.secondColor.withValues(
                                  alpha: 0.28,
                                ),
                                width: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(outerPadding),
                        child: Row(
                          children: [
                            /// HOME
                            _HubTabButton(
                              selected: selectedIndex == 0,
                              icon: Image.asset(
                                'assets/images/home.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                              activeIcon: Image.asset(
                                'assets/images/home_filled.png',
                                width: 26,
                                height: 26,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                              semanticLabel: 'Trang chủ',
                              onTap: () => onSelected(0),
                              reduceMotion: reduceMotion,
                            ),

                            /// SEARCH
                            _HubTabButton(
                              selected: selectedIndex == 1,
                              icon: const Icon(
                                Iconsax.search_normal_1_copy,
                              ),
                              activeIcon: const Icon(
                                Iconsax.search_normal_1_copy,
                                weight: 8,
                              ),
                              semanticLabel: 'Tìm kiếm',
                              onTap: () => onSelected(1),
                              reduceMotion: reduceMotion,
                            ),

                            /// FAVORITE
                            _HubTabButton(
                              selected: selectedIndex == 2,
                              icon: const Icon(CupertinoIcons.heart, size: 23),
                              activeIcon: const Icon(
                                CupertinoIcons.heart_fill,
                                size: 25,
                              ),
                              semanticLabel: 'Yêu thích',
                              onTap: () => onSelected(2),
                              reduceMotion: reduceMotion,
                            ),

                            /// PROFILE
                            _HubAvatarTabButton(
                              selected: selectedIndex == 3,
                              avatarUrl: avatarUrl,
                              onTap: () => onSelected(3),
                              reduceMotion: reduceMotion,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút điều hướng chỉ quản lý tương tác và hiệu ứng chuyển trạng thái.
///
/// Giao diện icon được truyền từ nơi sử dụng để từng tab có thể tự chọn
/// kích thước, màu sắc hoặc loại widget (Icon, Image, SVG...).
class _HubTabButton extends StatelessWidget {
  const _HubTabButton({
    required this.selected,
    required this.icon,
    this.activeIcon,
    required this.semanticLabel,
    required this.onTap,
    required this.reduceMotion,
  });

  final bool selected;
  final Widget icon;
  final Widget? activeIcon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: semanticLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(27),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Center(
              child: AnimatedScale(
                duration: Duration(milliseconds: reduceMotion ? 70 : 180),
                curve: Curves.easeOutBack,
                scale: selected ? 1.08 : 1,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: reduceMotion ? 70 : 170),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: KeyedSubtree(
                    key: ValueKey(selected),
                    child: ExcludeSemantics(
                      child: IconTheme.merge(
                        data: IconThemeData(
                          size: 24,
                          color: selected ? Colors.white : Colors.white54,
                        ),
                        child: selected ? activeIcon ?? icon : icon,
                      ),
                    ),
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

class _HubAvatarTabButton extends StatelessWidget {
  const _HubAvatarTabButton({
    required this.selected,
    required this.avatarUrl,
    required this.onTap,
    required this.reduceMotion,
  });

  final bool selected;
  final String avatarUrl;
  final VoidCallback onTap;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Hồ sơ',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(27),
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Center(
              child: AnimatedScale(
                duration: Duration(milliseconds: reduceMotion ? 70 : 180),
                curve: Curves.easeOutBack,
                scale: selected ? 1.08 : 1,
                child: _HubAvatarIcon(url: avatarUrl, selected: selected),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HubAvatarIcon extends StatelessWidget {
  const _HubAvatarIcon({required this.url, required this.selected});

  final String url;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Icon(
        selected ? CupertinoIcons.person_fill : CupertinoIcons.person,
        size: 24,
        color: selected ? Colors.white : Colors.white54,
      );
    }

    return Container(
      width: 26,
      height: 26,
      padding: EdgeInsets.all(selected ? 1.5 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: selected ? Border.all(color: Colors.white, width: 1.5) : null,
      ),
      child: ClipOval(
        child: FastCachedImage(key: ValueKey(url), url: url, fit: BoxFit.cover),
      ),
    );
  }
}

String _firstNonEmpty(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';

    if (text.isNotEmpty) {
      return text;
    }
  }

  return '';
}
