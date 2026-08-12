import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:movie_app/feature/movie_engagement/data/movie_engagement_repository.dart';

class ViewCountSection extends StatefulWidget {
  const ViewCountSection({
    super.key,
    required this.movie,
    this.compact = false,
    this.repository,
  });

  final MovieModel movie;
  final bool compact;
  final MovieEngagementRepository? repository;

  @override
  State<ViewCountSection> createState() => _ViewCountSectionState();
}

class _ViewCountSectionState extends State<ViewCountSection> {
  late final MovieEngagementRepository _repository;
  MovieEngagementMetrics? _metrics;
  StreamSubscription<UserLibraryState>? _librarySubscription;
  bool? _wasFavorite;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? SupabaseMovieEngagementRepository();
    unawaited(_loadMetrics());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_librarySubscription != null) return;
    final libraryCubit = context.read<UserLibraryCubit?>();
    if (libraryCubit == null) return;
    _wasFavorite = libraryCubit.state.isFavorite(widget.movie.slug);
    _librarySubscription = libraryCubit.stream.listen((state) {
      final isFavorite = state.isFavorite(widget.movie.slug);
      if (_wasFavorite == isFavorite ||
          state.syncingFavoriteSlugs.contains(widget.movie.slug)) {
        return;
      }
      _wasFavorite = isFavorite;
      _refreshTimer?.cancel();
      _refreshTimer = Timer(
        const Duration(milliseconds: 350),
        () => unawaited(_loadMetrics()),
      );
    });
  }

  Future<void> _loadMetrics() async {
    try {
      final metrics = await _repository.getMetrics(widget.movie.slug);
      if (!mounted) return;
      setState(() => _metrics = metrics);
    } catch (_) {
      // Lượt xem vẫn lấy từ API phim; khi Supabase lỗi chỉ ẩn lượt thích.
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    unawaited(_librarySubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;
    final views = widget.movie.view;
    final likes = metrics?.likeCount ?? 0;
    final updatedAt = widget.movie.modified?.time.toLocal();
    final metaStyle = TextStyle(
      color: Colors.white.withValues(alpha: .6),
      fontSize: widget.compact ? 10 : 12,
    );
    final parts = <String>[
      '${formatCompactCount(views)} lượt xem',
      '${formatCompactCount(likes)} lượt thích',
      if (!widget.compact && updatedAt != null) _relativeTime(updatedAt),
    ];

    return Wrap(
      spacing: widget.compact ? 6 : 10,
      runSpacing: 3,
      children: [
        for (var index = 0; index < parts.length; index++) ...[
          if (index > 0) Text('•', style: metaStyle),
          Text(parts[index], style: metaStyle),
        ],
      ],
    );
  }
}

String formatCompactCount(int value) {
  if (value >= 1000000000) return _compact(value / 1000000000, 'T');
  if (value >= 1000000) return _compact(value / 1000000, 'Tr');
  if (value >= 1000) return _compact(value / 1000, 'N');
  return value.toString();
}

String _compact(double value, String suffix) {
  final formatted = value.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
  return '$formatted$suffix';
}

String _relativeTime(DateTime value) {
  final difference = DateTime.now().difference(value);
  if (difference.isNegative || difference.inMinutes < 1) return 'Vừa cập nhật';
  if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
  if (difference.inDays < 1) return '${difference.inHours} giờ trước';
  if (difference.inDays < 30) return '${difference.inDays} ngày trước';
  if (difference.inDays < 365) return '${difference.inDays ~/ 30} tháng trước';
  return '${difference.inDays ~/ 365} năm trước';
}
