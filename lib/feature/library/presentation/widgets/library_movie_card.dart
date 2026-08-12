import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';

bool startsNewLibraryDateGroup(
  DateTime activityDate,
  DateTime? previousActivityDate,
) {
  if (previousActivityDate == null) return true;
  final current = activityDate.toLocal();
  final previous = previousActivityDate.toLocal();
  return current.year != previous.year ||
      current.month != previous.month ||
      current.day != previous.day;
}

class LibraryMovieCard extends StatelessWidget {
  const LibraryMovieCard({
    super.key,
    required this.slug,
    required this.name,
    required this.originName,
    required this.posterUrl,
    required this.episodeCurrent,
    required this.quality,
    required this.lang,
    required this.year,
    required this.activityDate,
    this.rating,
    this.progress,
    this.onRemove,
    this.onTap,
    this.onLongPress,
    this.onSelectionTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.showDateBadge = true,
  });

  final String slug;
  final String name;
  final String originName;
  final String posterUrl;
  final String episodeCurrent;
  final String quality;
  final String lang;
  final int year;
  final DateTime activityDate;
  final double? rating;
  final double? progress;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionTap;
  final bool isSelectionMode;
  final bool isSelected;
  final bool showDateBadge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$name, $episodeCurrent',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSelectionMode
            ? onSelectionTap
            : onTap ??
                  () => context.push(
                    AppRoutes.movieDetail.replaceAll(
                      ':slug',
                      Uri.encodeComponent(slug),
                    ),
                  ),
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    posterUrl.isEmpty
                        ? const ColoredBox(
                            color: Color(0xff292B38),
                            child: Icon(
                              Icons.movie_outlined,
                              color: Colors.white54,
                            ),
                          )
                        : FastCachedImage(
                            key: ValueKey('$slug-library-poster'),
                            url: posterUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 120),
                          ),
                    if (showDateBadge)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _LibraryDateBadge(date: activityDate),
                      ),
                    if (onRemove != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Xóa khỏi danh sách',
                          onPressed: isSelectionMode ? null : onRemove,
                          icon: const Icon(Icons.close, size: 16),
                        ),
                      ),
                    if (isSelectionMode)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xffC77DFF,
                                    ).withValues(alpha: .2)
                                  : Colors.black.withValues(alpha: .12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.secondColor
                                    : Colors.white38,
                                width: isSelected ? 2.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                    if (isSelectionMode)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected ? AppColor.primaryColor : null,
                            color: isSelected ? null : Colors.black54,
                            border: Border.all(color: Colors.white70),
                          ),
                          child: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.circle_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    if (progress != null && progress! > 0)
                      Positioned(
                        left: 2,
                        right: 2,
                        bottom: 0,
                        height: 3,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final normalized = progress!
                                .clamp(0.0, 1.0)
                                .toDouble();
                            final calculatedWidth =
                                constraints.maxWidth * normalized;
                            final visibleWidth =
                                (calculatedWidth < 2 ? 2.0 : calculatedWidth)
                                    .clamp(0.0, constraints.maxWidth)
                                    .toDouble();
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                key: const ValueKey('library-progress-fill'),
                                width: visibleWidth,
                                height: constraints.maxHeight,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColor.secondColor,
                                    borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              progress == null
                  ? [
                      episodeCurrent,
                      year > 0 ? '$year' : '',
                    ].where((value) => value.isNotEmpty).join(' • ')
                  : 'Tiếp tục ${(progress! * 100).round()}%',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .58),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryDateBadge extends StatelessWidget {
  const _LibraryDateBadge({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final localDate = date.toLocal();
    return Semantics(
      label: 'Ngày ${localDate.day} tháng ${localDate.month}',
      child: Container(
        key: const ValueKey('library-date-badge'),
        constraints: const BoxConstraints(minWidth: 42),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${localDate.day}',
              style: const TextStyle(
                fontSize: 12,
                height: 1,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'tháng ${localDate.month}',
              style: const TextStyle(
                fontSize: 8,
                height: 1,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
