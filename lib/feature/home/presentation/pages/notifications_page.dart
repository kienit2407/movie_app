import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/home/notification/new_movie_inbox.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NewMovieInboxCubit>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgApp,
      appBar: AppBar(
        backgroundColor: AppColor.bgApp,
        title: const Text('Thông báo'),
      ),
      body: BlocBuilder<NewMovieInboxCubit, NewMovieInboxState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.items.isEmpty) {
            return const Center(
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
            );
          }
          final groups = _groupByDay(state.items);
          return RefreshIndicator.adaptive(
            onRefresh: context.read<NewMovieInboxCubit>().refresh,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              itemCount: groups.length,
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
                      child: Text(
                        _dateLabel(group.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ...group.items.map(
                      (item) => _NotificationMovieTile(item: item),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationMovieTile extends StatelessWidget {
  const _NotificationMovieTile({required this.item});

  final NewMovieInboxItem item;

  @override
  Widget build(BuildContext context) {
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
                      : FastCachedImage(url: item.posterUrl, fit: BoxFit.cover),
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

class _NotificationGroup {
  const _NotificationGroup(this.date, this.items);
  final DateTime date;
  final List<NewMovieInboxItem> items;
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
