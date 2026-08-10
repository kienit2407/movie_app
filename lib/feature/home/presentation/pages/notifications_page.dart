import 'dart:math';
import 'dart:ui';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/common/helpers/static_data.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/feature/home/notification/new_movie_inbox.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _largeTitleKey = GlobalKey();

  late final Map<LinearGradient, Color> _selectedGradient;
  bool _showSmallTitle = false;

  @override
  void initState() {
    super.initState();

    final gradients = StaticData.randomeGadientTitlePage;
    _selectedGradient = gradients[Random().nextInt(gradients.length)];
    _scrollController.addListener(_checkLargeTitleVisibility);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NewMovieInboxCubit>().markAllRead();
    });
  }

  void _checkLargeTitleVisibility() {
    final renderObject = _largeTitleKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;

    final position = renderObject.localToGlobal(Offset.zero);
    final largeTitleBottom = position.dy + renderObject.size.height;
    final appBarHeight = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final shouldShowSmallTitle = largeTitleBottom < appBarHeight + 10;

    if (shouldShowSmallTitle == _showSmallTitle) return;
    setState(() => _showSmallTitle = shouldShowSmallTitle);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = _selectedGradient.keys.single;
    final appBarColor = _selectedGradient.values.single;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final headerDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return Scaffold(
      backgroundColor: AppColor.bgApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(decoration: BoxDecoration(gradient: backgroundGradient)),
          RefreshIndicator.adaptive(
            color: Colors.white,
            onRefresh: context.read<NewMovieInboxCubit>().refresh,
            child: Scrollbar(
              controller: _scrollController,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _buildAppBar(appBarColor, headerDuration),
                  _buildLargeTitle(),
                  BlocBuilder<NewMovieInboxCubit, NewMovieInboxState>(
                    buildWhen: _shouldRebuildNotificationList,
                    builder: (context, state) => _buildList(state),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Color appBarColor, Duration duration) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarHeight: kToolbarHeight,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left_2_copy, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          enabled: _showSmallTitle,
          filter: ImageFilter.blur(
            sigmaX: _showSmallTitle ? 30 : 0,
            sigmaY: _showSmallTitle ? 30 : 0,
          ),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            decoration: _showSmallTitle
                ? BoxDecoration(
                    border: Border.all(
                      color: AppColor.buttonColor.withValues(alpha: .3),
                    ),
                    color: appBarColor.withValues(alpha: .7),
                  )
                : null,
          ),
        ),
      ),
      title: AnimatedOpacity(
        duration: duration,
        curve: Curves.easeOut,
        opacity: _showSmallTitle ? 1 : 0,
        child: const Text(
          'Thông báo',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLargeTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        key: _largeTitleKey,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: const SharderText(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.black,
              Color(0xff717285),
              Colors.black,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          child: Text(
            'Thông báo',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(NewMovieInboxState state) {
    if (state.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (state.items.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: Colors.white38,
                size: 58,
              ),
              SizedBox(height: 12),
              Text(
                'Chưa có thông báo mới',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final groups = _groupByDay(state.items);
    final entries = <_NotificationListEntry>[
      for (final group in groups) ...[
        _NotificationListEntry.date(group.date),
        for (final item in group.items) _NotificationListEntry.item(item),
      ],
    ];
    final indicesByKey = <Key, int>{
      for (var index = 0; index < entries.length; index++)
        entries[index].key: index,
    };

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = entries[index];
            final date = entry.date;
            if (date != null) {
              return Padding(
                key: entry.key,
                padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
                child: Text(
                  _dateLabel(date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }

            return _NotificationMovieTile(key: entry.key, item: entry.item!);
          },
          childCount: entries.length,
          findChildIndexCallback: (key) => indicesByKey[key],
        ),
      ),
    );
  }
}

class _NotificationMovieTile extends StatelessWidget {
  const _NotificationMovieTile({super.key, required this.item});

  final NewMovieInboxItem item;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (62 * pixelRatio).round();
    final cacheHeight = (88 * pixelRatio).round();
    final imageFadeDuration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 120);

    return Card(
      color: Colors.white.withValues(alpha: .055),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          AppRoutes.movieDetail.replaceAll(
            ':slug',
            Uri.encodeComponent(item.slug),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 62,
                  height: 88,
                  child: item.posterUrl.isEmpty
                      ? const ColoredBox(
                          color: Color(0xff292B38),
                          child: Icon(Icons.movie_outlined),
                        )
                      : FastCachedImage(
                          url: item.posterUrl,
                          fit: BoxFit.cover,
                          cacheWidth: cacheWidth,
                          cacheHeight: cacheHeight,
                          fadeInDuration: imageFadeDuration,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      [
                        item.episodeCurrent,
                        item.quality,
                        item.lang,
                      ].where((value) => value.trim().isNotEmpty).join(' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('HH:mm').format(item.detectedAt),
                      style: const TextStyle(
                        color: AppColor.firstColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationListEntry {
  const _NotificationListEntry.date(DateTime value) : date = value, item = null;

  const _NotificationListEntry.item(NewMovieInboxItem value)
    : date = null,
      item = value;

  final DateTime? date;
  final NewMovieInboxItem? item;

  Key get key => date != null
      ? ValueKey<String>('notification-date-${date!.millisecondsSinceEpoch}')
      : ValueKey<String>('notification-item-${item!.slug}');
}

class _NotificationGroup {
  const _NotificationGroup(this.date, this.items);
  final DateTime date;
  final List<NewMovieInboxItem> items;
}

bool _shouldRebuildNotificationList(
  NewMovieInboxState previous,
  NewMovieInboxState current,
) {
  if (previous.isLoading != current.isLoading ||
      previous.items.length != current.items.length) {
    return true;
  }

  for (var index = 0; index < previous.items.length; index++) {
    final oldItem = previous.items[index];
    final newItem = current.items[index];
    if (oldItem.slug != newItem.slug ||
        oldItem.name != newItem.name ||
        oldItem.posterUrl != newItem.posterUrl ||
        oldItem.episodeCurrent != newItem.episodeCurrent ||
        oldItem.quality != newItem.quality ||
        oldItem.lang != newItem.lang ||
        oldItem.detectedAt != newItem.detectedAt) {
      return true;
    }
  }

  return false;
}

List<_NotificationGroup> _groupByDay(List<NewMovieInboxItem> items) {
  final groups = <DateTime, List<NewMovieInboxItem>>{};
  for (final item in items) {
    final local = item.detectedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    groups.putIfAbsent(day, () => []).add(item);
  }
  return groups.entries
      .map((entry) => _NotificationGroup(entry.key, entry.value))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

String _dateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final difference = today.difference(date).inDays;
  if (difference == 0) return 'Hôm nay';
  if (difference == 1) return 'Hôm qua';
  return DateFormat('dd/MM/yyyy').format(date);
}
