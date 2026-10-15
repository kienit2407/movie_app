import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/app_toast.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/core/storage/app_cache_service.dart';
import 'package:movie_app/core/widgets/app_loading.dart';
import 'package:storage_space/storage_space.dart'
    show StorageSpace, getStorageSpace;

typedef _StorageSnapshot = ({
  StorageSpace device,
  int appDataBytes,
  int cacheBytes,
});

class StorageManagementPage extends StatefulWidget {
  const StorageManagementPage({
    super.key,
    this.cacheService = const AppCacheService(),
    this.promptClearCache = false,
  });

  final AppCacheService cacheService;
  final bool promptClearCache;

  @override
  State<StorageManagementPage> createState() => _StorageManagementPageState();
}

enum _StorageType { appCache, otherData, empty }

class _StorageManagementPageState extends State<StorageManagementPage> {
  late final ScrollController _scrollController;
  late Future<_StorageSnapshot> _storageFuture;
  bool _isScrolled = false;
  bool _isClearingCache = false;
  bool _didHandleInitialClear = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _storageFuture = _loadStorage();
  }

  Future<_StorageSnapshot> _loadStorage() async {
    final deviceFuture = getStorageSpace(
      fractionDigits: 1,
      lowOnSpaceThreshold: 1024 * 1024 * 1024,
    );
    final appDataFuture = widget.cacheService.getAppDataSizeBytes();
    final cacheFuture = widget.cacheService.getImageCacheSizeBytes();

    return (
      device: await deviceFuture,
      appDataBytes: await appDataFuture,
      cacheBytes: await cacheFuture,
    );
  }

  Future<void> _reloadStorage() async {
    final nextStorage = _loadStorage();
    setState(() => _storageFuture = nextStorage);

    try {
      await nextStorage;
    } catch (_) {
      // FutureBuilder renders the error state.
    }
  }

  Future<void> _clearCache(int cacheBytes) async {
    if (_isClearingCache) return;
    final l10n = context.l10n;
    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: false,
      dialog: AppAlertDialog(
        title: l10n.storageClearDialogTitle,
        content: l10n.storageClearDialogMessage(formatBytes(cacheBytes)),
        buttonTitle: l10n.commonDelete,
        cancelButtonTitle: l10n.commonCancel,
        isDestructive: true,
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isClearingCache = true);

    try {
      await widget.cacheService.clearImageCache();
      if (!mounted) return;

      setState(() {
        _isClearingCache = false;
        _storageFuture = _loadStorage();
      });
      AppToast.show(context, l10n.storageClearSuccess);
    } catch (error, stackTrace) {
      debugPrint('[StorageManagementPage] Failed to clear cache: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;

      setState(() => _isClearingCache = false);
      AppToast.show(context, l10n.storageClearFailed);
    }
  }

  void _promptInitialClearIfNeeded(int cacheBytes) {
    if (!widget.promptClearCache || _didHandleInitialClear) return;
    _didHandleInitialClear = true;
    if (cacheBytes <= 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _clearCache(cacheBytes);
    });
  }

  void _handleScroll() {
    final isScrolled =
        _scrollController.hasClients && _scrollController.offset > 2;
    if (isScrolled == _isScrolled) return;
    setState(() => _isScrolled = isScrolled);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColor.bgApp,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(.8, -1),
                    radius: 1.1,
                    colors: [
                      AppColor.firstColor.withValues(alpha: .18),
                      AppColor.bgApp.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          RefreshIndicator.adaptive(
            onRefresh: _reloadStorage,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 64,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    tooltip: l10n.commonBack,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 21,
                    ),
                  ),
                  title: Text(
                    l10n.settingsStorageManagement,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _isScrolled ? 18 : 0,
                        sigmaY: _isScrolled ? 18 : 0,
                      ),
                      child: AnimatedContainer(
                        key: const ValueKey('storage-header-surface'),
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: _isScrolled
                              ? AppColor.bgApp.withValues(alpha: .88)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: _isScrolled
                                  ? Colors.white.withValues(alpha: .08)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  sliver: SliverToBoxAdapter(
                    child: FutureBuilder<_StorageSnapshot>(
                      future: _storageFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 260,
                            child: AppLoading(),
                          );
                        }

                        if (snapshot.hasError) {
                          return _StorageErrorView(onRetry: _reloadStorage);
                        }

                        final data = snapshot.requireData;
                        _promptInitialClearIfNeeded(data.cacheBytes);
                        return _StorageContent(
                          storage: data.device,
                          appDataBytes: data.appDataBytes,
                          cacheBytes: data.cacheBytes,
                          isClearingCache: _isClearingCache,
                          onClearCache: data.cacheBytes > 0
                              ? () => _clearCache(data.cacheBytes)
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageContent extends StatelessWidget {
  const _StorageContent({
    required this.storage,
    required this.appDataBytes,
    required this.cacheBytes,
    required this.isClearingCache,
    required this.onClearCache,
  });

  final StorageSpace storage;
  final int appDataBytes;
  final int cacheBytes;
  final bool isClearingCache;
  final VoidCallback? onClearCache;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appPercent = storage.total <= 0
        ? 0.0
        : appDataBytes / storage.total * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.storageAppDataTitle(l10n.appTitle),
          style: TextStyle(
            color: Colors.white.withValues(alpha: .78),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          formatBytes(appDataBytes),
          style: const TextStyle(
            fontSize: 42,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.storageUsageSummary(_formatPercent(appPercent)),
          style: TextStyle(
            color: Colors.white.withValues(alpha: .8),
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),
        _StorageUsageBar(
          totalBytes: storage.total,
          usedBytes: storage.used,
          appBytes: appDataBytes,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            _StorageLabel(
              title: l10n.appTitle,
              color: _storageColor(_StorageType.appCache),
            ),
            _StorageLabel(
              title: l10n.storageOtherData,
              color: _storageColor(_StorageType.otherData),
            ),
            _StorageLabel(
              title: l10n.storageFree,
              color: _storageColor(_StorageType.empty),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _CacheCard(
          cacheBytes: cacheBytes,
          isClearing: isClearingCache,
          onClear: onClearCache,
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            l10n.storageDeviceFreeSummary(storage.freeSize, storage.totalSize),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .58),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  String _formatPercent(double percent) {
    if (percent > 0 && percent < 1) return '<1%';
    return '${percent.round()}%';
  }
}

class _CacheCard extends StatelessWidget {
  const _CacheCard({
    required this.cacheBytes,
    required this.isClearing,
    required this.onClear,
  });

  final int cacheBytes;
  final bool isClearing;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.storageCacheAmount(formatBytes(cacheBytes)),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: isClearing ? null : onClear,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 46),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: .28),
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: isClearing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.commonDelete),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.storageCacheDescription,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageErrorView extends StatelessWidget {
  const _StorageErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storage_rounded,
              size: 42,
              color: Colors.white.withValues(alpha: .6),
            ),
            const SizedBox(height: 12),
            Text(context.l10n.storageLoadFailed),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageLabel extends StatelessWidget {
  const _StorageLabel({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: const SizedBox.square(dimension: 9),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _StorageUsageBar extends StatelessWidget {
  const _StorageUsageBar({
    required this.totalBytes,
    required this.usedBytes,
    required this.appBytes,
  });

  final int totalBytes;
  final int usedBytes;
  final int appBytes;

  @override
  Widget build(BuildContext context) {
    final usedFraction = _calculateFraction(usedBytes, totalBytes);
    final appFraction = _calculateFraction(
      appBytes.clamp(0, usedBytes),
      totalBytes,
    );

    return Semantics(
      label: context.l10n.storageAppDataSemantics(
        (appFraction * 100).toStringAsFixed(1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: double.infinity,
          height: 20,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: _storageColor(_StorageType.empty)),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: usedFraction,
                  heightFactor: 1,
                  child: ColoredBox(
                    color: _storageColor(_StorageType.otherData),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: appFraction,
                  heightFactor: 1,
                  child: ColoredBox(
                    color: _storageColor(_StorageType.appCache),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateFraction(num value, int total) {
    if (total <= 0) return 0;
    return (value / total).clamp(0.0, 1.0).toDouble();
  }
}

Color _storageColor(_StorageType type) {
  return switch (type) {
    _StorageType.appCache => const Color(0xFF22C7D8),
    _StorageType.otherData => const Color(0xFFFFCA18),
    _StorageType.empty => const Color(0xFFD3D3D3),
  };
}
